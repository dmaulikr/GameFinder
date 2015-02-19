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



@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //Google Drive presentations/Lucid chart
  

    
    

    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            
            
            [self.mapView setDelegate:self];
            self.mapView.showsUserLocation = YES;
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.08, 0.08))];
            
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self retrieveFromParse];
        //[self getPlaceDetail];
        
    });
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

#pragma -mark parse queries
-(void) retrieveFromParse {
    
    
    PFQuery *retrieveGames = [PFQuery queryWithClassName:@"Games"];
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //This was originally in your array loop, it would show, add the annotation, then dismiss. It would do this for every loop. I moved it here to the beginning of where the whole operation begins.
    [SVProgressHUD showImage:[UIImage imageNamed:@"background-1"] status:@"loading"];

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
                NSLog(@"%@", object);
                
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
        
        NSLog(@"dict = %@", object);
        
        NSString *name = [object objectForKey:@"name"];
        
        NSString *address = [object objectForKey:@"address"];
        
        NSString *city = [object objectForKey:@"city"];
        
        NSString *state = [object objectForKey:@"state"];
        
        NSNumber *zip = [object objectForKey:@"zip"];
        
        //CLLocationCoordinate2D *location = [object objectForKey:@""];
        
        PlaceDetailViewController *pdc = [segue destinationViewController];
        
        pdc.title = name;
        
        pdc.address = address;
        
        pdc.locationStateString = state;
        
        pdc.locationCityString = [city stringByAppendingString:@","];
        
        pdc.locationNameString = name;
        
        pdc.locationZipString = zip;
        
        //pdc.locationCoordinate = location;
        
    }
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

#pragma -mark TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell tapped");
    
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
    
    [UIView animateWithDuration:.5 animations:^{
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
            NSLog(@"Go Pushed");
            [self okayButton];
        }];
        
        
        [alert addAction:cancel];
        [alert addAction:yes];
        
        [self presentViewController:alert animated:YES completion:nil];
    };
    
    
}
- (void)okayButton {
    CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *place = [placemarks lastObject];
        NSLog(@"%@", place.name);
        
        PFGeoPoint *currentPoint =
        [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                               longitude:currentCoordinate.longitude];
        
        PFObject *postObject = [PFObject objectWithClassName:@"Games"];
        postObject[@"name"] = place.subLocality;
        postObject[@"location"] = currentPoint;
        postObject[@"address"] = place.name;
        postObject[@"city"] = place.locality;
        postObject[@"state"] = place.administrativeArea;
        postObject[@"zip"] = place.postalCode;
        
        [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {  // Failed to save, show an alert view with the error message
                
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to save location" message:@"Must be connected to a network" preferredStyle:UIAlertControllerStyleAlert];
                
                
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSLog(@"AlertView Cancelled");
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
                
                
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
                
                return;
            }
            if (succeeded) {  // Successfully saved, post a notification to tell other view controllers
                [SVProgressHUD showSuccessWithStatus:@"Saved!"];
                [self retrieveFromParse];
                [self hideKeyboard];
                
            } else {
                NSLog(@"Failed to save.");
            }
            
            
        }];
        
    }];
    
    
}

-(void)hideKeyboard{
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //timer
    //invalidate timer
    //refresh after timer objects from parse
    //map bounds
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
