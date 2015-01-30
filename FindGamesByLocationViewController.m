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
    
    
        
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocationRange:) name:@"updatedLocation" object:nil];
    
}

//-(void)viewDidAppear:(BOOL)animated {
//   
//    BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults ] boolForKey:@"isLoggedIn"];
//    if (!isLoggedIn) {
//        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogInScreen"];
//    
//    [self presentViewController:viewController animated:YES completion:^{
//        
//    }];
//
//    }
//    
//}

-(void)updateRegion:(CLLocationCoordinate2D) location{
    
    self.mapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D initialLocationFocus = location;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(initialLocationFocus, span);
    
    [self.mapView setRegion:region animated:YES];
    
    
    
}


-(void)updateLocationRange:(NSNotification *)notif {
    
    CLLocation *newLocation = notif.object;
    
    [self updateRegion:newLocation.coordinate];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
