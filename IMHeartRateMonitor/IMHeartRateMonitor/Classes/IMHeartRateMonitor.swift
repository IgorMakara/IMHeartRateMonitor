//
//  IMHeartRateMonitor.swift
//  IMHeartRateMonitor
//
//  Created by admin on 12/24/19.
//  Copyright © 2019 IgorMakara. All rights reserved.
//
import Foundation
import CoreBluetooth

public enum ConnectionState {
    case connected
    case disconnected
    case connecting
    
    var title: String? {
        switch self {
        case .connected:
            return NSLocalizedString("Connected", comment: "")
        case .disconnected:
            return NSLocalizedString("Not connected", comment: "")
        case .connecting:
            return NSLocalizedString("Connecting…", comment: "")
        }
    }
}

open class IMHeartRateMonitorServise: NSObject {
    
    fileprivate let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    fileprivate let deviceInfoServiceCBUUID = CBUUID(string: "0x180A")
    fileprivate let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
    fileprivate let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")
    fileprivate let deviceManufactureCharacteristicCBUUID = CBUUID(string: "2A29")

    fileprivate struct Constants {
        static let lastConnectedDeviceIdKey = "BLEHandler.LastConnectedDeviceIdKey"
    }
    
    public static let shared = IMHeartRateMonitorServise()
    
    //MARK: Variables
    
    fileprivate var centralManager: CBCentralManager?
    fileprivate var heartRatePeripheral: CBPeripheral?
    
    public var connectionState: ConnectionState = .disconnected {
        didSet {
            connectionStateChangedCompletion?(connectionState)
        }
    }
    
    public var didDiscoverPeripheralCompletion: ((CBPeripheral)->Void)?
    public var didUpdateCharacteristicCompletion: ((CBPeripheral)->Void)?
    public var didConnectCompletion: (()->Void)?
    public var didDisconnectCompletion: (()->Void)?
    public var connectionStateChangedCompletion: ((ConnectionState)->Void)?
    
    public var heartRateChangedCompletion: ((Int)->Void)?
    var connectedDevice: CBPeripheral?
    
    //MARK: Public
    
    public func startScaning() {
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
    
    public func disconnectPeripherial(_ peripherial: CBPeripheral? = nil) {
        if let peripherial = peripherial {
            centralManager?.cancelPeripheralConnection(peripherial)
        }else if let peripherial = connectedDevice {
            centralManager?.cancelPeripheralConnection(peripherial)
        }
    }
    
    
    public func connectToPeripherial(_ peripheral: CBPeripheral, heartRateChangedCompletion: @escaping ((Int)->Void), connectedCompletion: (()->Void)? = nil) {

        connectPeripherial(peripheral)
        
        self.heartRateChangedCompletion = heartRateChangedCompletion
    }
    
    public func getManufacturePeripherialName() -> String? {
        
        for servise in connectedDevice?.services ?? [] {
            
            if servise.uuid == deviceInfoServiceCBUUID {
                for characteristic in servise.characteristics ?? [] {
                    if characteristic.uuid == deviceManufactureCharacteristicCBUUID {
                        if let manufacturerName = characteristic.value {
                            
                            let manufacturerName = String(decoding: manufacturerName, as: UTF8.self)
                            
                            return "\(manufacturerName) \(connectedDevice?.name ?? "")"
                        }
                    }else {
                        return connectedDevice?.name
                    }
                }
            }
        }
        
        return nil
    }
}

fileprivate extension IMHeartRateMonitorServise {
    func onHeartRateReceived(_ heartRate: Int) {
        heartRateChangedCompletion?(heartRate)
        print("BPM: \(heartRate)")
    }
    
    func connectPeripherial(_ peripheral: CBPeripheral) {
        heartRatePeripheral = peripheral
        heartRatePeripheral?.delegate = self
        
        centralManager?.stopScan()
        
        centralManager?.connect(peripheral)
        
        connectionState = .connecting
    }
}

//MARK: CBCentralManagerDelegate

extension IMHeartRateMonitorServise: CBCentralManagerDelegate {
   @objc public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager?.scanForPeripherals(withServices: [heartRateServiceCBUUID, deviceInfoServiceCBUUID], options: nil)
        @unknown default:
            print("central.state is unknown")
        }
    }

    @objc public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        didDiscoverPeripheralCompletion?(peripheral)
        
        print("disccover")
        
        if let lastConnectedDevideId = retriveLastDeviceConnectedId() {
            if peripheral.identifier.uuidString == lastConnectedDevideId {
                connectPeripherial(peripheral)
            }
        }
    }
    
    @objc public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        
        didConnectCompletion?()
        
        heartRatePeripheral?.discoverServices([heartRateServiceCBUUID, deviceInfoServiceCBUUID])
        
        saveLastConnectedDevice()
    }
    
    @objc public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectionState = .disconnected
        connectedDevice = nil
        didDisconnectCompletion?()
    }
}

//MARK: CBPeripheralDelegate

extension IMHeartRateMonitorServise: CBPeripheralDelegate {
    @objc public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            switch service.uuid {
            case heartRateServiceCBUUID:
                peripheral.discoverCharacteristics([heartRateMeasurementCharacteristicCBUUID], for: service)
            case deviceInfoServiceCBUUID:
                peripheral.discoverCharacteristics([deviceManufactureCharacteristicCBUUID], for: service)
            default:
                break
            }
        }
    }
    
    @objc public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
            
            if characteristic.properties.contains(.read) {
                print("\(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    @objc public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case bodySensorLocationCharacteristicCBUUID:
            let bodySensorLocation = bodyLocation(from: characteristic)
            print("Heart rate sensor location: \(bodySensorLocation)")
        case heartRateMeasurementCharacteristicCBUUID:
            let bpm = heartRate(from: characteristic)
            onHeartRateReceived(bpm)
        case deviceManufactureCharacteristicCBUUID:
            break
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
        
        didUpdateCharacteristicCompletion?(peripheral)
    }
    
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }
    
    private func heartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        // See: https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
        // The heart rate mesurement is in the 2nd, or in the 2nd and 3rd bytes, i.e. one one or in two bytes
        // The first byte of the first bit specifies the length of the heart rate data, 0 == 1 byte, 1 == 2 bytes
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}

//MARK: Last device connected handling

fileprivate extension IMHeartRateMonitorServise {
    func saveLastConnectedDevice() {
        guard let deviceId = connectedDevice?.identifier.uuidString else { return }
        
        UserDefaults.standard.set(deviceId, forKey: Constants.lastConnectedDeviceIdKey)
    }
    
    func retriveLastDeviceConnectedId() -> String? {
        let id = UserDefaults.standard.value(forKey: Constants.lastConnectedDeviceIdKey) as? String
        return id
    }
}
