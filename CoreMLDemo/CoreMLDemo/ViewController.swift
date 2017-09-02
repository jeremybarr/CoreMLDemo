//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by Jeremy Barr on 8/28/17.
//  Copyright © 2017 Jeremy Barr. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO

class ViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var chosenImageView: UIImageView!
    @IBOutlet weak var classificationTableView: UITableView!
    @IBOutlet weak var takePictureButton: UIBarButtonItem!
    @IBOutlet weak var chooseImageButton: UIBarButtonItem!
    
    // MARK: Variables
    var inputImage: CIImage = CIImage()
    var classificationArray: [VNClassificationObservation] = [VNClassificationObservation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: IBActions
    @IBAction func takePictureButtonPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        present(picker,
                animated: true,
                completion: nil)
    }
    
    @IBAction func chooseImageButtonPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker,
                animated: true,
                completion: nil)
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            return VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
        } catch {
            fatalError("Can't load Vision ML Model: \(error)")
        }
    }()
    
    func handleClassification(request: VNRequest, error: Error?) {
        // Make sure we have some observations
        guard let observations = request.results as? [VNClassificationObservation] else {
            fatalError("Unexpected result type from VNCoreMLRequest")
        }
        // Clear the array of results and reload it with our observation results
        classificationArray.removeAll()
        classificationArray = observations
        
        // We have to reload the table view on the main threaad
        DispatchQueue.main.async {
            self.classificationTableView.separatorStyle = .singleLine
            self.classificationTableView.reloadData()
        }
    }
}

// MARK: UITableView DataSource/Delegate Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classificationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classificationCellIdentifier", for: indexPath)
        
        let observation: VNClassificationObservation = classificationArray[indexPath.row]
        
        // Display the results of the classification in the table view cells
        cell.textLabel?.text = observation.identifier
        cell.detailTextLabel?.text = "\(Int(round(observation.confidence*100)))%"
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if classificationArray.count > 0 {
            return 1
        } else {
            // Helper method to create a nice little message in
            // case of an empty table view.
            TableViewHelper.EmptyMessage(message: "Looks like we don't have an image to analyze.\nTake a picture or select one from your library.", tableView: classificationTableView)
            return 0
        }
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Make sure we actually have an image to work with.
        guard let uiImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("No image from image picker.")
        }
        // We need to be able to convert the image into a CIImage
        guard let ciImage = CIImage(image: uiImage) else {
            fatalError("Can't create CIImage from UIImage.")
        }
        
        // Setting the orientation of the image so we know how to analyze it
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(uiImage.imageOrientation.rawValue))
        inputImage = ciImage.oriented(orientation!)
        
        // Display the image in the ImageView
        chosenImageView.image = uiImage
        
        // Actually process the image with the Vision framework
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(ciImage: self.inputImage, options: [:])
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print(error)
            }
        }
    }
    
    
}

