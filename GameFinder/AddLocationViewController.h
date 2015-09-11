//
//  AddLocationViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 7/27/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface AddLocationViewController : UIViewController <UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *locationNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UISwitch *outdoorSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *lightSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *coveredSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;

@property (strong, nonatomic) IBOutlet UIView *backgroundView;

@property CLLocation *placeLocation;

@property (strong, nonatomic) PFGeoPoint *placeGeoPoint;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *zip;

@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (weak, nonatomic) IBOutlet UIButton *thumbsDownButton;
@property (weak, nonatomic) IBOutlet UIButton *thumbsUpButton;

@property (nonatomic) BOOL courtIsOutside;
@property (nonatomic) BOOL courtHasLights;
@property (nonatomic) BOOL courtIsCovered;
@property (nonatomic) BOOL courtIsOpenToPublic;
@property (nonatomic) BOOL didPressSave;
@property (nonatomic) BOOL didTakePicture;
@end
