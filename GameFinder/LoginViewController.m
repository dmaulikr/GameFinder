//
//  LoginViewController.m
//  SignInWithParse
//
//  Created by Nick Reeder on 1/30/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <TwitterKit/TwitterKit.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    self.socialLoginView.hidden = YES;
    
    
}


#pragma -mark UITextfield delegate methods


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    if (textField == self.userTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (textField == self.passwordRegisterTextField) {
        [textField resignFirstResponder];
        [self.emailTextField becomeFirstResponder];
        
    }
    else if (textField == self.passwordTextField || self.emailTextField){
        [self logIn];
    }
    return YES;
}



-(void)hideKeyboard {
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
}


- (IBAction)logInWithFacebookOrTwitterButton:(id)sender {
    self.socialLoginView.backgroundColor = [UIColor colorWithHue:359.0 saturation:0 brightness:.26 alpha:.90];
    self.socialLoginView.hidden = NO;
}

- (IBAction)cancelSocialLoginButton:(id)sender {
    self.socialLoginView.hidden = YES;
}
- (IBAction)facebookLogInButton:(id)sender {
    NSArray *permissions = @[@"public_profile"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (user) {
            [self performSegueWithIdentifier:@"LoginSuccessful" sender:self];
        }
        if (user.isNew){
            if ([FBSDKAccessToken currentAccessToken]) {
                [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
                 startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     if (!error) {
                         
                         //NSLog(@"result: %@", result);
                         
                         NSString *email = result[@"email"];
                         NSString *fbId = result[@"id"];
                         NSRange range = [email rangeOfString:@"@"];
                         NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", fbId]];
                         NSString *bday = result[@"birthday"];
                         
                         NSString *facebookPic = [pictureURL absoluteString];
                         
                         NSString *username = [email substringToIndex:range.location];
                         
                         if (email.length > 1 && fbId.length > 1 && facebookPic.length >1 && username.length >1){
                             [user setObject:username forKey:@"username"];
                             [user setObject:fbId forKey:@"facebookId"];
                             [user setObject:facebookPic forKey:@"facebookImageUrl"];
                             [user setObject:bday forKey:@"birthday"];
                             [user setObject:email forKey:@"email"];
                             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                                 if (succeeded) {
                                     UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"settingsStoryboard"];
                                     [self presentViewController:vc animated:YES completion:nil];
                                 }
                             }];
                             
                             
                             
                         }
                     }
                 }];
            }
        }
    }];
    
}

/*
 - (IBAction)twitterLogInButton:(id)sender {
 [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
 if (!user) {
 NSLog(@"Uh oh. The user cancelled the Twitter login.");
 return;
 } else if (user.isNew) {
 NSURL *verify = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
 NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
 [[PFTwitterUtils twitter] signRequest:request];
 NSURLResponse *response = nil;
 NSData *data = [NSURLConnection sendSynchronousRequest:request
 returningResponse:&response
 error:&error];
 
 NSError* error;
 // If response JSON starts with {}, it represents dictionary
 NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
 
 NSLog(@"dicData %@", dicData);
 }
 }];
 
 }
 */

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
