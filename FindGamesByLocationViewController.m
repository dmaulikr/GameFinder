//
//  FindGamesViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 1/24/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "FindGamesByLocationViewController.h"
#import <Parse/Parse.h>



@interface FindGamesByLocationViewController ()

@end

@implementation FindGamesByLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            self.mapView.showsUserLocation = YES;
            [self.mapView setDelegate:self];
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
            

        }
    }];
        
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocationRange:) name:@"updatedLocation" object:nil];
    
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)geoPoint{
    
    [self.mapView setRegion:MKCoordinateRegionMake(geoPoint.coordinate, MKCoordinateSpanMake(0.02, 0.02)) animated:YES];
    
}

//-(void)updateRegion:(CLLocationCoordinate2D) location{
//    
//    self.mapView.showsUserLocation = YES;
//    
//    CLLocationCoordinate2D initialLocationFocus = location;
//    
//    MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
//    
//    MKCoordinateRegion region = MKCoordinateRegionMake(initialLocationFocus, span);
//    
//    [self.mapView setRegion:region animated:YES];
//    
//    
//    
//}
//
//
//-(void)updateLocationRange:(NSNotification *)notif {
//    
//    CLLocation *newLocation = notif.object;
//    
//    [self updateRegion:newLocation.coordinate];
//}
//
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
