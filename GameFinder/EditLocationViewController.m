//
//  EditLocationViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 8/10/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "EditLocationViewController.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"

@interface EditLocationViewController ()

@end

@implementation EditLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.placeNameTextField.text = self.nameString;
    if ([self.indoorBool  isEqual: @(1)]) {
        [self.outdoorSwitch setOn:false];
    }else{
        [self.outdoorSwitch setOn:true];
    }
    if ([self.lightBool isEqual:@(1)]) {
        [self.lightSwitch setOn:true];
    }else{
        [self.lightSwitch setOn:false];
    }
    if ([self.coveredBool isEqual:@(1)]) {
        [self.coveredSwitch setOn:true];
    }else{
        [self.coveredSwitch setOn:false];
    }
    if ([self.publicBool isEqual:@(1)]) {
        [self.publicSwitch setOn:true];
    }else{
        [self.publicSwitch setOn:false];
    }
    
    [self.eraseSwitch setOn:false];
    self.editLocationButton.hidden = YES;
    
    // Do any additional setup after loading the view.
}

- (IBAction)handleEditButtonPressed:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query whereKey:@"name" containsString:self.originalName];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        object[@"name"] = self.placeNameTextField.text;
        if (self.outdoorSwitch.on) {
            object[@"indoor"] = @NO;
        }else{
            object[@"indoor"] = @YES;
        }
        if (self.lightSwitch.on) {
            object[@"lights"] = @YES;
        }else{
            object[@"lights"] = @NO;
        }
        if (self.coveredSwitch.on) {
            object[@"covered"] = @YES;
        }else{
            object[@"covered"] = @NO;
        }
        if (self.publicSwitch.on) {
            object[@"openToPublic"] = @YES;
        }else{
            object[@"openToPublic"] = @NO;
        }
        if (self.eraseSwitch.isOn) {
            [object incrementKey:@"shouldEraseLocation" byAmount:@1];
        }else{
            [object incrementKey:@"shouldEraeLocation" byAmount:@0];
        }

        [object saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            [SVProgressHUD showWithStatus:@"Saving" maskType:SVProgressHUDMaskTypeClear];
            if (!error) {
                [SVProgressHUD showSuccessWithStatus:@"Saved changes"];
                [self performSegueWithIdentifier:@"NewLocationInformation" sender:object];
            }
            
        }];
    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    self.editLocationButton.hidden = NO;
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

- (IBAction)outdoorSwitch:(id)sender {
    self.editLocationButton.hidden = NO;
}
- (IBAction)lightSwitch:(id)sender {
    self.editLocationButton.hidden = NO;
}
- (IBAction)coveredSwitch:(id)sender {
    self.editLocationButton.hidden = NO;
}
- (IBAction)publicSwitch:(id)sender {
    self.editLocationButton.hidden = NO;
}
- (IBAction)eraseLocation:(id)sender {
    self.editLocationButton.hidden = NO;
}



- (IBAction)handleCloseButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
