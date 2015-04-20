//
//  ProfileViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 4/15/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "SDWebImage/UIImageView+WebCache.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get info from parse
    [self queryParse];

    
    // Do any additional setup after loading the view.
    self.navigationTitle.title = [PFUser currentUser].username;
    self.profileImageView.layer.borderColor = [UIColor blackColor].CGColor;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderWidth = 3.0;
    self.profileImageView.frame = CGRectMake(0, 0, 100, 100);
    self.profileImageView.layer.cornerRadius = 50;
    self.changeButton.alpha = 0;
    self.navBar.alpha = 0;
    self.oftenLabel.alpha = 0;
    self.emailLabel.alpha = 0;
    self.experienceLabel.alpha = 0;
    self.ageLabel.alpha = 0;
    
    
    
    }

-(void)viewDidAppear:(BOOL)animated{
    // Cool animation effect when they land on this view
    [self performSelector:@selector(animateObjects) withObject:nil afterDelay:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)animateObjects{
    [UIView animateWithDuration:3 animations:^{
        self.profileImageView.center = CGPointMake(self.view.center.x, self.view.center.y-170);
        self.emailLabel.center = CGPointMake(self.view.center.x, self.view.center.y-90);
        self.oftenLabel.center = CGPointMake(self.view.center.x, self.view.center.y-20);
        self.ageLabel.center = CGPointMake(self.view.center.x, self.view.center.y+70);
        self.experienceLabel.center = CGPointMake(self.view.center.x, self.view.center.y+160);
        self.oftenLabel.alpha = 1;
        self.emailLabel.alpha = 1;
        self.experienceLabel.alpha = 1;
        self.ageLabel.alpha = 1;
        self.changeButton.alpha = 1;
        self.changeButton.center = CGPointMake(self.view.center.x, self.view.center.y + 250);
        self.navBar.alpha = 1;
        self.view.backgroundColor = [UIColor colorWithWhite:9 alpha:.8];
        

    }];
    
}
     
-(void)queryParse{
    
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:user.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
        for (id userObject in results) {
            NSString *often = userObject[@"oftenPlay"];
            NSString *bday = userObject[@"birthday"];
            NSString *profilePic = userObject[@"facebookImageUrl"];
            NSURL *url = [NSURL URLWithString:profilePic];
            NSString *experience = userObject[@"experience"];
            NSString *email = userObject[@"email"];
            [self.profileImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile"]];
            self.oftenLabel.text = [NSString stringWithFormat:@"You play %@ times a week.", often];
            self.ageLabel.text = [NSString stringWithFormat:@"You were born on %@", bday];
            self.experienceLabel.text = [NSString stringWithFormat:@"Your experience level is %@", experience];
            self.emailLabel.text = [NSString stringWithFormat:@"Your email is %@", email];
        }
        
        
    }];
    
}
- (IBAction)changeProfileButton:(id)sender {
}
- (IBAction)cancelButton:(id)sender {
    [UIView animateWithDuration:1.5 animations:^{
        self.profileImageView.center = CGPointMake(self.view.center.x, self.view.center.y);
        self.oftenLabel.center = CGPointMake(self.view.center.x, self.view.center.y);
        self.emailLabel.center = CGPointMake(self.view.center.x, self.view.center.y);
        self.ageLabel.center = CGPointMake(self.view.center.x, self.view.center.y);
        self.experienceLabel.center = CGPointMake(self.view.center.x, self.view.center.y);
        self.changeButton.alpha = 0;
        self.changeButton.center = CGPointMake(self.view.center.x, self.view.center.y);
        self.view.backgroundColor = [UIColor whiteColor];
        self.navBar.alpha = 0;
        self.oftenLabel.alpha = 0;
        self.emailLabel.alpha = 0;
        self.experienceLabel.alpha = 0;
        self.ageLabel.alpha = 0;
    } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }];
    
    
}

- (IBAction)logOut:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    PFUser *user = [PFUser currentUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (id object in objects) {
            
            [object removeObject:user.username forKey:@"players"];
            [object saveInBackground];
            [PFUser logOut];
            
        }
    }];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LogInScreen"];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
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
