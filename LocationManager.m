//
//  LocationManager.m
//  GameFinder
//
//  Created by Nick Reeder on 2/26/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager
-(id) init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 400;
        
        
        [self.locationManager requestAlwaysAuthorization];
        
        
    }
    return self;
    
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
}



-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    self.currentLocation = [locations lastObject];
    
    if (self.startingLocation == nil) {
        
        self.startingLocation = self.currentLocation;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"initialLocation" object:self.currentLocation];
        
    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedLocation" object:self.currentLocation];
    }
    
}
@end
