//
//  HTTPManager.h
//  GameFinder
//
//  Created by Nick Reeder on 1/25/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface HTTPManager : NSObject

+(id)sharedManager;

-(void)requestPlacesForLocation:(CLLocationCoordinate2D)userLocations radius:(float) radius andSearchTerm:(NSString *)searchTerm;

@end
