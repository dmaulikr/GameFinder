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
#import "SDWebImage/UIButton+WebCache.h"


@interface MainViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITableView *gamesTableView;

@property (strong, nonatomic) PFGeoPoint *userLocation;


@property (weak, nonatomic) IBOutlet UIButton *zoomButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addGamesButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationTitle;

@property CLGeocoder *geoCoder;

@property NSArray *gameTimesArray;

@property NSString *locationName;

@property NSString *locationType;






@end
