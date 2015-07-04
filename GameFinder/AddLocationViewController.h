//
//  AddLocationViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 7/4/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddLocationViewController : UIViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *placesTableView;
@property NSMutableArray *placesFoundArray;
@property PFGeoPoint *currentLocation;
@end
