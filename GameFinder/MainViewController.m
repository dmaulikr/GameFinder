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
#import "AppDelegate.h"







@interface MainViewController ()



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        //NSLog(@"user: %@", [PFUser currentUser]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived) name:@"localNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocation:) name:@"updatedLocation" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(initialLocation:) name:@"initialLocation" object:nil];
    
    [self userImage];
    
    [SVProgressHUD showImage:[UIImage imageNamed:@"bball2"] status:@"loading"];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), MKCoordinateSpanMake(0.08, 0.08))];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired = 1;
    [self.mapView setDelegate:self];
    self.mapView.showsUserLocation = YES;
    self.navigationTitle.title = [NSString stringWithFormat:@"Hey, %@!", [PFUser currentUser].username];
    

    
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
- (IBAction)profileButton:(id)sender {
   
}

-(void)pushNotificationReceived{
    
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Still Playing" message:@"Are you still hoopin?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"stillPlaying" object:nil];
    }];
    
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notPlaying" object:nil];
    }];
    
    [alert addAction:no];
    [alert addAction:yes];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}



#pragma mark- parse queries
-(void) retrieveFromParse {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:currentLocation];
    //NSLog(@"userGeoPoint is %@", userGeoPoint);
    [self.mapView removeAnnotations:self.mapView.annotations];
    PFQuery *retrieveGames = [PFQuery queryWithClassName:@"Games"];
    [retrieveGames whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:50];
    
    
    
    
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.gamesTableView reloadData];
        });
        
    }];
    
    
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
        
        

        PFGeoPoint *location = [object objectForKey:@"location"];
        
                
        
        PlaceDetailViewController *pdc = [segue destinationViewController];
        
        pdc.title = name;
        
        pdc.address = address;
        
        pdc.locationStateString = state;
        
        pdc.locationCityString = [city stringByAppendingString:@","];
        
        pdc.locationNameString = name;
        
        pdc.locationZipString = zip;
        
        pdc.locationTypeString = type;
        
        pdc.locationCoordinate = location;
        
        
       
        
    }
}

#pragma mark- Location manager delegate methods

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    [self retrieveFromParse];
    
}

-(void)initialLocation:(NSNotification *)notif{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude), MKCoordinateSpanMake(0.08, 0.08))];
    
    
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
            pinView.canShowCallout = YES;
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            pinView.rightCalloutAccessoryView = rightButton;
            pinView.image = [UIImage imageNamed:@"basketball-pin"];
            
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


- (IBAction)zoomButton:(id)sender {
    
    [UIView animateWithDuration:.2 animations:^{
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
    }];
    [self disableAddLocationButton];
}

- (IBAction)addLocation:(id)sender {
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        
        UIAlertView *uav = [[UIAlertView alloc] initWithTitle:@"Alert with iOS 7" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        [uav show];
        
        
    } else {
               
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Do you want to add this location?"];
        
        [attributedTitle addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15.0] range:NSMakeRange(0, attributedTitle.length)];
        [attributedTitle addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:.27 green:.27 blue:.27 alpha:1.0] range:NSMakeRange(0, attributedTitle.length)];
        
        [alert setValue:attributedTitle forKey:@"attributedTitle"];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
            
            
        }];
        
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *yes) {
            
            UIAlertController *addLocationNameandType = [UIAlertController alertControllerWithTitle:@"Name and Type" message:@"Please fill out a name and a type of place." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            
            UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add Location" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                UITextField *name = addLocationNameandType.textFields.firstObject;
                UITextField *type = addLocationNameandType.textFields.lastObject;
                self.locationName = name.text;
                self.locationType = type.text;
                if ((name.text.length >= 3 && [type.text isEqualToString:@"Park"]) || [type.text isEqualToString:@"School"] || [type.text isEqualToString:@"Fitness Center"] || [type.text isEqualToString:@"Other"]) {
                    [self postToParse];
                    [self disableAddLocationButton];
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please enter all fields" message:@"Place type must be School, Park, Fitness Center or Other " preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        [self presentViewController:addLocationNameandType animated:YES completion:nil];
                    }];
                    
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            }];
            
            
            [addLocationNameandType addAction:cancel];
            [addLocationNameandType addAction:add];
            
            [addLocationNameandType addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.textAlignment = NSTextAlignmentCenter;
                textField.placeholder = @"Name this location";
                textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                
            }];
            
            
            [addLocationNameandType addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.textAlignment = NSTextAlignmentCenter;
                textField.placeholder = @"Park, School, Fitness Center";
                textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
            }];
            [self presentViewController:addLocationNameandType animated:YES completion:nil];
            
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
            
            
            postObject[@"name"] = self.locationName;
            postObject[@"location"] = geoPoint;
            postObject[@"address"] = place.name;
            postObject[@"city"] = place.locality;
            postObject[@"state"] = place.administrativeArea;
            postObject[@"zip"] = place.postalCode;
            postObject[@"type"] = self.locationType;
            
            
            
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
                    [self disableAddLocationButton];
                    
                    
                    
                } else {
                    NSLog(@"Failed to save.");
                }
                
                
            }];
            
            
        }];
        
    }];
    
}


-(void)disableAddLocationButton {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:appDelegate.locationManager.currentLocation];
        PFQuery *getGames = [PFQuery queryWithClassName:@"Games"];
        [getGames whereKey:@"location" nearGeoPoint:geoPoint withinMiles:0.09];
        [getGames  findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count >= 1) {
                
                self.addGamesButton.enabled = NO;
                
            }if (objects.count < 1) {
                self.addGamesButton.enabled = YES;
            }
            
       
        
        
    }];
    
    
    
}


-(void)hideKeyboard{
    
    
}

-(void)userImage{
    
    
    NSString *facebookImageUrl = [[PFUser currentUser]objectForKey:@"facebookImageUrl"];
    NSURL *url = [NSURL URLWithString:facebookImageUrl];
    
    UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    settingsView.layer.cornerRadius = 12.5;
    settingsView.layer.borderColor = [UIColor blackColor].CGColor;
    settingsView.layer.borderWidth = 1.0;
    settingsView.clipsToBounds = YES;
    

    [settingsView addTarget:self action:@selector(settingsClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [settingsView sd_setBackgroundImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"profile"]];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    
    [self.navigationItem setLeftBarButtonItem:settingsButton];
}

#pragma mark textfield delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hideKeyboard];
    return true;
}

-(void)updateLocation:(NSNotification *)notif{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    [self disableAddLocationButton];
}

-(void)settingsClicked{
    [self performSegueWithIdentifier:@"settingsClicked" sender:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
