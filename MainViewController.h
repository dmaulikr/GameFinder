//
//  MainViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 2/9/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "CustomTableViewCell.h"
#import "SVProgressHUD.h"
#import <CoreLocation/CoreLocation.h>


@interface MainViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *gamesTableView;

@property (strong, nonatomic) PFGeoPoint *userLocation;

@property (strong, nonatomic) CLLocation *currentLocation;

@property (weak, nonatomic) IBOutlet UIButton *zoomButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addGamesButton;

@property CLGeocoder *geoCoder;

@property NSArray *gameTimesArray;

@property NSString *locationName;


@property NSString *locationType;


@property (nonatomic, retain) CLLocationManager *locationManager;


@end
