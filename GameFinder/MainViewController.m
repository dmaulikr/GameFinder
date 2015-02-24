//
//  MainViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 2/9/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "MainViewController.h"
#import "PlaceDetailViewController.h"
#import "GamePointAnnotation.h"
#import "CreateGameViewController.h"


//Cllocation distance


@interface MainViewController ()



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.pickerArray = @[@"",@"1-5",@"6-10",@"11-15", @"More than 15"];
    
    self.placeTypeArray = @[@"",@"School", @"Fitness Center", @"Park", @"Other"];
    
    self.locationNameView.hidden = YES;
    self.locationNameView.layer.cornerRadius = 5;
    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 800;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired = 1;
    [self.locationNameView addGestureRecognizer:tap];
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
    
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude), MKCoordinateSpanMake(0.08, 0.08))];
    [self.locationManager startUpdatingLocation];
    
    
    
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self disableAddLocationButton];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"LogInScreen"];
    
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser ) {
        // go straight to the app!
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
    }
    
    
}
#pragma mark- uipicker control delegates

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([pickerView isEqual: self.pickerControl]){
        return [self.pickerArray count];
    }else if([pickerView isEqual:self.typePicker]){
        return [self.placeTypeArray count];
    }else return 0;
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if([pickerView isEqual: self.pickerControl]){
        return [self.pickerArray objectAtIndex:row];
    }else if([pickerView isEqual:self.typePicker]){
        return [self.placeTypeArray objectAtIndex:row];
    }else return 0;
    
    
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    //query parse for game and then add nuber to players array
    if([pickerView isEqual: self.pickerControl]){
        [self.numberOfPlayers setText:[self.pickerArray objectAtIndex:row]];
    }else if([pickerView isEqual:self.typePicker]){
        [self.typeOfLocation setText:[self.placeTypeArray objectAtIndex:row]];
    }else return ;
    
    
}




#pragma mark- parse queries
-(void) retrieveFromParse {
    
    
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    //NSLog(@"userGeoPoint is %@", userGeoPoint);
    
    PFQuery *retrieveGames = [PFQuery queryWithClassName:@"Games"];
    [retrieveGames whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:50];
    [SVProgressHUD showImage:[UIImage imageNamed:@"bball2"] status:@"loading"];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    
    [retrieveGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            //Changed the way you interated thru your array
            for (int x=0; x < objects.count; x++) {
                
                //Grab the object at index x
                NSDictionary *object = [objects objectAtIndex:x];
                
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
            self.gameTimesArray = [[NSArray alloc]initWithArray:objects];
        } else {
            //Just added this to show an error popup if you got back an error
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }
        [self performSelectorOnMainThread:@selector(reloadData:) withObject:nil waitUntilDone:NO];
        
    }];
    
    
}

-(void)reloadData:(NSString *)string{
    [self.gamesTableView reloadData];
}

-(void)getPlaceDetail{
    PFQuery *retrieveGames = [PFQuery queryWithClassName:@"Games"];
    [retrieveGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            for (id object in objects) {
                
                [object objectForKey:@"objectId"];
                
                [self performSelectorOnMainThread:@selector(showPlaceDetail:) withObject:object waitUntilDone:YES];
            }
        }
        
        
        
    }];
    
}

#pragma mark - segue methods
-(void)showPlaceDetail:(NSDictionary *)object {
    
    [self performSegueWithIdentifier:@"showPlaceDetail" sender:object];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"showPlaceDetail"]) {
        NSDictionary *object = (NSDictionary *)sender;
        
        
        
        NSString *name = [object objectForKey:@"name"];
        
        NSString *address = [object objectForKey:@"address"];
        
        NSString *city = [object objectForKey:@"city"];
        
        NSString *state = [object objectForKey:@"state"];
        
        NSString *zip = [object objectForKey:@"zip"];
        
        NSString *type = [object objectForKey:@"type"];
        
        NSString *players = [object objectForKey:@"players"];
        
        PFGeoPoint *location = [object objectForKey:@"location"];
        
        NSDate *createdAt = [object objectForKey:@"createdAt"];
        
        
        PlaceDetailViewController *pdc = [segue destinationViewController];
        
        pdc.title = name;
        
        pdc.address = address;
        
        pdc.locationStateString = state;
        
        pdc.locationCityString = [city stringByAppendingString:@","];
        
        pdc.locationNameString = name;
        
        pdc.locationZipString = zip;
        
        pdc.locationTypeString = type;
        
        pdc.locationCoordinate = location;
        
        
        
        //pdc.playersCell.title.text = players;
        
    }
}

#pragma mark- Location manager delegate methods

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    [self retrieveFromParse];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"locations are %@", [locations lastObject]);
    self.currentLocation = [locations lastObject];
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    [self disableAddLocationButton];
    
}


#pragma mark- map annotation view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation{
    
    static NSString *identifier = @"MyLocation";
    
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
            //pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            pinView.rightCalloutAccessoryView = rightButton;
            pinView.image = [UIImage imageNamed:@"basketball"];
            
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
    
    //Get the object from the array that matches the stored index
    NSDictionary *object = [self.gameTimesArray objectAtIndex:ann.index];
    
    //Pass the object
    [self performSegueWithIdentifier:@"showPlaceDetail" sender:object];
}

#pragma mark- TableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //returns the number of sections you need.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //how many rows are in each of the above sections (Total number of cells needing to be displayed).
    return self.gameTimesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //The actual code to return each cell, configured with the data you want to display.
    
    static NSString *CellIdentifier = @"LocationCell";
    
    CustomTableViewCell *cell = [tableView
                                 dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *tempObject = [self.gameTimesArray objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
        
    }
    
    
    
    cell.title.text = [tempObject objectForKey:@"name"];
    cell.subTitle.text = [tempObject objectForKey:@"address"];
    cell.title.textAlignment = NSTextAlignmentCenter;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.title.font = [UIFont fontWithName:@"optima-bold" size:17.0];
    cell.title.textColor = [UIColor darkGrayColor];
    cell.subTitle.textColor = [UIColor lightGrayColor];
    cell.subTitle.font = [UIFont fontWithName:@"american typewriter" size:10.0];
    
    
    return cell;
    
    
}



#pragma mark- TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //Get the object at the same index in the array
    NSDictionary *object = [self.gameTimesArray objectAtIndex:indexPath.row];
    
    //Send that object along to the segue
    [self performSegueWithIdentifier:@"showPlaceDetail" sender:object];
    
    tableView.scrollsToTop = NO;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark- buttons

- (IBAction)logOut:(id)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogInScreen"];
    
    [PFUser logOut];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (IBAction)zoomButton:(id)sender {
    
    [UIView animateWithDuration:.2 animations:^{
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
    }];
    
}
- (IBAction)xButton:(id)sender {
    
    self.locationNameView.hidden = YES;
}

- (IBAction)addLocation:(id)sender {
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        
        UIAlertView *uav = [[UIAlertView alloc] initWithTitle:@"Alert with iOS 7" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        [uav show];
        
        
    } else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Do you want to add this location?" message:@" " preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"AlertView Cancelled");
            
            
        }];
        
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *yes) {
            
            self.locationNameView.hidden = NO;
            self.locationNameView.backgroundColor = [UIColor colorWithWhite:1 alpha:.8];
            
        }];
        
        
        [alert addAction:cancel];
        [alert addAction:yes];
        
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    
}
- (void)postToParse {
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    NSLog(@"currentLocation = %@", currentLocation);
    
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *place = [placemarks lastObject];
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            
            PFObject *postObject = [PFObject objectWithClassName:@"Games"];
            
            postObject[@"name"] = self.locationName.text;
            postObject[@"location"] = geoPoint;
            postObject[@"address"] = place.name;
            postObject[@"city"] = place.locality;
            postObject[@"state"] = place.administrativeArea;
            postObject[@"zip"] = place.postalCode;
            postObject[@"type"] = self.typeOfLocation.text;
            postObject[@"players"] = self.numberOfPlayers.text;
            
            
            
            [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {  // Failed to save, show an alert view with the error message
                    
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to save location" message:@"Location already exists. Check in instead." preferredStyle:UIAlertControllerStyleAlert];
                    
                    
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        NSLog(@"AlertView Cancelled");
                        
                    }];
                    
                    
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    
                    return;
                }
                if (succeeded) {  // Successfully saved, post a notification to tell other view controllers
                    
                    [SVProgressHUD showSuccessWithStatus:@"Saved!"];
                    [self retrieveFromParse];
                    
                    
                    
                } else {
                    NSLog(@"Failed to save.");
                }
                
                
            }];
            
            
        }];
        
    }];
    
}


-(void)disableAddLocationButton {
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        PFQuery *getGames = [PFQuery queryWithClassName:@"Games"];
        [getGames whereKey:@"location" nearGeoPoint:geoPoint withinMiles:0.05];
        [getGames  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count >= 1) {
                
                self.addGamesButton.enabled = NO;
                
            }if (objects.count < 1) {
                self.addGamesButton.enabled = YES;
            }
            
        }];
        
        
    }];
    
    
    
}
- (IBAction)submitButton:(id)sender {
    if (self.locationName.text.length >2 && self.typeOfLocation.text.length >1 && self.numberOfPlayers.text.length >1) {
        [self postToParse];
        [self disableAddLocationButton];
        self.locationNameView.hidden = YES;
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please fill out all fields." message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *ok) {
        }];
        
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}
- (IBAction)yesButton:(id)sender {
    [self performSegueWithIdentifier:@"playingNow" sender:nil];
}

-(void)hideKeyboard{
    [self.locationName resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
