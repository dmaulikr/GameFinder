//
//  FindGamesViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 1/24/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "FindGamesViewController.h"


@interface FindGamesViewController ()

@end

@implementation FindGamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocationRange:) name:@"updatedLocation" object:nil];
    
    
}

-(void)getPlacesFromGoogle {
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/%f&radius=300&sensor=false&keyword=%f&key=AIzaSyAEgIRlWRmj1qzGUgbVasEn6i167LAcF20", self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError *jsonError;
        
        NSMutableDictionary *allData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        NSArray *results = [allData objectForKey:@"results"];
        
        NSMutableArray *placesFound = [NSMutableArray array];
        
        if (results.count <= 1) {
            
            for (id object in results) {
                NSDictionary *places = object;
                
                NSString *name = [places objectForKey:@"name"];
                
                NSDictionary *geometry = [places objectForKey:@"geometry"];
                
                NSDictionary *location = [geometry objectForKey:@"location"];
                
                NSNumber *lat = [location objectForKey:@"lat"];
                
                NSNumber *lng = [location objectForKey:@"lng"];
                
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
                
                MapViewAnnotation *annotation = [[MapViewAnnotation alloc]initWithTitle:name andCoordinate:latlng];
                
                [placesFound addObject:annotation];
            }
            
            [self performSelectorOnMainThread:@selector(displayNewAnnotations:) withObject:placesFound waitUntilDone:NO];
        }
        
    }] resume];
}

-(void)displayNewAnnotations:(NSMutableArray *)places {
    
    [self.mapView removeAnnotation:self.mapView.annotations];
    
    [self.mapView addAnnotation:places];
}

-(void)updateRegion:(CLLocationCoordinate2D) location {
    
    self.mapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D initialLocationFocus = location;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(initialLocationFocus, span);
    
    [self.mapView setRegion:region animated:YES];
}

-(void)updateLocationRange:(NSNotification *) notif {
    
    CLLocation *newLocation = notif.object;
    
    [self updateRegion:newLocation.coordinate];
}

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
