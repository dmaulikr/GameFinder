//
//  LoginViewController.h
//  SignInWithParse
//
//  Created by Nick Reeder on 1/30/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterViewController.h"
#import <MapKit/MapKit.h>

@interface LoginViewController : UIViewController < UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButtonArrow;
@property (weak, nonatomic) IBOutlet UIButton *logInButtonArrow;

@property (weak, nonatomic) IBOutlet UIButton *signUp;
@property (weak, nonatomic) IBOutlet UIButton *logIn;

@property (weak, nonatomic) IBOutlet UIView *gameFinderView;


@property (weak, nonatomic) IBOutlet UITextField *userRegisterTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordRegisterTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end
