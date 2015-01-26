//
//  FindGamesViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 1/24/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MapViewAnnotation.h"

@interface FindGamesViewController : ViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITabBarItem *timeBarButton;
@property (weak, nonatomic) IBOutlet UITabBarItem *skillBarButton;
@property (weak, nonatomic) IBOutlet UITabBarItem *locationBarButton;

@end
