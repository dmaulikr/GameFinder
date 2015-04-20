//
//  signUpViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 4/20/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "signUpViewController.h"
#import <Parse/Parse.h>

@interface signUpViewController ()

@end

@implementation signUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.registerPasswordTextField.hidden = YES;
    self.registerEmailTextField.hidden = YES;
    self.registerOftenPlayTextField.hidden = YES;
    self.registerExperienceTextField.hidden = YES;
    self.registerBirthdayTextField.hidden = YES;
    self.signUpButton.hidden = YES;
    
    
    self.experiencePickerData = @[@"Recreational", @"High School", @"Junior College",@"Division II or III", @"Division I College", @"Professional"];
    self.oftenPickerData = @[@"1",@"2",@"3",@"4",@"5",@"More than 5"];
    
    
    UIPickerView *picker = [[UIPickerView alloc]init];
    picker.delegate = self;
    picker.dataSource = self;
    
    UIPickerView *picker2 = [[UIPickerView alloc]init];
    picker2.delegate = self;
    picker2.dataSource = self;
    
    self.registerOftenPlayTextField.inputView = picker;
    self.registerExperienceTextField.inputView = picker2;
    
    self.registerBirthdayTextField.inputView = [self configureDatePicker];
    
    
    
    
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    // Do any additional setup after loading the view.
}

- (IBAction)signUpButtonPressed:(id)sender {
    [self registerNewUser];
}

- (void)registerNewUser {
    
    PFUser *user = [PFUser user];
    user.username = self.registerUsernameTextField.text;
    user.password = self.registerPasswordTextField.text;
    user.email = self.registerEmailTextField.text;
    [user setObject:self.registerOftenPlayTextField.text forKey:@"oftenPlay"];
    [user setObject:self.registerBirthdayTextField.text forKey:@"birthday"];
    [user setObject:self.registerExperienceTextField.text forKey:@"experience"];
    if (self.registerUsernameTextField.text.length > 3 && self.registerEmailTextField.text.length > 4 && self.registerEmailTextField != nil && self.registerOftenPlayTextField != nil && self.registerBirthdayTextField != nil && self.registerExperienceTextField != nil) {
        
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            [self performSegueWithIdentifier:@"logInAfterSignUp" sender:nil];
            
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
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"There was a problem registering your information." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Try again." style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:dismiss];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Date Picker Methods


- (UIDatePicker *)configureDatePicker
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.maximumDate = [NSDate date];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(handleDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    return datePicker;
}

-(void)dismissDatePicker
{
    [self.registerBirthdayTextField resignFirstResponder];
    
    
}

-(void)handleDatePickerValueChanged:(UIDatePicker *)datePicker
{
    NSDate *date = datePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    self.registerBirthdayTextField.text = [dateFormat stringFromDate:date];
    self.registerExperienceTextField.hidden = NO;
    [self.registerExperienceTextField becomeFirstResponder];
}



#pragma mark - UIPicker Delegate Methods


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(pickerView == self.registerOftenPlayTextField.inputView)
        return self.oftenPickerData.count;
    else
        return self.experiencePickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (pickerView == self.registerOftenPlayTextField.inputView) {
        return self.oftenPickerData[row];
    }
    return self.experiencePickerData[row];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (self.registerOftenPlayTextField.inputView == pickerView) {
         self.registerOftenPlayTextField.text = self.oftenPickerData[row];
        [self.registerExperienceTextField resignFirstResponder];
        self.registerBirthdayTextField.hidden = NO;
        [self.registerBirthdayTextField becomeFirstResponder];
    } if (pickerView == self.registerExperienceTextField.inputView) {
        self.registerExperienceTextField.text = self.experiencePickerData[row];
        [self.registerExperienceTextField resignFirstResponder];
        self.signUpButton.hidden = NO;
    }
   
}



#pragma mark - textField methods



-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    if (textField == self.registerUsernameTextField) {
        [textField resignFirstResponder];
        self.registerPasswordTextField.hidden = NO;
        [self.registerPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.registerPasswordTextField) {
        [textField resignFirstResponder];
        self.registerEmailTextField.hidden = NO;
        [self.registerEmailTextField becomeFirstResponder];
        
    }
    else if (textField == self.registerEmailTextField) {
        [textField resignFirstResponder];
        self.registerOftenPlayTextField.hidden = NO;
        [self.registerOftenPlayTextField becomeFirstResponder];
        
    }
    
    else if (textField == self.registerOftenPlayTextField) {
        [textField resignFirstResponder];
        self.registerBirthdayTextField.hidden = NO;
        [self.registerBirthdayTextField becomeFirstResponder];
        
    }
    else if (textField == self.registerBirthdayTextField) {
        [textField resignFirstResponder];
        self.registerExperienceTextField.hidden = NO;
        [self.registerExperienceTextField becomeFirstResponder];
        self.signUpButton.hidden = NO;
    }
    else if (textField == self.registerExperienceTextField){
        [self registerNewUser];
    }
    return YES;
}

-(void)dismissKeyboard:(id)sender{
    [self.view endEditing:YES];
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
