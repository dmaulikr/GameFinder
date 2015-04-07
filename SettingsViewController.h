//
//  SettingsViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 4/6/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@property (weak, nonatomic) IBOutlet UILabel *oftenPlayLabel;

@property NSArray *pickerData;

@property (weak, nonatomic) IBOutlet UITextField *experienceTextField;

@end
