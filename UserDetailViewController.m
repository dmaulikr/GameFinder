//
//  UserDetailViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 8/6/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "UserDetailViewController.h"

@interface UserDetailViewController ()

@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profileImageView.layer.cornerRadius = 150.0;
    self.profileImageView.clipsToBounds = YES;
    self.usernameLabel.alpha = 0.0;
    self.experienceLabel.alpha = 0.0f;
    self.experienceLabel.text = self.experience;
    self.usernameLabel.text = self.username;
}

-(void)viewDidAppear:(BOOL)animated{
    [UIView animateWithDuration:2.5 animations:^{
        self.usernameLabel.alpha = 1.0;
        self.experienceLabel.alpha = 1.0;
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
