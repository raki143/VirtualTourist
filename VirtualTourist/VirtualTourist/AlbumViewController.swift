//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Rakesh Kumar on 26/03/17.
//  Copyright © 2017 Rakesh Kumar. All rights reserved.
//

import UIKit
import MapKit

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newCollection: UIBarButtonItem!
    
    var pin : Pin?
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // collection view
        collectionView.register(UINib.init(nibName: "imageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = true
        
        // map view
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.4, longitudeDelta: 0.4)
        let centeredRegion = MKCoordinateRegion(center: (pin?.coordinate)!, span: mapSpan)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        mapView.setRegion(centeredRegion, animated: true)
        let annotation = PinAnnotation()
        annotation.pin = pin
        annotation.coordinate = (pin?.coordinate)!
        mapView.addAnnotation(annotation)
        
        //newCollection (UIBarButton)
        newCollection.target = self
        newCollection.action = #selector(getNewAlbumOrRemoveImages)
        
        // make a request to getImageAtURL
        DispatchQueue.global().async {
            
            if let photos = self.pin?.photos?.allObjects as? [Photo]{
                
                for photo in photos{
                    
                    let url = URL(string: photo.url!)
                    
                    RequestManager.getImageAtURL(url:url!, completion: { (image, error) in
                        
                        if let image = image {
                            photo.imageData = UIImagePNGRepresentation(image) as NSData?
                            
                            DispatchQueue.main.async {
                                self.stack.save()
                                self.collectionView.reloadData()
                            }
                        }
                    })
                }
            }
        }
        
        
    }

    
    // MARK: - collection view methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : imageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! imageCollectionViewCell
        
        let photo = pin?.photos?.allObjects[indexPath.row] as! Photo
        
        // image Data available 
        if let imageData = photo.imageData{
            
            cell.imageView.image = UIImage(data: imageData as Data)
            
        }else{
            // no image data available. so need to download from web.
            
            cell.loadImageCell(loading: true)
            
            DispatchQueue.global().async {
                
                let url = URL(string: photo.url!)
                
                RequestManager.getImageAtURL(url: url!, completion: { (image, error) in
                    
                    if let image = image{
                        
                        DispatchQueue.main.async {
                            
                            if let imageCell = collectionView.cellForItem(at: indexPath) as? imageCollectionViewCell{
                                
                                imageCell.loadImageCell(loading: false)
                                imageCell.imageView.image = image
                                imageCell.layoutIfNeeded()
                            }
                            
                            photo.imageData = UIImagePNGRepresentation(image) as NSData?
                            self.stack.save()
                        }
                    }
                })
            }
            
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (pin?.photos?.count)!
    }
    
    //MARK:- UIBarButton newCollection method
    func getNewAlbumOrRemoveImages(){
        
    }
    
}
