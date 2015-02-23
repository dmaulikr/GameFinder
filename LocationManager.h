//
//  LocationManager.h
//  GameFinder
//
//  Created by Nick Reeder on 2/22/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property CLLocationManager *locationManager;

@property CLLocation *currentLocation;

@property CLLocation *startingLocation;

@end
