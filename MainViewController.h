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


@interface MainViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *gamesTableView;

@property (strong, nonatomic) PFGeoPoint *userLocation;

@property (strong, nonatomic) CLLocation *currentLocation;

@property CLGeocoder *geoCoder;

@property NSArray *gameTimesArray;





@end
