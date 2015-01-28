//
//  FindGamesViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 1/24/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ViewController.h"



@interface FindGamesViewController : UIViewController 

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (weak, nonatomic) IBOutlet UITabBarItem *timeBarButton;
@property (weak, nonatomic) IBOutlet UITabBarItem *skillBarButton;
@property (weak, nonatomic) IBOutlet UITabBarItem *locationBarButton;

@end
