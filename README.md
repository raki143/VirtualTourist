# VirtualTourist

Virtual Tourist allows users to specify travel locations around the world, and create virtual photo albums and places for each location. Users are able to drop pins around the world. As soon as a pin is dropped the Photo data for the pin location is  fetched from the Flickr API and stored in Core data.Tapping a pin allows users to access a photo album view that lets them view and edit an album of images for a location displayed in a collection view. 

## Implementation
This app has two view controllers:

- __Location View Controller__: - This view controller shows the map and allows user to drop pins all over the world. Whenever user tap on dropped pin, photos are fetched from flickr at that particular location coordinates. User can delete pins in edit mode of this view controller.

- __Album View Controller__: - This view controller will show map with selected drop pin and photo album. All the downloaded photos will be updated in the photo album for selected pin location. New collection button will fetch new photos for the location. User has a chance to delete photos in the edit mode of this view controller.   

- Application uses CoreData, MapKit, UIKit.
