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


@interface MainViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *gamesTableView;

@property (strong, nonatomic) PFGeoPoint *userLocation;

@property (strong, nonatomic) CLLocation *currentLocation;

@property (weak, nonatomic) IBOutlet UIButton *zoomButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addGamesButton;

@property CLGeocoder *geoCoder;

@property NSArray *gameTimesArray;


@property (weak, nonatomic) IBOutlet UITextField *locationName;

@property (weak, nonatomic) IBOutlet UIView *locationNameView;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerControl;

@property (weak, nonatomic) IBOutlet UIPickerView *typePicker;

@property NSArray *pickerArray;

@property NSArray *placeTypeArray;
@property (weak, nonatomic) IBOutlet UILabel *numberOfPlayers;
@property (weak, nonatomic) IBOutlet UILabel *typeOfLocation;

@end
