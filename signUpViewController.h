//
//  signUpViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 4/20/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface signUpViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *registerEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *registerUsernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *registerBirthdayTextField;

@property (weak, nonatomic) IBOutlet UITextField *registerExperienceTextField;
@property (weak, nonatomic) IBOutlet UITextField *registerPasswordTextField;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@property NSArray *experiencePickerData;



@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end
