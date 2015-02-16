//
//  MapViewAnnotation.m
//  GameFinder
//
//  Created by Nick Reeder on 2/12/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "MapViewAnnotation.h"


@implementation MapViewAnnotation

-(id) initWithTitle:(NSString *) annotationTitle andCoordinate:(CLLocationCoordinate2D) annotationCoordinate {
    
    self = [super init];
    
    if (self) {
        _title = annotationTitle;
        _coordinate = annotationCoordinate;
      
        
    }
    return self;
}

@end
