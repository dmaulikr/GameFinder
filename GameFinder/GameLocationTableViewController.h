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

@property NSArray *gameLocationsArray;
@end
