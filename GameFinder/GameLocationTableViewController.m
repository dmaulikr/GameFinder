//
//  GameLocationTableViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 7/27/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "GameLocationTableViewController.h"
#import <Parse/Parse.h>
#import "UIImageView+WebCache.h"
#import "GameLocationTableViewCell.h"
#import "AppDelegate.h"
#import "PlaceDetailTableViewController.h"
#import "GamePointAnnotation.h"
#import "SVProgressHUD.h"
#import "AddLocationViewController.h"





@interface GameLocationTableViewController ()



// For state restoration
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;


@end

@implementation GameLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self queryParseForGameLocations];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocation:) name:@"updatedLocation" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initialLocation:) name:@"initialLocation" object:nil];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.searchResultsTableView = [[SearchResultsTableViewController alloc]init];
    UIView *headerView = [[UIView alloc]initWithFrame:self.tableView.tableHeaderView.frame];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultsTableView];
    self.searchResultsTableView.tableView.delegate = self;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    headerView = self.searchController.searchBar;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    [self.tableView.tableHeaderView addSubview:headerView];
    
    
    
    
    [self profileImageButton];
    self.centerMapButton.alpha = 0.0f;
    
    self.contractMapButton.layer.cornerRadius = 15.0f;
    self.contractMapButton.layer.borderWidth = 1.0f;
    self.contractMapButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.contractMapButton.clipsToBounds = YES;
    self.contractMapButton.hidden = YES;
    
    self.mapView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.mapView.layer.borderWidth = 2.0f;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshView) name:@"addedLocation" object:nil];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), MKCoordinateSpanMake(0.08, 0.08))];
    
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    
    UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(makeMapFullScreen)];
    hold.numberOfTouchesRequired = 1.0f;
    hold.minimumPressDuration = 0.25f;
    [self.mapView addGestureRecognizer:hold];
    
}
-(void)viewWillAppear:(BOOL)animated{
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    self.searchResultsTableView.tableView.hidden = YES;
    self.searchController.searchBar.placeholder = @"Find a location";
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }
    [UIView animateWithDuration:15.0 animations:^{
        
        self.centerMapButton.alpha = 1.0;
        self.centerMapButton.layer.cornerRadius = 12.0f;
        self.centerMapButton.layer.borderWidth = 1.0f;
        self.centerMapButton.layer.borderColor = [UIColor blackColor].CGColor;
        self.centerMapButton.clipsToBounds = YES;
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gameLocationsArray.count;
    
}

#pragma mark - Table view delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.tableView) {
        //Get the object at the same index in the array
        PFObject *object = [self.gameLocationsArray objectAtIndex:indexPath.row];
        
        //Send that object along to the segue
        [self performSegueWithIdentifier:@"ShowPlaceDetail" sender:object];
        
        
    }else{
        
        NSMutableDictionary *object = [self.searchResultsTableView.searchResults objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"ShowPlaceDetail" sender:object];
        self.searchController.searchBar.text = @"";
        
    }
    
    
    tableView.scrollsToTop = NO;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    GameLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameLocationCell"];
    PFObject *object = [self.gameLocationsArray objectAtIndex:indexPath.row];
    
    PFFile *file = [object[@"pictureArray"]objectAtIndex:0];
    NSURL *url = [NSURL URLWithString:file.url];
    cell.gameImageView.clipsToBounds = YES;
    
    cell.gameImageView.layer.borderWidth = 2.0f;
    cell.gameImageView.layer.cornerRadius = 2.0;
    [cell.gameImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"court"]];
    PFGeoPoint *gameLocation = object[@"location"];
    CLLocationDistance distance = [geoPoint distanceInMilesTo:gameLocation];
    NSString *distanceTo = [NSString stringWithFormat:@"%.02g", distance];
    cell.title.text = [NSString stringWithFormat:@"%@ | %@ mi away", object[@"name"], distanceTo];
    cell.subtitle.text = object[@"address"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSArray *array = object[@"players"];
    NSNumber *number = @(array.count);
    NSString *string = [NSString stringWithFormat:@"%@", number];
    cell.numberOfPlayersLabel.text = string;
    cell.numberOfPlayersLabel.backgroundColor = [UIColor colorWithRed:0.18f green:0.81f blue:0.41f alpha:1.0f];
    cell.numberOfPlayersLabel.clipsToBounds = YES;
    cell.numberOfPlayersLabel.layer.cornerRadius = cell.numberOfPlayersLabel.frame.size.width/2;
    cell.numberOfPlayersLabel.layer.borderColor = [UIColor blackColor].CGColor;
    cell.numberOfPlayersLabel.layer.borderWidth = 1.0f;
    if (array.count >= 1) {
        cell.gameImageView.layer.borderColor = [UIColor colorWithRed:0.18f green:0.81f blue:0.41f alpha:1.0f].CGColor;
        cell.numberOfPlayersLabel.hidden = NO;
    }else{
        cell.gameImageView.layer.borderColor = [UIColor blackColor].CGColor;
        cell.numberOfPlayersLabel.hidden = YES;
    }
    return cell;
}


#pragma mark -Parse Query
-(void)queryParseForGameLocations{
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *currentLocation, NSError *error){
        PFQuery *query = [PFQuery queryWithClassName:@"Games"];
        [query includeKey:@"players"];
        [query whereKey:@"location" nearGeoPoint:currentLocation withinMiles:50.0];
        [query findObjectsInBackgroundWithBlock:^(NSArray *games, NSError *error){
            if (!error) {
                NSLog(@"queryParseForGameLocations");
                for (int x=0; x < games.count; x++) {
                    
                    //Grab the object at index x
                    PFObject *object = [games objectAtIndex:x];
                    if ([[object objectForKey:@"shouldEraseLocation"]isEqualToNumber:@(10)]) {
                        PFObject *deleteObject = object;
                        [deleteObject deleteInBackgroundWithBlock:^(BOOL delete, NSError *error){
                            if (delete) {
                                
                            }
                        }];
                    }
                    //By subclassing MKAnnotationPoint I was able to add an index property
                    GamePointAnnotation *annotation = [[GamePointAnnotation alloc] init];
                    annotation.title = [object objectForKey:@"name"];
                    annotation.subtitle = [object objectForKey:@"address"];
                    PFGeoPoint *geoPoint = [object objectForKey:@"location"];
                    annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                    
                    //Need to store the index of this object from the array so you can send this same object to your next screen
                    annotation.index = x;
                    
                    [self.mapView addAnnotation:annotation];
                    [self performSelectorOnMainThread:@selector(queryParseForPlayerLocation:) withObject:object waitUntilDone:YES];
                }
                
                self.gameLocationsArray = [[NSArray arrayWithArray:games]mutableCopy];
                
                [SVProgressHUD dismiss];
                
                [self.tableView reloadData];
                
            }
        }];
        
        
    }];

}
//Check for location to prevent duplicate locations being added to db
-(void)queryParseForPlayerLocation: (PFObject *)games{
    if (games == nil) {
         self.isNear = NO;
        return;
    }
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    PFGeoPoint *gameGeoPoint = games[@"location"];
    CLLocation *gameLocation = [[CLLocation alloc]initWithLatitude:gameGeoPoint.latitude longitude:gameGeoPoint.longitude];
    CLLocationDistance distance = [currentLocation distanceFromLocation:gameLocation];
    if (distance >= 200 && [[games objectForKey:@"players"]containsObject:[PFUser currentUser]]) {
        NSLog(@"player removed");
        
        [games removeObject:[PFUser currentUser] forKey:@"players"];
        [games saveInBackgroundWithBlock:^(BOOL remove, NSError *error){
            
        }];
        self.isNear = NO;
        
    }else if (distance < 200){
        [games addUniqueObject:[PFUser currentUser] forKey:@"players"];
        [games saveInBackgroundWithBlock:^(BOOL added, NSError *error){
            NSLog(@"player added");
            
        }];
        self.isNear = YES;
        
    }else{
        return;
    }
}



#pragma mark - Navigation

#pragma mark - segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowPlaceDetail"]) {
        [self.searchResultsTableView.searchResults removeAllObjects];
        PFObject *object = (PFObject *)sender;
        
        NSString *name = [object objectForKey:@"name"];
        PFGeoPoint *location = [object objectForKey:@"location"];
        
        PlaceDetailTableViewController *pdc = [segue destinationViewController];
        NSNumber *lightString = object[@"lights"];
        NSNumber *publicString = object[@"openToPublic"];
        NSNumber *coveredString = object[@"covered"];
        NSNumber *outdoorString = object[@"outdoor"];
        pdc.placeObject = object;
        
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        
        self.navigationItem.backBarButtonItem = backButton;
        
        pdc.titleString = name;
        pdc.locationCoordinate = location;
        pdc.lightString = lightString;
        pdc.publicString = publicString;
        pdc.coveredString = coveredString;
        pdc.outdoorString = outdoorString;
        
        
    } else if ([[segue identifier]isEqualToString:@"AddLocation"]){
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
        
        AddLocationViewController *dvc = segue.destinationViewController;
        dvc.placeLocation = currentLocation;
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *place = [placemarks lastObject];
            dvc.address = place.name;
            dvc.city = place.locality;
            dvc.state = place.administrativeArea;
            dvc.zip = place.postalCode;
            
        }];
        

        
        
    }
}

#pragma mark- map annotation view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    
    static NSString *identifier = @"GameLocationCell";
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!pinView)
        {
            
            // If an existing pin view was not available, create one.
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            pinView.canShowCallout = YES;
            pinView.image = [UIImage imageNamed:@"basketball-pin"];
            UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *car = [UIImage imageNamed:@"car"];
            UIImageView *carImage = [[UIImageView alloc]initWithImage:car];
            leftButton.frame = CGRectMake(0,0,28,28);
            leftButton.layer.cornerRadius = 14.0f;
            leftButton.layer.borderColor = [UIColor colorWithRed:0.4f green:0.99607843f blue:0.4f alpha:1].CGColor;
            leftButton.layer.borderWidth = 1.0f;
            leftButton.layer.masksToBounds = YES;
            leftButton.showsTouchWhenHighlighted = YES;
            carImage.frame = CGRectMake(0, 0, leftButton.frame.size.width, leftButton.frame.size.height);
            [leftButton addSubview:carImage];
            pinView.leftCalloutAccessoryView = leftButton;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    //Grab a reference to the annotation making sure to use our subclass so we can get the index property
    GamePointAnnotation *ann = view.annotation;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Open in Maps" message:@"You will be directed from Game Finder." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *cancel) {
        
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        CLLocationCoordinate2D placeLocation = CLLocationCoordinate2DMake(ann.coordinate.latitude, ann.coordinate.longitude);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:placeLocation addressDictionary:nil];
        MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
        item.name = ann.title;
        [item openInMapsWithLaunchOptions:nil];
    }];
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

#pragma mark -profile button
-(void)profileImageButton{
    
    UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    settingsView.layer.cornerRadius = 12.5;
    settingsView.layer.borderColor = [UIColor blackColor].CGColor;
    settingsView.layer.borderWidth = 2.0;
    settingsView.clipsToBounds = YES;
    [settingsView setImage:[UIImage imageNamed:@"profile"] forState:UIControlStateNormal];
    [settingsView addTarget:self action:@selector(settingsClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    
    [self.navigationItem setLeftBarButtonItem:settingsButton];
    
}

-(void)settingsClicked{
    [self performSegueWithIdentifier:@"SettingsClicked" sender:nil];
}


#pragma mark -location manage delegates
-(void)updateLocation:(NSNotification *)notif{
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    [self queryParseForGameLocations];
    [self.tableView reloadData];
    
    
    
}

-(void)initialLocation:(NSNotification *)notif{
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), MKCoordinateSpanMake(0.08, 0.08))];
    //[self queryParseForGameLocations];
    [self.tableView reloadData];
    
    
    
}
#pragma mark - map methods
-(void)makeMapFullScreen{
    self.mapView.clipsToBounds = YES;
    self.upperView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.contractMapButton.hidden = NO;
    
}

-(void)refreshView{
    [self queryParseForGameLocations];
    //[self queryParseForPlayerLocation];
}

#pragma mark - button methods
- (IBAction)handleCenterMapButtonPressed:(id)sender {
    
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}


- (IBAction)handleContractMapButtonPressed:(id)sender {
    
    self.upperView.frame = CGRectMake(0, 0, self.view.frame.size.width, 275);
    self.contractMapButton.hidden = YES;
    
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    
    
    NSString *searchString = searchController.searchBar.text;
    NSArray *searchResults = [self.gameLocationsArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PFObject *evaluatedObject,
                                                                                                                        NSDictionary *bindings) {
        BOOL result = NO;
        
        if ([(NSString *)evaluatedObject[@"name"] containsString:searchString]) {
            result = YES;
        }
        return result;
    }]];
    
    SearchResultsTableViewController *tableController = (SearchResultsTableViewController *)self.searchController.searchResultsController;
    //tableController.searchResults = nil;
    tableController.searchResults = [[NSArray arrayWithArray:searchResults]mutableCopy];
    [tableController.tableView reloadData];
    
    
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [searchBar resignFirstResponder];
}


- (IBAction)handleAddGameButtonPressed:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Location" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *currentLocation = [UIAlertAction actionWithTitle:@"I'm here now" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"AddLocation" sender:nil];
    }];
    UIAlertAction *differentLocation = [UIAlertAction actionWithTitle:@"Search" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"SearchPlacesNotNearUser" sender:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    if (self.isNear == NO) {
        [alert addAction:currentLocation];
    }
    
    [alert addAction:differentLocation];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
