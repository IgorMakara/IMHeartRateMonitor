//
//  DeviceTableViewCell.swift
//  HeartRateMonitorAdaptor
//
//  Created by admin on 12/18/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit

class DeviceTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var heartRateLabel: UILabel!
    
    var name: String? {
        didSet { nameLabel.text = "\(name ?? "")" }
    }
    
    var heartRate: Int? {
        didSet { heartRateLabel.text = "\(heartRate ?? 0)"}
    }
}
