//
//  GameLocationTableViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 7/27/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "GameLocationTableViewController.h"
#import <Parse/Parse.h>
#import "GameLocationTableViewCell.h"
#import "AppDelegate.h"
#import "PlaceDetailViewController.h"
#import "GamePointAnnotation.h"
#import "SVProgressHUD.h"

@interface GameLocationTableViewController ()

@end

@implementation GameLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocation:) name:@"updatedLocation" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initialLocation:) name:@"initialLocation" object:nil];
    
    [self queryParseForGameLocations];
    
    [self profileImageButton];
    self.centerMapButton.alpha = 0.0f;
    
    self.contractMapButton.layer.cornerRadius = 15.0f;
    self.contractMapButton.layer.borderWidth = 1.0f;
    self.contractMapButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.contractMapButton.clipsToBounds = YES;
    self.contractMapButton.hidden = YES;
   
    
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

-(void)viewDidAppear:(BOOL)animated{
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //Get the object at the same index in the array
    NSDictionary *object = [self.gameLocationsArray objectAtIndex:indexPath.row];
    
    //Send that object along to the segue
    [self performSegueWithIdentifier:@"ShowPlaceDetail" sender:object];
    
    tableView.scrollsToTop = NO;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GameLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameLocationCell"];
    
    NSDictionary *dict = [self.gameLocationsArray objectAtIndex:indexPath.row];
    
    cell.title.text = dict[@"name"];
    cell.subtitle.text = dict[@"address"];
    cell.accessoryView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"info"]];
    if (!cell.accessoryView) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.title.font = [UIFont fontWithName:@"optima-bold" size:17.0];
    cell.title.textColor = [UIColor darkGrayColor];
    cell.subtitle.textColor = [UIColor lightGrayColor];
    cell.subtitle.font = [UIFont fontWithName:@"american typewriter" size:10.0];
    return cell;
}

#pragma mark -Parse Query
-(void)queryParseForGameLocations{
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *currentLocation, NSError *error){
        PFQuery *query = [PFQuery queryWithClassName:@"Games"];
        [query whereKey:@"location" nearGeoPoint:currentLocation withinMiles:50.0];
        [query findObjectsInBackgroundWithBlock:^(NSArray *games, NSError *error){
            if (!error) {
                for (int x=0; x < games.count; x++) {
                    
                    //Grab the object at index x
                    NSDictionary *object = [games objectAtIndex:x];
                    
                    //By subclassing MKAnnotationPoint I was able to add an index property
                    GamePointAnnotation *annotation = [[GamePointAnnotation alloc] init];
                    annotation.title = [object objectForKey:@"name"];
                    annotation.subtitle = [object objectForKey:@"address"];
                    PFGeoPoint *geoPoint = [object objectForKey:@"location"];
                    annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                    
                    //Need to store the index of this object from the array so you can send this same object to your next screen
                    annotation.index = x;
                    
                    [self.mapView addAnnotation:annotation];
                    
                }
                
                self.gameLocationsArray = [[NSArray arrayWithArray:games]mutableCopy];
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
                [self performSelectorOnMainThread:@selector(queryParseForPlayerLocation) withObject:nil waitUntilDone:YES];
                
            }
        }];
        
        
    }];
    
    
   
}

#pragma mark - Navigation

#pragma mark - segue methods
-(void)showPlaceDetail:(NSDictionary *)object {
    
    [self performSegueWithIdentifier:@"ShowPlaceDetail" sender:object];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowPlaceDetail"]) {
        NSDictionary *object = (NSDictionary *)sender;

        NSString *name = [object objectForKey:@"name"];
        PFGeoPoint *location = [object objectForKey:@"location"];
        PFFile *file = object[@"locationImage"];
        
        PlaceDetailViewController *pdc = [segue destinationViewController];
        NSNumber *lightString = object[@"lights"];
        NSNumber *publicString = object[@"openToPublic"];
        NSNumber *coveredString = object[@"covered"];
        NSNumber *indoorString = object[@"indoor"];
        pdc.placeObject = object;
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                pdc.placeImageView.image = image;
            
            }
        }];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        pdc.placeImageView.clipsToBounds = YES;
        pdc.titleString = name;
        pdc.locationCoordinate = location;
        pdc.lightString = lightString;
        pdc.publicString = publicString;
        pdc.coveredString = coveredString;
        pdc.indoorString = indoorString;

        
    }
}

#pragma mark- map annotation view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation{
    
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
    
    if  ([[[UIDevice currentDevice] systemVersion] floatValue]< 8.0){
        UIActionSheet *uas = [[UIActionSheet alloc] initWithTitle:@"Open in Maps?" delegate:self cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:nil];
        
        [uas showInView:self.view];
        
    } else {
        
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

//Check for location to prevent duplicate locations being added to db
-(void)queryParseForPlayerLocation {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:appDelegate.locationManager.currentLocation];
    PFQuery *getGames = [PFQuery queryWithClassName:@"Games"];
    [getGames whereKey:@"location" nearGeoPoint:geoPoint withinKilometers:0.15];
    [getGames  getFirstObjectInBackgroundWithBlock:^(PFObject *closestGame, NSError *error) {
        if (closestGame) {
            [closestGame addUniqueObject:[PFUser currentUser] forKey:@"players"];
            [closestGame saveInBackground];
        }if (!closestGame) {
            [self performSelector:@selector(removePlayer) withObject:nil];
        }
        [self performSelector:@selector(enableAddGameButton:) withObject:closestGame];
    }];
    
 
}
-(void)removePlayer{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query whereKey:@"players" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            PFObject *players = [objects lastObject];
            
            [players removeObject:[PFUser currentUser] forKey:@"players"];
            [players saveInBackground];
  
        }
        
        
    }];
}

#pragma mark -location manage delegates
-(void)updateLocation:(NSNotification *)notif{
   
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    [self queryParseForPlayerLocation];
    [self.tableView reloadData];
    
    
    
}

-(void)initialLocation:(NSNotification *)notif{
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), MKCoordinateSpanMake(0.08, 0.08))];
    
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
    [self queryParseForPlayerLocation];
}

#pragma mark - button methods
- (IBAction)handleCenterMapButtonPressed:(id)sender {
   
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}


- (IBAction)handleContractMapButtonPressed:(id)sender {
    
    self.upperView.frame = CGRectMake(0, 0, self.view.frame.size.width, 255);
    self.contractMapButton.hidden = YES;
    
}

- (IBAction)handleFindGameButtonPressed:(id)sender {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    self.definesPresentationContext = YES;
    [UIView animateWithDuration:1.0f animations:^{
        
        self.navigationItem.titleView = self.searchController.searchBar;
        [self.navigationItem.titleView becomeFirstResponder];
    }];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar removeFromSuperview];
}
-(void)enableAddGameButton:(NSDictionary *)closestGame{
    if (closestGame) {
        self.addGamesButton.enabled = NO;
    }else{
        self.addGamesButton.enabled = YES;
    }
}
- (IBAction)handleAddGameButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"AddLocation" sender:nil];
}

@end
