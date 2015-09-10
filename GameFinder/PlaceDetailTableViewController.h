//
//  PlaceDetailTableViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 9/9/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface PlaceDetailTableViewController : UITableViewController<UICollectionViewDataSource, UICollectionViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property PFObject *placeObject;
;

@property PFGeoPoint *locationCoordinate;

@property BOOL isCloseEnough;

@property NSArray *playersArray;
@property NSArray *picturesArray;

@property (weak, nonatomic) IBOutlet UICollectionView *playerCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *pictureCollectionView;



@property (weak, nonatomic) IBOutlet UIImageView *lightImageView;
@property (weak, nonatomic) IBOutlet UIImageView *coveredImageView;
@property (weak, nonatomic) IBOutlet UIImageView *indoorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *publicImageView;

@property (weak, nonatomic) IBOutlet UIButton *navigationButton;

@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;

@property NSNumber *outdoorString;
@property NSNumber *lightString;
@property NSNumber *publicString;
@property NSNumber *coveredString;
@property NSString *titleString;
@end
