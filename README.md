# IMHeartRateMonitor
  IMHeartRateMonitor is a lightweight library on top of Core Bluetooth to interact with BLE Heart Rate Monitors

  It allows you to get Heart Rate value form Heart Rate Monitors.

      - Easy to connect
      - Everything is already parsed
      - Connect and get data

# Documentation & Support

    See some code bellow. Also, make sure you checkout the example app. It contains such as functionality: list, connect,                  disconnect, auto-connect to last device.

# Example
 
    Clone the project, and run pod install from the IMHeartRateMonitorExample directory first.
 
 ## Warning:

    -Specify a bundle identifier, Team and provisioning profiles to run.

    -You will need an actual device to connect to HR monitors
 
 # Requirements
 
    Swift 4.0
 
 # Installation
 
    IMHeartRateMonitor is available on CocoaPods. To install it, simply add the following line to your Podfile:

  ```ruby
        pod 'IMHeartRateMonitor'
```

# Usage

## Import 
```ruby
        import IMHeartRateMonitor
```

## Create Monitor

```ruby
        let heartRateMonitor = IMHeartRateMonitor.shared
```

## Start
```ruby
        heartRateMonitor.didConnectCompletion = {
            //state changed
        }
        
        heartRateMonitor.didDiscoverPeripheralCompletion = { peripherial in
            //append discovered peripherals
        }
    
        heartRateMonitor.startScaning()
        
```

## Connect to peripheral

```ruby
        heartRateMonitor.connectToPeripherial(peripheral, heartRateChangedCompletion: { heartRate in
            
        })
```
## Observe changes
```ruby
        heartRateMonitor.didUpdateCharacteristicCompletion = { peripheral in
        
        }

        heartRateMonitor.didDisconnectCompletion = {

        }
        
        heartRateMonitor.connectionStateChangedCompletion = { state in

        }
    
        heartRateMonitor.heartRateChangedCompletion = { heartRate in
    
        }
        
        
        GET MANUFACTURE DEVICE NAME 
        
        func getPeripherialName() -> String?
```
