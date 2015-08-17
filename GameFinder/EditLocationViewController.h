//
//  EditLocationViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 8/10/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditLocationViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;

@property (weak, nonatomic) IBOutlet UITextField *placeNameTextField;
@property (weak, nonatomic) IBOutlet UISwitch *outdoorSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *lightSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *coveredSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *publicSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *eraseSwitch;
@property (weak, nonatomic) IBOutlet UIButton *editLocationButton;

@property NSString *originalName;
@property NSString *nameString;
@property NSNumber *outdoorBool;
@property NSNumber *lightBool;
@property NSNumber *coveredBool;
@property NSNumber *publicBool;
@property NSNumber *outdoor;

@property BOOL shouldErase;



@end
