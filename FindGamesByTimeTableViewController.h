//
//  FindGamesByTimeTableViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 1/29/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
//#import "TimeCellTableViewCell.h"

@interface FindGamesByTimeTableViewController : UIViewController <UITableViewDataSource ,UITableViewDelegate>

@property NSArray *gameTimesArray;

@property (weak, nonatomic) IBOutlet UITableView *gameTime;


@end
