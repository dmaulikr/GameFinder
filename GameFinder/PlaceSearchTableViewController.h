//
//  PlaceSearchTableViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 9/10/15.
//  Copyright © 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface PlaceSearchTableViewController : UITableViewController <CLLocationManagerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *places;

@end
