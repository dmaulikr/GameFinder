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
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocationRange:) name:@"updatedLocation" object:nil];
    
    self.mapView.layer.cornerRadius = 5.0;
    [self.mapView setDelegate:self];
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self getPlacesFromGoogleatLocation:self.mapView.centerCoordinate];
    });
    //[self performSelector:@selector(getPlacesFromGoogleatLocation:)];
 
}




- (IBAction)logOut:(id)sender {
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogInScreen"];
    
    [PFUser logOut];
    [self presentViewController:vc animated:YES completion:^{
        
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
    
    static NSString *CellIdentifier = @"TimeCell";
    
    CustomTableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *tempObject = [self.gameTimesArray objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    
    
   
    cell.title.text = [tempObject objectForKey:@"name"];
    cell.subTitle.text = [tempObject objectForKey:@"vicinity"];
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
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma -mark google places api
-(void)getPlacesFromGoogleatLocation:(CLLocationCoordinate2D) currentLocation{
    
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=25000&types=gym|school|park&key=AIzaSyA0UHt_IADIiohNKBl2FujWlUkKNprZZFY", currentLocation.latitude, currentLocation.longitude];
    
    
    NSURL  *url = [NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSMutableDictionary *allData = [NSJSONSerialization
                                        JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        NSArray *results = [allData objectForKey:@"results"];
        
        
        //NSLog(@"Results are: %@", results);
        
        NSMutableArray *placesFound = [NSMutableArray array];
        
        if (results.count >= 1){
            
            for (id object in results) {
                
                NSDictionary *places = object;
                
                NSString *name = [places objectForKey:@"name"];
                
                NSString *googlePlacesID = [places objectForKey:@"place_id"];
                
                NSDictionary *geometry = [places objectForKey:@"geometry"];
                
                NSDictionary *location = [geometry objectForKey:@"location"];
                
                
                NSNumber *lat = [location objectForKey:@"lat"];
                
                NSNumber *lng = [location objectForKey:@"lng"];
                
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
                
                self.gameTimesArray = [[NSArray alloc]initWithArray:results];
                
                [self.gamesTableView reloadData];
                    
                MapViewAnnotation *annotation = [[MapViewAnnotation alloc]initWithTitle:name andCoordinate:latlng andGooglePlacesID:googlePlacesID];
                
                    [placesFound addObject:annotation];
            
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self displayNewAnnotations:placesFound];
            });
            
            //[self performSelectorOnMainThread:@selector(displayNewAnnotations:) withObject:placesFound waitUntilDone:NO];
        }
        
    }] resume];
    
}
#pragma -mark map annotation view
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    
    
    if ([annotation isKindOfClass:[MapViewAnnotation class]]) {
        
        MKAnnotationView *aView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        
        
        if (aView == nil) {
            
           
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            aView.image = [UIImage imageNamed:@"basketball"];
            aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
            aView.canShowCallout = YES;
            aView.annotation = annotation;
        } else {
            aView.annotation = annotation;
        }
        
        return aView;
        
    } else {
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    MapViewAnnotation *annotation = view.annotation;
    
    [self getPlaceDetailWithID:annotation.googlePlacesID];
    
}

-(void)getPlaceDetailWithID:(NSString *)placeID {
    
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/nearbyplace/details/json?placeid=%@&key=AIzaSyDfFhd0Uh5fvOw1daGh9zbVPbAVirn2qDU", placeID];
    NSURL  *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSMutableDictionary *allData = [NSJSONSerialization
                                        JSONObjectWithData:data
                                        options:NSJSONReadingMutableContainers
                                        error:&jsonError];
        
        NSDictionary *result = [allData objectForKey:@"result"];
        NSLog(@"detail result is %@", result);
        [self performSelectorOnMainThread:@selector(showPlaceDetail:) withObject:result waitUntilDone:NO];
        
        
        
    }] resume];
    
}

-(void)showPlaceDetail:(NSDictionary *)result {
    
    PlaceDetailViewController *dvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"detailPage"];
    
    NSString *name = [result objectForKey:@"name"];
    
    dvc.title = name;
    
    [self.navigationController pushViewController:dvc animated:YES];
    //[self performSegueWithIdentifier:@"showPlaceDetail" sender:result];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showPlaceDetail"]) {
        
        NSDictionary *result = (NSDictionary *)sender;
      
        NSString *name = [result objectForKey:@"name"];
        
        PlaceDetailViewController *pdc = segue.destinationViewController;
        
        pdc.title = name;
    }
}

-(void)displayNewAnnotations:(NSMutableArray *)places {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView addAnnotations:places];
    
}




-(void)updateRegion:(CLLocationCoordinate2D) location{
    
    self.mapView.showsUserLocation = YES;
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    
    CLLocationCoordinate2D initialLocationFocus = location;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(.08,.08);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(initialLocationFocus, span);
    
    [self.mapView setRegion:region animated:YES];
    
    
    
}

-(void)updateLocationRange:(NSNotification *)notif {
    
    CLLocation *newLocation = notif.object;
    
    [self getPlacesFromGoogleatLocation:newLocation.coordinate];
    
    [self updateRegion:newLocation.coordinate];
    
}

- (IBAction)zoomButton:(id)sender {
    
    
    [UIView animateWithDuration:.5 animations:^{
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude);
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
