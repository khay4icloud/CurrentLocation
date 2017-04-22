//
//  ViewController.swift
//  CurrentLoaction
//
//  Created by Sri Kalyan Ganja on 4/18/17.
//  Copyright © 2017 KLYN. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    
    //MARK: Properties
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startStandardUpdates() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Set a movement threshold for new events 
        locationManager.distanceFilter = 500 //meters 
        
        //Start Location Manager
        locationManager.startUpdatingLocation()
        
    }

    //MARK: Actions
    @IBAction func getCurrentLocation(_ sender: Any) {
        
        if CLLocationManager.locationServicesEnabled() {
            self.startStandardUpdates()
        } else {
            print("Location services not enabled by the user")
        }
    }
    
    //MARK: CoreLocation - Delegate methods
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: %@", error)
        
        let alert = UIAlertController(title: "Error", message: "Failed to get location", preferredStyle: .alert)
        let defautlAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(defautlAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation : CLLocation = locations.last!
        
        latitudeLabel.text = "\(currentLocation.coordinate.latitude)"
        longitudeLabel.text = "\(currentLocation.coordinate.longitude)"
        
        //Stop Location Manager
        locationManager.stopUpdatingLocation()
        
        //Reverse Geocoding
        print("Resolving the address")
        CLGeocoder().reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) -> Void in
            if !(error == nil) {
                
                print (error ?? "Error, Placemarks not available")
                return
                
            }
            else {
                if let placemark = placemarks?.last {
                    
//                    self.addressLabel.text = String(format: "%@, %@, \n%@, %@, \n%@, \n%@", placemark.subThoroughfare!, placemark.thoroughfare!,
//                    placemark.postalCode!, placemark.locality!, placemark.administrativeArea!, placemark.country!)
                    
                    self.addressLabel.text = self.localizedStringForAddressDictionary(addressDictionary: placemark.addressDictionary!
                        as Dictionary<NSObject, AnyObject>)
                    
                } else {
                    print ("test did not work")
                }
            }
        
        })
    }
    
    // Convert to the newer CNPostalAddress
    func postalAddressFromAddressDictionary(_ addressdictionary: Dictionary<NSObject,AnyObject>) -> CNMutablePostalAddress {
        let address = CNMutablePostalAddress()
        
        address.street = addressdictionary["Street" as NSObject] as? String ?? ""
        address.state = addressdictionary["State" as NSObject] as? String ?? ""
        address.city = addressdictionary["City" as NSObject] as? String ?? ""
        address.country = addressdictionary["Country" as NSObject] as? String ?? ""
        address.postalCode = addressdictionary["ZIP" as NSObject] as? String ?? ""
        
        return address
    }
    
    // Create a localized address string from an Address Dictionary
    func localizedStringForAddressDictionary(addressDictionary: Dictionary<NSObject,AnyObject>) -> String {
        return CNPostalAddressFormatter.string(from: postalAddressFromAddressDictionary(addressDictionary), style: .mailingAddress)
    }
    
}



