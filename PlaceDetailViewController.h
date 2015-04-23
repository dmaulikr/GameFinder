//
//  PlaceDetailViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 2/12/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import "PlaceDetailCustomTableViewCell.h"


@interface PlaceDetailViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UIApplicationDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapDetailView;





@property (strong, nonatomic) NSTimer *timer;

@property PFGeoPoint *locationCoordinate;

@property CLLocation *locationLocation;

@property NSString *address;

@property NSString *locationNameString;

@property NSString *locationCityString;

@property NSString *locationStateString;

@property NSString *locationZipString;

@property NSString *locationTypeString;

@property NSString *locationPlayerString;

@property NSDate *locationDateString;

@property NSString *objectIDString;

@property NSArray *playersArray;

@property (weak, nonatomic) IBOutlet UITableView *playersTableView;

@property (weak, nonatomic) IBOutlet UIButton *playHereButton;

@property (weak, nonatomic) IBOutlet UIButton *directionsButton;

@property (nonatomic) BOOL isCheckedIn;

@end
