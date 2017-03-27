//
//  Constants.swift
//  VirtualTourist
//
//  Created by Rakesh Kumar on 19/03/17.
//  Copyright © 2017 Rakesh Kumar. All rights reserved.
//



struct Flickr {
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    
}

// MARK: Flickr Parameter Keys
struct FlickrParameterKeys {
    static let Method = "method"
    static let APIKey = "api_key"
    static let Latitude = "lat"
    static let Longitude = "lon"
    static let Radius = "radius"
    static let GalleryID = "gallery_id"
    static let Extras = "extras"
    static let Format = "format"
    static let NoJSONCallback = "nojsoncallback"
    static let SafeSearch = "safe_search"
    static let PerPage = "per_page"
    static let Page = "page"
}

// MARK: Flickr Parameter Values
struct FlickrParameterValues {
    static let SearchMethod = "flickr.photos.search"
    static let APIKey = "d960369b1a397748188d4364767e315c"
    static let Radius = "5"
    static let ResponseFormat = "json"
    static let DisableJSONCallback = "1" /* 1 means "yes" */
    static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
    static let GalleryID = "5704-72157622566655097"
    static let MediumURL = "url_m"
    static let PerPage = "21"
    static let UseSafeSearch = "1"
}

// MARK: Flickr Response Keys
struct FlickrResponseKeys {
    static let ID = "id"
    static let Status = "stat"
    static let Photos = "photos"
    static let Photo = "photo"
    static let Title = "title"
    static let MediumURL = "url_m"
    static let Pages = "pages"
}

// MARK: Flickr Response Values
struct FlickrResponseValues {
    static let OKStatus = "ok"
}

// MARK: Button Title
struct CollectionButton{
    static let newCollection = "New Collection"
    static let removeImages = "Remove Selected Images"
}



