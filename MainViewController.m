//
//  MainViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 2/9/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.mapView.layer.cornerRadius = 5.0;
    [self.mapView setDelegate:self];
    
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
//            MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
//            annotation.coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
//            annotation.title = @"WTF?!";
//            
//            [self.mapView addAnnotation:annotation];
            
            
            
            self.mapView.showsUserLocation = YES;
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            [self.mapView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude), MKCoordinateSpanMake(0.01, 0.01))];
            
            
        }
    }];
    
    [self performSelector:@selector(retrieveFromParse)];
    
}


#pragma -mark parse queries
-(void) retrieveFromParse {
    
    PFQuery *retrieveGames = [PFQuery queryWithClassName:@"Games"];
    [retrieveGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            self.gameTimesArray = [[NSArray alloc]initWithArray:objects];
        }
        [self.gamesTableView reloadData];
    }];
    
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
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //The actual code to return each cell, configured with the data you want to display.
    
    static NSString *CellIdentifier = @"TimeCell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [self.gameTimesArray objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    
    
    cell.textLabel.text = [tempObject objectForKey:@"name"];
    cell.detailTextLabel.text = [tempObject objectForKey:@"address"];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    cell.backgroundColor = [UIColor colorWithRed:226 green:239 blue:237 alpha:.8];
    
    
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.textLabel.font = [UIFont fontWithName:@"optima" size:15.0];
    cell.detailTextLabel.font = [UIFont fontWithName:@"american typewriter" size:13.0];
    
    
    return cell;
    
    
}

#pragma -mark TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell tapped");
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



-(void)getPlacesFromGoogle{
    
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=51.503186,-0.126446&radius=5000&types=pub&sensor&key=IzaSyCJR91xOyftoSVE6Tj2EwrARyLKh0KlDso"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        
                NSMutableDictionary *allData = [NSJSONSerialization
                                                JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
                NSArray *results = [allData objectForKey:@"results"];
        
                NSMutableArray *placesFound = [NSMutableArray array];
        
        if (results.count >= 1){
                NSLog(@"%@", results);
                NSLog(@"%@", placesFound);
        }
    }] resume];
}

//
//-(void)getPlacesFromGoogle{
//    
//    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/radarsearch/json?location=%f,%f&radius=300&types=gym|fitness=&key=AIzaSyCJR91xOyftoSVE6Tj2EwrARyLKh0KlDso",self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude];
//    
//    NSURL  *url = [NSURL URLWithString:urlStr];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    
//    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        NSError *jsonError;
//        
//        NSMutableDictionary *allData = [NSJSONSerialization
//                                        JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
//        
//        NSArray *results = [allData objectForKey:@"results"];
//        
//        NSMutableArray *placesFound = [NSMutableArray array];
//        
//        NSLog(@"%@", placesFound);
//        
//        if (results.count >= 1){
//            
//            for (id object in results) {
//                
//                NSDictionary *places = object;
//                
//                NSString *name = [places objectForKey:@"name"];
//                
//                NSString *googlePlacesID = [places objectForKey:@"place_id"];
//                
//                NSDictionary *geometry = [places objectForKey:@"geometry"];
//                
//                NSDictionary *location = [geometry objectForKey:@"location"];
//                
//                NSNumber *lat = [location objectForKey:@"lat"];
//                
//                NSNumber *lng = [location objectForKey:@"lng"];
//                
//                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
//                
//                MapViewAnnotation *annotation = [[MapViewAnnotation alloc]initWithTitle:name andCoordinate:latlng andGooglePlacesID:googlePlacesID];
//                
//                
//                
//                [placesFound addObject:annotation];
//                
//            }
//            
//            [self performSelectorOnMainThread:@selector(displayNewAnnotations:) withObject:placesFound waitUntilDone:NO];
//            
//        }
//        
//        
//        
//    }] resume];
//    
//    
//}
//
//-(void)displayNewAnnotations:(NSMutableArray *)places {
//    
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    
//    [self.mapView addAnnotations:places];
//    
//}
//
//
//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
//    static NSString *identifier = @"MyLocation";
//    
//    
//    if ([annotation isKindOfClass:[MapViewAnnotation class]]) {
//        
//        MKAnnotationView *aView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//        
//        
//        
//        if (aView == nil) {
//            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//            
//            aView.image = [UIImage imageNamed:@"pin.png"];
//            aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoDark];
//            aView.canShowCallout = YES;
//            aView.annotation = annotation;
//        } else {
//            aView.annotation = annotation;
//        }
//        
//        return aView;
//        
//    } else {
//        return nil;
//    }
//}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
