//
//  ViewController.swift
//  HeartRateMonitorAdaptor
//
//  Created by admin on 11/15/19.
//  Copyright © 2019 admin. All rights reserved.
//

import UIKit
import CoreBluetooth
import IMHeartRateMonitor

class ViewController: UIViewController {

    fileprivate var availableDevices: [CBPeripheral] = [] {
        didSet { devicesTableView.reloadData() }
    }
    
    @IBOutlet weak var devicesTableView: UITableView! {
        didSet { setupTableView() }
    }
    
    fileprivate var heartRateMonitor = IMHeartRateMonitorServise.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        heartRateMonitor.didConnectCompletion = {
            
        }
        
        heartRateMonitor.didDiscoverPeripheralCompletion = { peripherial in
            self.addPeripheral(peripherial)
        }
    
        heartRateMonitor.startScaning()
    }
}

fileprivate extension ViewController {
    func setupTableView() {
        devicesTableView.register(UINib(nibName: "DeviceTableViewCell", bundle: .main), forCellReuseIdentifier: "DeviceTableViewCellID")
    }
    
    func addPeripheral(_ peripheral: CBPeripheral) {
        if !availableDevices.contains(peripheral) && peripheral.name != nil {
            availableDevices.append(peripheral)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCellID", for: indexPath) as? DeviceTableViewCell
        
        let device = availableDevices[indexPath.row]
        
        cell?.name = device.name
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as? DeviceTableViewCell
        
        let device = availableDevices[indexPath.row]
        

        heartRateMonitor.connectToPeripherial(device, heartRateChangedCompletion: { heartRate in
            cell?.heartRate = heartRate
        })
    }
}
