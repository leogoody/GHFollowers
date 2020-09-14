//
//  Date+Ext.swift
//  GHFollowers
//
//  Created by Леонид Кузнецов on 31.03.2020.
//  Copyright © 2020 Leonid Kuznetcov. All rights reserved.
//

import Foundation

extension Date {
    
    func convertToMonthYearFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: self)
    }
}
