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
#import "PlaceDetailCollectionViewCell.h"


@interface PlaceDetailViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate, UIApplicationDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSDictionary *placeObject;
@property (weak, nonatomic) IBOutlet UITextField *scheduleGameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addNumberOfPlayersTextField;

@property PFGeoPoint *locationCoordinate;

@property BOOL isCloseEnough;

@property NSArray *playersArray;
@property (weak, nonatomic) IBOutlet UILabel *takePictureLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *playerCollectionView;
@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;

@property NSArray *numberPickerArray;
@property (weak, nonatomic) IBOutlet UIButton *saveScheduleButton;
@property (weak, nonatomic) IBOutlet UIButton *saveAddPlayersButton;
@property (weak, nonatomic) IBOutlet UILabel *scheduleGameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addPlayersLabel;
@property NSMutableArray *scheduledGamesArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *lightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coveredImageView;
@property (weak, nonatomic) IBOutlet UIImageView *indoorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *publicImageView;

@property (weak, nonatomic) IBOutlet UIView *courtInformationView;


@property NSNumber *outdoorString;
@property NSNumber *lightString;
@property NSNumber *publicString;
@property NSNumber *coveredString;
@property NSString *titleString;
@end
