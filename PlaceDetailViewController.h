//
//  PlaceDetailViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 2/12/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface PlaceDetailViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapDetailView;

@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;



@end
