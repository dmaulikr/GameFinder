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


//Cllocation distance


@interface MainViewController ()



@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //Google Drive presentations/Lucid chart
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocationRange:) name:@"updatedLocation" object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.gamesTableView addSubview:refreshControl];
//    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
//        if (!error) {
//
//            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
//            [[PFUser currentUser] saveInBackground];
//            
//
//            [self.mapView setDelegate:self];
//            self.mapView.showsUserLocation = YES;
//            
//        }
//    }];
  
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self disableAddButton];
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

- (void)refresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
}

#pragma -mark parse queries
-(void) retrieveFromParse {
    
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    //NSLog(@"userGeoPoint is %@", userGeoPoint);
    
    PFQuery *retrieveGames = [PFQuery queryWithClassName:@"Games"];
    [retrieveGames whereKey:@"location" nearGeoPoint:userGeoPoint withinMiles:50];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [SVProgressHUD showImage:[UIImage imageNamed:@"bball2"] status:@"loading" maskType:SVProgressHUDMaskTypeGradient];
        
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
        [self.gamesTableView reloadData];
        
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


-(void)disableAddButton {
    
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


#pragma -mark TableView datasource methods



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //returns the number of sections you need.
    if (self.gameTimesArray) {
        
        self.gamesTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"No data is currently available. Please pull down to refresh.";
        messageLabel.textColor = [UIColor orangeColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        
        self.gamesTableView.backgroundView = messageLabel;
        self.gamesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //how many rows are in each of the above sections (Total number of cells needing to be displayed).
    return self.gameTimesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 70;
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

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    return 0;
}

#pragma -mark TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    //Get the object at the same index in the array
    NSDictionary *object = [self.gameTimesArray objectAtIndex:indexPath.row];
    
    //Send that object along to the segue
    [self performSegueWithIdentifier:@"showPlaceDetail" sender:object];
    
    tableView.scrollsToTop = NO;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma -mark map annotation view
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
            
            [self okayButton];
        }];
        
        
        [alert addAction:cancel];
        [alert addAction:yes];
        
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    
}
- (void)okayButton {
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    NSLog(@"currentLocation = %@", currentLocation);
    
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *place = [placemarks lastObject];
        
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            
            PFObject *postObject = [PFObject objectWithClassName:@"Games"];
            
            postObject[@"name"] = place.subLocality;
            postObject[@"location"] = geoPoint;
            postObject[@"address"] = place.name;
            postObject[@"city"] = place.locality;
            postObject[@"state"] = place.administrativeArea;
            postObject[@"zip"] = place.postalCode;
            
            //NSLog(@"address dictionary is %@", place.addressDictionary);
            
            [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {  // Failed to save, show an alert view with the error message
                    
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to save location" message:@"Location already exists. Check in instead." preferredStyle:UIAlertControllerStyleAlert];
                    
                    
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        NSLog(@"AlertView Cancelled");
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    return;
                }
                if (succeeded) {  // Successfully saved, post a notification to tell other view controllers
                    [SVProgressHUD showSuccessWithStatus:@"Saved!"];
                    
                    
                    
                } else {
                    NSLog(@"Failed to save.");
                }
                
                
            }];
            
            
        }];
        
    }];
    
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    [self retrieveFromParse];
    
}
-(void)updateRegion:(CLLocationCoordinate2D) location{
    
    self.mapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D initialLocationFocus = location;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(.06, .06);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(initialLocationFocus, span);
    
    [self.mapView setRegion:region animated:YES];
    
    
    
}



-(void)updateLocationRange:(NSNotification *)notif {
    
    CLLocation *newLocation = notif.object;
    
    [self updateRegion:newLocation.coordinate];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
