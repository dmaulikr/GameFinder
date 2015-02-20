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
#import <AddressBook/AddressBook.h>

@interface PlaceDetailViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapDetailView;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UILabel *zipLabel;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;


@property PFGeoPoint *locationCoordinate;

@property CLLocation *locationLocation;

@property NSString *address;

@property NSString *locationNameString;

@property NSString *locationCityString;

@property NSString *locationStateString;

@property NSString *locationZipString;

@property NSString *locationTypeString;

@end
