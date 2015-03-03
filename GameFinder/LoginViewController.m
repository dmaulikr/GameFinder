//
//  LoginViewController.m
//  SignInWithParse
//
//  Created by Nick Reeder on 1/30/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    
}


#pragma -mark UITextfield delegate methods


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    

    if (textField == self.userTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.userRegisterTextField) {
        [textField resignFirstResponder];
        [self.passwordRegisterTextField becomeFirstResponder];
    }
    else if (textField == self.passwordRegisterTextField) {
        [textField resignFirstResponder];
        [self.emailTextField becomeFirstResponder];
        
    }else if (textField == self.passwordTextField || self.emailTextField){
        [self logIn];
    }
    return YES;
}



-(void)hideKeyboard {
    [self.userTextField resignFirstResponder];
    [self.userRegisterTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.passwordRegisterTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}


#pragma mark Animation between login and sign up
- (IBAction)signUp:(id)sender {
    NSLog(@"signUp pressed");
    [UIView animateWithDuration:.5 animations:^{
        self.gameFinderView.alpha = 0;
    }];
    
}

- (IBAction)logInButtonInstead:(id)sender {
    
    [UIView animateWithDuration:.5 animations:^{
        self.gameFinderView.alpha = 1;

    }];
}



#pragma mark Login User
- (IBAction)logInPressed:(id)sender {
    
    [self logIn];
    
    }

-(void)logIn {
    
    
        
    [PFUser logInWithUsernameInBackground:self.userTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
                if (!error) {
            [self performSegueWithIdentifier:@"LoginSuccessful" sender:self];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@", errorString);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:errorString.uppercaseString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    
}

- (IBAction)forgotButton:(id)sender {
    UIAlertController *forgot = [UIAlertController alertControllerWithTitle:@"Forgot Password" message:@"enter your email address." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *submit = [UIAlertAction actionWithTitle:@"Submit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *email = forgot.textFields.firstObject;
        [PFUser requestPasswordResetForEmailInBackground:email.text];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [forgot addAction:cancel];
    [forgot addAction:submit];
    
    [forgot addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.placeholder = @"email address";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        
    }];
    
    [self presentViewController:forgot animated:YES completion:nil];
    
}

#pragma mark Register New User

- (IBAction)signUpButtonPressed:(id)sender {
    [self registerNewUser];
}

- (void)registerNewUser {
    
    PFUser *user = [PFUser user];
    user.username = self.userRegisterTextField.text;
    user.password = self.passwordRegisterTextField.text;
    user.email = self.emailTextField.text;
    

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self performSegueWithIdentifier:@"LoginSuccessful" sender:self];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@", errorString);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:errorString.uppercaseString preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
