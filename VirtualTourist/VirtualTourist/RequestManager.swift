//
//  RequestManager.swift
//  VirtualTourist
//
//  Created by Rakesh Kumar on 19/03/17.
//  Copyright © 2017 Rakesh Kumar. All rights reserved.
//

import Foundation
import UIKit

typealias GetImagesCompletionHandler = (_ result:Bool,_ error:virtualTouristError) -> Void

struct RequestManager{
    
    static let session = URLSession.shared
    
    static func getImagesAtPin(pin:Pin,completionHandler:@escaping GetImagesCompletionHandler){
        
        
        let methodParameters = [FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
                                FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
                                FlickrParameterKeys.Latitude: "\(pin.coordinate.latitude)",
            FlickrParameterKeys.Longitude: "\(pin.coordinate.longitude)",
            FlickrParameterKeys.Radius: FlickrParameterValues.Radius,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.PerPage: FlickrParameterValues.PerPage,
            FlickrParameterKeys.Page: "\(pin.currentPage)"]
        
        let request = URLRequest(url: getURLFromParameters(parameters: methodParameters as [String : AnyObject]))
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else{
                debugPrint("error with your request \(error)")
                completionHandler(false,virtualTouristError.errorInFetchImagesAtPin)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else{
                debugPrint("StatusCode is otherthan 2xx")
                completionHandler(false,virtualTouristError.errorInFetchImagesAtPin)
                return
            }
            
            guard let data = data else{
                debugPrint("NO data received.")
                completionHandler(false, virtualTouristError.errorInFetchImagesAtPin)
                return
            }
            
            
            do {
                if let parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject] {
                    
                    
                    guard let responseStatus = parsedResult[FlickrResponseKeys.Status] as? String, responseStatus == FlickrResponseValues.OKStatus else {
                        
                        debugPrint("Flickr API returned an error. See error code and message in \(parsedResult)")
                        completionHandler(false,virtualTouristError.errorInFetchImagesAtPin)
                        return
                    }
                    
                    // Is "photos" key in our result?
                    guard let photosDictionary = parsedResult[FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                        debugPrint("Cannot find keys '\(FlickrResponseKeys.Photos)' in \(parsedResult)")
                        completionHandler(false,virtualTouristError.errorInFetchImagesAtPin)
                        return
                    }
                    
                    guard let photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                        debugPrint("array of photos not available")
                        completionHandler(false,virtualTouristError.errorInFetchImagesAtPin)
                        return
                    }
                    
                    
                    
                    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
                    
                    stack.performBackgroundBatchOperation({ (workerContext) in
                        
                        for photoDictionary in photosArray {
                            
                            if let id = photoDictionary[FlickrResponseKeys.ID] as? String, let idDouble = Double(id), let photoURL = photoDictionary[FlickrResponseKeys.MediumURL] as? String {
                                
                                let idNumber = NSNumber(value: idDouble)
                                let photo = Photo(id: idNumber, url: photoURL, context: workerContext)
                                photo.pin = Pin(latitude: pin.latitude, longitude: pin.longitude, context: workerContext)
                                
                                
                            }
                        }
                        completionHandler(true,virtualTouristError.noError)
                        
                    })
                    
                    
                    
                }
                
            } catch {
                
                debugPrint("Could not parse the data as JSON: '\(data)'")
                completionHandler(false,virtualTouristError.errorInFetchImagesAtPin)
                return
            }
            
        }
        
        task.resume()
        
        
    }
    
}


// MARK:- Helper method to construct URL using QueryItem parameters.
func getURLFromParameters(parameters: [String:AnyObject]) -> URL {
    
    var components = URLComponents()
    
    components.scheme = Flickr.APIScheme
    components.host = Flickr.APIHost
    components.path = Flickr.APIPath
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
        let  queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem as URLQueryItem)
    }
    return components.url!
    
}