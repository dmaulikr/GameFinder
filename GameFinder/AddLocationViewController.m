//
//  AddLocationViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 7/27/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "AddLocationViewController.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"

@interface AddLocationViewController ()

@end

@implementation AddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Show keyboard when view first appears
    [self.locationNameTextField becomeFirstResponder];
    self.didPressSave = YES;
        //Style and set up image view for user adding picture
    self.addLocationPictureImageView.layer.cornerRadius = 4.0f;
    self.addLocationPictureImageView.clipsToBounds = YES;
    self.addLocationPictureImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapImageView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openCamera)];
    tapImageView.numberOfTapsRequired = 1.0f;
    [self.addLocationPictureImageView addGestureRecognizer:tapImageView];
    

}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    self.view.superview.bounds = CGRectMake(0, 0, self.view.frame.size.width-10, self.view.frame.size.height-10);
    self.view.layer.cornerRadius = 4.0f;
    self.view.layer.borderColor = [UIColor whiteColor].CGColor;
    self.view.layer.borderWidth = 6.0f;
    
    

    //Style save buttton
    self.saveButton.layer.cornerRadius = 4.0f;
    self.saveButton.hidden = YES;
    }
    
   #pragma mark UITextField delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    self.saveButton.hidden = NO;
    self.didPressSave = NO;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self hideKeyboard];
    return YES;
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

#pragma mark Button helper methods
- (IBAction)handleCloseButtonPressed:(id)sender {
    if (!self.didPressSave) {
        [self showAlertViewController];
    }else{
    [self closeViewController];
    }
}
- (IBAction)handleSaveButtonPressed:(id)sender {
    [self postLocationToParse];
}

#pragma mark Post location to Parse
-(void)postLocationToParse{
    PFObject *location = [PFObject objectWithClassName:@"Games"];
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error){
        CLLocation *currentLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *place = [placemarks lastObject];
            location[@"name"] = self.locationNameTextField.text;
            location[@"location"] = geoPoint;
            location[@"address"] = place.name;
            location[@"city"] = place.locality;
            location[@"state"] = place.administrativeArea;
            location[@"zip"] = place.postalCode;
            if (self.outdoorSwitch.on) {
                location[@"indoor"] = @NO;
            }else{
                location[@"indoor"] = @YES;
            }
            if (self.lightSwitch.on) {
                location[@"lights"] = @YES;
            }else{
                location[@"lights"] = @NO;
            }
            if (self.coveredSwitch.on) {
                location[@"covered"] = @YES;
            }else{
                location[@"covered"] = @NO;
            }
            if (self.publicSwitch.on) {
                location[@"openToPublic"] = @YES;
            }else{
                location[@"openToPublic"] = @NO;
            }
            if (self.locationNameTextField.text.length >= 1) {
            
                NSData *data = UIImagePNGRepresentation(self.addLocationPictureImageView.image);
                PFFile *file = [PFFile fileWithData:data];
                [location setObject:file forKey:@"locationImage"];
                
            [location saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [SVProgressHUD showWithStatus:@"Saving location..."];
                if (error) {  // Failed to save, show an alert view with the error message
                    
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Unable to save location" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    
                    
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                       
                        
                    }];
                    
                    
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    
                    return;
                }
                if (succeeded) {  // Successfully saved, post a notification to tell other view controllers
                    
                    [SVProgressHUD showSuccessWithStatus:@"Saved!"];
                    self.didPressSave = YES;
                    [self closeViewController];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"addedLocation" object:nil];
                   
                    
                } else {
                    NSLog(@"Failed to save.");
                }
                
                
            }];
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Please enter a valid name" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:okay];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
        
    }];
  
}

#pragma mark Handle close/save and dismissal of View

-(void)showAlertViewController{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Would you like to save this location?" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self postLocationToParse];
    }];
    UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"No thanks" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self closeViewController];
    }];
    [alert addAction:save];
    [alert addAction:dismiss];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)closeViewController{
        [self hideKeyboard];
         [UIView animateWithDuration:1.0f animations:^{
             self.view.center = CGPointMake(self.view.center.x, self.view.center.y +800);
         } completion:^(BOOL finished) {
             [self dismissViewControllerAnimated:NO completion:nil];
         }];

}

#pragma mark -camera methods
-(void)openCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    } else {
        
        UIAlertController *noCamera = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Must have a camera." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        }];
        
        [noCamera addAction:action];
        
        [self presentViewController:noCamera animated:YES completion:nil];
    }

}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.addLocationPictureImageView.image = chosenImage;
    self.saveButton.hidden = NO;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


#pragma mark -UISwitch methods
- (IBAction)outdoorSwitch:(id)sender {
    
    if ([sender isOn]) {
        self.courtIsOutside = YES;
    }else{
        [self.lightSwitch setOn:NO];
        [self.coveredSwitch setOn:NO];
    }
    
}
- (IBAction)lightSwitch:(id)sender {
    if ([sender isOn]) {
        self.courtHasLights = YES;
    }
    
}
- (IBAction)coveredSwitch:(id)sender {
    if ([sender isOn]) {
        self.courtIsCovered = YES;
    }
    
}
- (IBAction)publicSwitch:(id)sender {
    if ([sender isOn]) {
         self.courtIsOpenToPublic = YES;
    }
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
