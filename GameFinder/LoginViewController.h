//
//  LoginViewController.h
//  SignInWithParse
//
//  Created by Nick Reeder on 1/30/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@interface LoginViewController : UIViewController < UITextFieldDelegate, UIAlertViewDelegate>

//sam.ingle@metaltoad.com


#pragma mark textfields
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;

#pragma mark views


@property (weak, nonatomic) IBOutlet UIButton *facebookButton;



@end
