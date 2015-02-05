//
//  FindGamesViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 1/24/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>



@interface FindGamesByLocationViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) PFGeoPoint *userLocation;



@end
