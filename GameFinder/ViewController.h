//
//  ViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 1/22/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>





@interface ViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *signIn;

@property (weak, nonatomic) IBOutlet UIButton *signUp;

@property (weak, nonatomic) IBOutlet UITextField *email;

@property (weak, nonatomic) IBOutlet UITextField *password;
@end

