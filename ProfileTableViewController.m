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
@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSelector:@selector(queryParse)];
    
    
    self.headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-bg"]];
    // Style profile image view
    self.profileImageView.layer.cornerRadius = 50;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 3;
    
    // Set navigation title
    self.navigationItem.title = @"Profile";
    
    self.profileImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageOptions)];
    tap.numberOfTapsRequired = 1.0f;
    
    [self.profileImageView addGestureRecognizer:tap];
}
-(void)viewWillAppear:(BOOL)animated{
    self.logOutButton.alpha = 0;
    self.profileImageView.alpha = 0;
}
-(void)viewDidAppear:(BOOL)animated{
    [UIView animateWithDuration:1 animations:^{
        self.logOutButton.alpha = 1;
        self.profileImageView.alpha = 1;
    }];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 3;
}


-(void)queryParse{
    PFUser *user = [PFUser currentUser];
    NSString *username = [[PFUser currentUser] objectForKey:@"username"];
    self.usernameCell.detailTextLabel.text = username;
    NSString *email = [[PFUser currentUser] objectForKey:@"email"];
    NSString *oftenPlay = [[PFUser currentUser] objectForKey:@"oftenPlay"];
    NSString *experience = [[PFUser currentUser] objectForKey:@"experience"];
    NSString *birthday = [[PFUser currentUser] objectForKey:@"birthday"];
    
    PFFile *file = [user objectForKey:@"profileImage"];
    [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error){
        if (!error) {
          
            UIImage *image = [UIImage imageWithData:imageData];
            self.profileImageView.image = image;
        }
    }];

    self.profileImageView.image = [UIImage imageNamed:@"hooper"];
    self.usernameCell.detailTextLabel.text = username;
    self.emailCell.detailTextLabel.text = email;
    self.birthdayTableViewCell.detailTextLabel.text = birthday;
    self.oftenPlayCell.detailTextLabel.text = oftenPlay;
    self.experienceCell.detailTextLabel.text = experience;
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
    [options addAction:chooseFromLibraray];
    [options addAction:openCameraApp];
    [self presentViewController:options animated:YES completion:nil];
}

-(void)openCameraApp{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
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
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

// Image picker controller delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.profileImageView.image = chosenImage;
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [[PFUser currentUser]setObject:imageFile forKey:@"profileImage"];
    [[PFUser currentUser]saveInBackground];
    UIImageWriteToSavedPhotosAlbum (chosenImage, nil, nil, nil);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];

}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
