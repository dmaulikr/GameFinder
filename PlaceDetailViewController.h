//
//  PlaceDetailViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 2/12/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PlaceDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapDetailView;


@property NSString *urlString;

@end
