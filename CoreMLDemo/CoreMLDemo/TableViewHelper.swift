//
//  TableViewHelper.swift
//  CoreMLDemo
//
//  Created by Jeremy Barr on 9/1/17.
//  Copyright © 2017 Jeremy Barr. All rights reserved.
//

import Foundation
import UIKit

class TableViewHelper: NSObject {
    
    class func EmptyMessage(message: String, viewController: UITableViewController) {
        let messageLabel = UILabel(frame: CGRect(x: 0.0,
                                                 y: 0.0,
                                                 width: viewController.view.bounds.size.width,
                                                 height: viewController.view.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "San Francisco", size: 15)
        messageLabel.sizeToFit()
        
        viewController.tableView.backgroundView = messageLabel
        viewController.tableView.separatorStyle = .none
    }
    
    class func EmptyMessage(message: String, tableView: UITableView) {
        let messageLabel = UILabel(frame: CGRect(x: 0.0,
                                                 y: 0.0,
                                                 width: tableView.bounds.size.width,
                                                 height: tableView.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = UIColor.darkGray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "San Francisco", size: 15)
        messageLabel.sizeToFit()
        
        tableView.backgroundView = messageLabel
        tableView.separatorStyle = .none
    }
}
