//
//  MapViewAnnotation.h
//  GameFinder
//
//  Created by Nick Reeder on 2/12/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapViewAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *googlePlacesID;

@property(nonatomic) BOOL animatesDrop;


-(id) initWithTitle:(NSString *) annotationTitle andCoordinate:(CLLocationCoordinate2D)
annotationCoordinate andGooglePlacesID: (NSString *) placesID ;




@end
