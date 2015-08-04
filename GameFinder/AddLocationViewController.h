//
//  AddLocationViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 7/27/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddLocationViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *locationNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UISwitch *outdoorSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *lightSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *coveredSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;

@property (weak, nonatomic) IBOutlet UIImageView *addLocationPictureImageView;
@property (strong, nonatomic) IBOutlet UIView *backgroundView;


@property (nonatomic) BOOL courtIsOutside;
@property (nonatomic) BOOL courtHasLights;
@property (nonatomic) BOOL courtIsCovered;
@property (nonatomic) BOOL courtIsOpenToPublic;
@property (nonatomic) BOOL didPressSave;
@end
