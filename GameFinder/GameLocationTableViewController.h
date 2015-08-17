//
//  GameLocationTableViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 7/27/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SearchResultsTableViewController.h"

@interface GameLocationTableViewController : UITableViewController <UIActionSheetDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating, UISearchControllerDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addGamesButton;
@property (weak, nonatomic) IBOutlet UIView *upperView;
@property (weak, nonatomic) IBOutlet UIButton *contractMapButton;
@property (weak, nonatomic) IBOutlet UIButton *centerMapButton;
@property NSMutableArray *gameLocationsArray;



//Seach bar
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) SearchResultsTableViewController *searchResultsTableView;

@property BOOL isFiltered;
@end
