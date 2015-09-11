//
//  PlaceSearchTableViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 9/10/15.
//  Copyright © 2015 Nick Reeder. All rights reserved.
//

#import "PlaceSearchTableViewController.h"
#import <MapKit/MapKit.h>
#import "AddLocationViewController.h"
#import <Parse/Parse.h>
#import <AddressBookUI/AddressBookUI.h>

static NSString *kCellIdentifier = @"PlacesCell";
@interface PlaceSearchTableViewController ()

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D userCoordinate;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation PlaceSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.locationManager = [[CLLocationManager alloc] init];
    
    self.searchBar.placeholder = @"Find your court";
    self.searchBar.tintColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.places.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    MKMapItem *mapItem = [self.places objectAtIndex:indexPath.row];
    
    cell.textLabel.text = mapItem.name;
    NSDictionary *mapItemDict = mapItem.placemark.addressDictionary;
    cell.detailTextLabel.text = mapItemDict[@"Street"];
    
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"AddSearchedLocation" sender:[self.places objectAtIndex:indexPath.row]];
}
#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // If the text changed, reset the tableview if it wasn't empty.
    if (self.places.count != 0) {
        
        // Set the list of places to be empty.
        self.places = @[];
        // Reload the tableview.
        [self.tableView reloadData];
        
    }
}

- (void)startSearch:(NSString *)searchString {
    if (self.localSearch.searching)
    {
        [self.localSearch cancel];
    }
    
    // Confine the map search area to the user's current location.
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = self.userCoordinate.latitude;
    newRegion.center.longitude = self.userCoordinate.longitude;
    
    // Setup the area spanned by the map region:
    // We use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level).
    //      The numbers used here correspond to a roughly 8 mi
    //      diameter area.
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
        if (error != nil) {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places"
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            
            self.places = [response mapItems];
            
            // Used for later when setting the map's region in "prepareForSegue".
            self.boundingRegion = response.boundingRegion;
            
            [self.tableView reloadData];
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (self.localSearch != nil) {
        self.localSearch = nil;
    }
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    [self.localSearch startWithCompletionHandler:completionHandler];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    // Check if location services are available
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"%s: location services are not available.", __PRETTY_FUNCTION__);
        
        // Display alert to the user.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
                                                                       message:@"Location services are not enabled on this device. Please enable location services in settings."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}]; // Do nothing action to dismiss the alert.
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    // Request "when in use" location service authorization.
    // If authorization has been denied previously, we can display an alert if the user has denied location services previously.
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"%s: location services authorization was previously denied by the user.", __PRETTY_FUNCTION__);
        
        // Display alert to the user.
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services"
                                                                       message:@"Location services were previously denied by the user. Please enable location services for this app in settings."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}]; // Do nothing action to dismiss the alert.
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    // Start updating locations.
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    // When a location is delivered to the location manager delegate, the search will actually take place. See the -locationManager:didUpdateLocations: method.
}


#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    // Remember for later the user's current location.
    CLLocation *userLocation = locations.lastObject;
    self.userCoordinate = userLocation.coordinate;
    
    [manager stopUpdatingLocation]; // We only want one update.
    
    manager.delegate = nil;         // We might be called again here, even though we
    // called "stopUpdatingLocation", so remove us as the delegate to be sure.
    
    // We have a location now, so start the search.
    [self startSearch:self.searchBar.text];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // report any errors returned back from Location Services
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // Get the single item.
    NSIndexPath *selectedItemPath = [self.tableView indexPathForSelectedRow];
    MKMapItem *mapItem = self.places[selectedItemPath.row];
   
    NSDictionary *mapItemDict = mapItem.placemark.addressDictionary;
    

    AddLocationViewController *dvc = segue.destinationViewController;
    dvc.name = mapItemDict[@"Name"];
    dvc.address = mapItemDict[@"Street"];
    dvc.placeLocation = mapItem.placemark.location;
    dvc.city = mapItemDict[@"City"];
    dvc.state = mapItemDict[@"State"];
    dvc.zip = mapItemDict[@"ZIP"];
    dvc.takePictureButton.hidden = YES;
}

@end
