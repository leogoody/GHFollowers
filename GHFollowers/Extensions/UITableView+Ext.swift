//
//  UITableView+Ext.swift
//  GHFollowers
//
//  Created by Леонид Кузнецов on 07.04.2020.
//  Copyright © 2020 Leonid Kuznetcov. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async { self.reloadData() }
    }
    
    
    func removeExcessCells() {
        tableFooterView = UIView(frame: .zero)
    }
}
