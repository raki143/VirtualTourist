//
//  LocationViewController.swift
//  VirtualTourist
//
//  Created by Rakesh on 3/20/17.
//  Copyright © 2017 Rakesh Kumar. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationViewController: UIViewController,MKMapViewDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var removePinLabel: UILabel!
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    var pin: Pin? = nil
    var annotation: PinAnnotation? = nil
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        title = "Virtual Tourist"
        self.navigationItem.rightBarButtonItem = editButtonItem
        
        // add long press gesture recognizer
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addPinToMap(gesture:)))
        longPressGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGesture)
        
        // execute fetch request to entity Pin.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        do{
            if let locationPins = try stack.context.fetch(fetchRequest) as? [Pin]{
                
                for pin in locationPins{
                    let annotation = PinAnnotation()
                    annotation.pin = pin
                    annotation.coordinate = pin.coordinate
                    mapView.addAnnotation(annotation)
                }
            }
        }catch{
            print("Error in fetch reuest of entity Pin.")
        }
        
        
    }
    
    // add pins to map.
    func addPinToMap(gesture:UILongPressGestureRecognizer){
        
        
        let locationInMap = gesture.location(in: mapView)
        let coordinates : CLLocationCoordinate2D = mapView.convert(locationInMap, toCoordinateFrom: mapView)
        
        switch gesture.state{
        case .began:
            pin = Pin(latitude: coordinates.latitude, longitude: coordinates.longitude, context: stack.context)
            annotation = PinAnnotation()
            annotation?.pin = pin
            annotation?.coordinate = pin!.coordinate
            mapView.addAnnotation(annotation!)
        case .changed:
            pin?.coordinate = coordinates
            annotation?.coordinate = coordinates
        case .ended:
            // call request manager api to request images at pin
            return
            
        default:
            return
        }
        stack.save()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        
        super.setEditing(editing, animated: animated)
        UIView.animate(withDuration: 0.3) {
            self.removePinLabel.isHidden = !editing
            
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil{
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            
        }else{
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    
    
    
}

