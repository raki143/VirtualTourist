    //
    //  AlbumViewController.swift
    //  VirtualTourist
    //
    //  Created by Rakesh Kumar on 26/03/17.
    //  Copyright © 2017 Rakesh Kumar. All rights reserved.
    //
    
    import UIKit
    import MapKit
    import CoreData
    
    class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
        
        
        @IBOutlet private weak var mapView: MKMapView!
        
        @IBOutlet private weak var collectionView: UICollectionView!
        
        @IBOutlet private weak var newCollection: UIBarButtonItem!
        
        @IBOutlet private var noImagesDialogView: UIView!
        
        public var pin : Pin?
        
        private let stack = (UIApplication.shared.delegate as! AppDelegate).stack
        
        override func viewDidLoad() {
            
            super.viewDidLoad()
            
            // collection view
            collectionView.register(UINib.init(nibName: "ImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "imageCell")
            
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.allowsMultipleSelection = true
            
            let width : CGFloat
            
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                width = collectionView.frame.size.width / 1.5
            case .phone:
                width = collectionView.frame.size.width / 2
            default:
                width = collectionView.frame.size.width / 2
            }
            
            
            
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: width)
            
            // map view
            let mapSpan = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            let centeredRegion = MKCoordinateRegion(center: (pin?.coordinate)!, span: mapSpan)
            mapView.isZoomEnabled = false
            mapView.isScrollEnabled = true
            mapView.isUserInteractionEnabled = true
            mapView.setRegion(centeredRegion, animated: true)
            let annotation = PinAnnotation()
            annotation.pin = pin
            annotation.coordinate = (pin?.coordinate)!
            mapView.addAnnotation(annotation)
            
            //newCollection (UIBarButton)
            newCollection.target = self
            newCollection.action = #selector(getNewAlbumOrRemoveImages)
            
            
            
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            
            // if pin has no images to show or current page is last page disable new collection button.
            if pin?.totalPages == 0 || pin?.currentPage == pin?.totalPages{
                newCollection.isEnabled = false
            }
            
            noImagesDialogView.isHidden = true
            
        }
        
        
        
        // MARK: - collection view methods
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell : ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
            
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
                        
                        
                        
                        DispatchQueue.main.async {
                            
                            cell.loadImageCell(loading: false)
                            
                            if let image = image{
                               
                                cell.imageView.image = image
                                cell.layoutIfNeeded()
                                
                                
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
            
            // if pin has no images to show then only display noImagesView
            if pin?.photos?.count == 0{
                noImagesDialogView.isHidden = false
            }
            
            return (pin?.photos?.count)!
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell{
                
                if cell.isSelected{
                    
                    newCollection.title = CollectionButton.removeImages
                    // If it is last page change newCollection button state to enable.
                    if pin?.currentPage == pin?.totalPages {
                        newCollection.isEnabled = true
                    }
                    
                }
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            
            guard let selectedCells = collectionView.indexPathsForSelectedItems, selectedCells.count > 0 else{
                // if all selected items are deselected and pin current page is last page then disable newcollection button
                if pin?.currentPage == pin?.totalPages {
                    newCollection.isEnabled = false
                }
                newCollection.title = CollectionButton.newCollection
                return
            }
        }
        
        //MARK:- UIBarButton newCollection method
        func getNewAlbumOrRemoveImages(){
            
            
            if newCollection.title == CollectionButton.newCollection{
                
                // hide noImagesDialogView
                noImagesDialogView.isHidden = true
                
                // disable newCollection button
                newCollection.isEnabled = false
                
                // increment current page when lessthan total pages
                if (pin?.currentPage)! < (pin?.totalPages)!{
                    pin?.currentPage += 1
                }
                

                DispatchQueue.global().async {
                    RequestManager.getImagesAtPin(pin: self.pin!, completionHandler: { (result, error) in
                        
                        DispatchQueue.main.async {
                            
                            // enable newCollection button
                            self.newCollection.isEnabled = true
                            
                            if result {
                                print("Fetching new collection is successfull.")
                                
                                // Delete photos of pin only when new collection request is successful.
                                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                                fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
                                let deletePhotosRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                                
                                do{
                                    try self.stack.context.execute(deletePhotosRequest)
                                }catch let error as NSError {
                                    print("Unable to delete photos : \(error.localizedDescription)")
                                }
                                
                                self.pin?.photos = []
                                
                                // new collection button is disabled when current page reaches last page
                                if self.pin?.currentPage == self.pin?.totalPages{
                                    self.newCollection.isEnabled = false
                                }
                                self.collectionView.reloadData()
                                
                            }else{
                                self.pin?.currentPage -= 1
                            }
                            
                        }
                    })
                }
                
            }else if newCollection.title == CollectionButton.removeImages{
                
                guard let selectedImagesIndexPath = collectionView.indexPathsForSelectedItems, selectedImagesIndexPath.count > 0 else {
                    return
                }
                
                collectionView.performBatchUpdates({
                    
                    for imageIndexPath in selectedImagesIndexPath{
                        
                        if let photo = self.pin?.photos?.allObjects[imageIndexPath.row] as? Photo{
                            self.stack.context.delete(photo)
                        }
                        
                    }
                    
                    self.stack.save()
                    self.collectionView.deleteItems(at: selectedImagesIndexPath)
                    
                    }, completion: { (result) in
                        
                        DispatchQueue.main.async(execute: {
                            if self.pin?.currentPage == self.pin?.totalPages{
                                self.newCollection.isEnabled = false
                            }
                            self.newCollection.title = CollectionButton.newCollection
                        })
                })
                
            }
            
        }
        
    }
    
    
    
    
    
    
    
    
