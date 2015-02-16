//
//  MainViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 2/9/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "MainViewController.h"
#import "PlaceDetailViewController.h"



@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Look at SV progress hud
    //Google Drive presentations/Lucid chart
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
//    tap.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:tap];
    
    self.addLocationView.hidden = YES;
        
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
                        
            self.mapView.layer.cornerRadius = 5.0;
            [self.mapView setDelegate:self];
            self.mapView.showsUserLocation = YES;
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.08, 0.08))];

        }
    }];
  
    dispatch_async(dispatch_get_main_queue(), ^{
        [self retrieveFromParse];
    });
}

-(void)viewDidAppear:(BOOL)animated{
    
    
    
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"LogInScreen"];
    
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        // go straight to the app!
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
    }
    
}

#pragma -mark parse queries
-(void) retrieveFromParse {
    
    PFQuery *retrieveGames = [PFQuery queryWithClassName:@"Games"];
    [retrieveGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (id object in objects) {
                
                
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.title = [object objectForKey:@"name"];
                annotation.subtitle = [object objectForKey:@"address"];
                PFGeoPoint *geoPoint = [object objectForKey:@"location"];
                annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
                
                
                
                [self.mapView addAnnotation:annotation];
                [SVProgressHUD show];
            }
            self.gameTimesArray = [[NSArray alloc]initWithArray:objects];
        }
        [self.gamesTableView reloadData];
        [SVProgressHUD dismiss];
    }];
    
}





#pragma -mark TableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //returns the number of sections you need.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //how many rows are in each of the above sections (Total number of cells needing to be displayed).
    return self.gameTimesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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

#pragma -mark TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell tapped");
    
    [self performSegueWithIdentifier:@"showPlaceDetail" sender:nil];
    
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
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"detailPage"];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}



-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
   
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    }




/*-(void)updateRegion:(CLLocationCoordinate2D) location{
    
    self.mapView.showsUserLocation = YES;
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    CLLocationCoordinate2D initialLocationFocus = location;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(.08,.08);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(initialLocationFocus, span);
    
    [self.mapView setRegion:region animated:YES];
    
    
    
}

-(void)updateLocationRange:(NSNotification *)notif {
    
    CLLocation *newLocation = notif.object;
    
    //[self getPlacesFromGoogleatLocation:newLocation.coordinate];
    
    [self updateRegion:newLocation.coordinate];
    
}
*/

- (IBAction)logOut:(id)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogInScreen"];
    
    [PFUser logOut];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (IBAction)zoomButton:(id)sender {
    
    [UIView animateWithDuration:.5 animations:^{
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
    }];
}

- (IBAction)addLocation:(id)sender {
    self.addLocationView.hidden = NO;
}
- (IBAction)okayButton:(id)sender {
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
    
    PFGeoPoint *currentPoint =
    [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                           longitude:currentCoordinate.longitude];
    
    PFObject *postObject = [PFObject objectWithClassName:@"Games"];
    postObject[@"name"] = self.locationTextField.text;
    postObject[@"location"] = currentPoint;
    
    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {  // Failed to save, show an alert view with the error message
            
            return;
        }
        if (succeeded) {  // Successfully saved, post a notification to tell other view controllers
            NSLog(@"Yeah!");
            
            self.addLocationView.hidden = YES;
            [self.gamesTableView reloadData];
            [self hideKeyboard];
            
        } else {
            NSLog(@"Failed to save.");
        }
    
  
    }];
}

-(void)hideKeyboard{
    [self.locationTextField resignFirstResponder];
}



- (IBAction)cancelButton:(id)sender {
    [self hideKeyboard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
