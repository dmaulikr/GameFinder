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
    self.oftenPlaysLabel.alpha = 0.0f;
    self.experienceLabel.alpha = 0.0f;
    self.ageLabel.alpha = 0.0f;
    if (!self.oftenPlay) {
       self.oftenPlaysLabel.text = @"Not sure how many times a week they play";
    }else{
    self.oftenPlaysLabel.text = [NSString stringWithFormat:@"%@ plays %@ x's a week", self.username, self.oftenPlay];
    }
    self.ageLabel.text = [NSString stringWithFormat:@"%@ is %lu years old", self.username,(unsigned long)self.years];
    
    self.experienceLabel.text = [NSString stringWithFormat:@"Experience level is %@", self.experience];
    self.navigationItem.title = self.username;
}

-(void)viewDidAppear:(BOOL)animated{
    [UIView animateWithDuration:1.5 animations:^{
        self.experienceLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.5 animations:^{
            self.oftenPlaysLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.5 animations:^{
                self.ageLabel.alpha = 1.0;
            }];
        }];
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
