//
//  CreateGameViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 2/20/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateGameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property NSMutableArray *gameTimes;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end
