//
//  UserDetailViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 8/6/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *experienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property NSString *username;
@property NSString *experience;
@end
