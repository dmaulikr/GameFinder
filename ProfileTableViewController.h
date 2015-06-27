//
//  ProfileTableViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 4/21/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *birthdayTableViewCell;

@property (weak, nonatomic) IBOutlet UIButton *logOutButton;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *oftenPlayCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *experienceCell;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@end
