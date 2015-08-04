//
//  GameLocationTableViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 7/27/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GameLocationTableViewController : UITableViewController <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addGamesButton;
@property (weak, nonatomic) IBOutlet UIView *upperView;
@property (weak, nonatomic) IBOutlet UIButton *contractMapButton;
@property (weak, nonatomic) IBOutlet UIButton *centerMapButton;
@property NSArray *gameLocationsArray;
@end
