//
//  ProfileTableViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 4/21/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ProfileTableViewController.h"
#import <Parse/Parse.h>
#import "SDWebImage/UIImageView+WebCache.h"
#import "SVProgressHUD.h"
@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   
    
    self.navigationController.navigationBar.hidden = YES;
    
    // Style profile image view
    self.profileImageView.layer.cornerRadius = 50;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 3;
    

    // Style header view in order to set it apart from table view
    self.headerView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.headerView.layer.borderWidth = 2.0f;
    
    self.profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageOptions)];
    tap.numberOfTapsRequired = 1.0f;
    self.saveEmailButton.hidden = YES;
    self.saveUserNameButton.hidden = YES;
    
    
    [self.profileImageView addGestureRecognizer:tap];
}
-(void)viewWillAppear:(BOOL)animated{
    [self performSelector:@selector(queryParse)];

    self.usernameLabel.text = self.usernameTextField.text;
    
   
}
-(void)viewDidAppear:(BOOL)animated{
    [UIView animateWithDuration:1 animations:^{
        [self.logOutButton setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Futura-CondensedMedium" size:23.0]} forState:UIControlStateNormal];

        self.navigationController.toolbar.barTintColor = [UIColor colorWithRed:0.60f green:0.60f blue:0.60f alpha:1.0f];
        self.navigationController.toolbarHidden = NO;
        
    }];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.usernameTextField) {
        self.saveUserNameButton.hidden = NO;
        self.saveEmailButton.hidden = YES;
    }else if (textField == self.emailTextField){
        self.saveEmailButton.hidden = NO;
        self.saveUserNameButton.hidden = YES;
    }
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    }
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - save button methds

- (IBAction)handleSaveUsernameButtonPressed:(id)sender {
    if (self.usernameTextField.text.length >= 1) {
        [PFUser currentUser].username = self.usernameTextField.text;
        [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (!error) {
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Hello, %@", self.usernameTextField.text] maskType:SVProgressHUDMaskTypeClear];
                self.usernameLabel.text = self.usernameTextField.text;
                self.saveUserNameButton.hidden = YES;
            }else{
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:[error userInfo][@"error"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:dismiss];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];

    }
    }

- (IBAction)handleSaveEmailButtonPressed:(id)sender {
    if (self.emailTextField.text.length >= 6) {
    
    [PFUser currentUser].email = self.emailTextField.text;
    [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"We'll send an email to %@", self.emailTextField.text] maskType:SVProgressHUDMaskTypeGradient];
            self.emailTextField.text = self.emailTextField.text;
            self.saveEmailButton.hidden = YES;
            
        }else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:[error userInfo][@"error"] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:dismiss];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
  
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }else{
        return 2.0;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25.0f;
}

-(void)queryParse{
    PFUser *user = [PFUser currentUser];
    
    self.usernameTextField.text = [PFUser currentUser].username;
    self.emailTextField.text = [[PFUser currentUser] objectForKey:@"email"];
   self.oftenPlayCell.detailTextLabel.text = [[PFUser currentUser] objectForKey:@"oftenPlay"];
    self.experienceCell.detailTextLabel.text = [[PFUser currentUser] objectForKey:@"experience"];
    self.birthdayTableViewCell.detailTextLabel.text = [[PFUser currentUser] objectForKey:@"birthday"];
    
    PFFile *file = [user objectForKey:@"profileImage"];
    [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
        if (imageData) {
          
            UIImage *image = [UIImage imageWithData:imageData];
            self.profileImageView.image = image;
        }else{
            self.profileImageView.image = [UIImage imageNamed:@"hooper"];
        }
    }];

}

- (IBAction)logOutButton:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Log Out" message:@"Are you sure you want to log out?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [PFUser logOutInBackground];
        
        //* take user out of "checked in" games *//
        
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"LogInScreen"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)imageOptions{
    UIAlertController *options = [UIAlertController alertControllerWithTitle:@"Choose picture" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *openCameraApp = [UIAlertAction actionWithTitle:@"Take a new photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openCameraApp];
    }];
    UIAlertAction *chooseFromLibraray = [UIAlertAction actionWithTitle:@"Choose from photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self chooseFromPhotoLibrary];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [options addAction:chooseFromLibraray];
    [options addAction:openCameraApp];
    [options addAction:cancel];
    [self presentViewController:options animated:YES completion:nil];
}

-(void)openCameraApp{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    } else {
        
        UIAlertController *noCamera = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Must have a camera." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        }];
        
        [noCamera addAction:action];
        
        [self presentViewController:noCamera animated:YES completion:nil];
    }

    
}

-(void)chooseFromPhotoLibrary{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

// Image picker controller delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.profileImageView.image = chosenImage;
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [[PFUser currentUser]setObject:imageFile forKey:@"profileImage"];
    [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        if (success) {
            UIImageWriteToSavedPhotosAlbum (chosenImage, nil, nil, nil);
        }
    }];
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];

}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)handleCloseButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
