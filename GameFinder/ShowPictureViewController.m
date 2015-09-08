//
//  ShowPictureViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 9/8/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ShowPictureViewController.h"
#import "UIImageView+WebCache.h"

@interface ShowPictureViewController ()

@end

@implementation ShowPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showImageImageView.layer.cornerRadius = 6.0f;
    self.showImageImageView.layer.borderWidth = 2.0f;
    self.showImageImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.showImageImageView.clipsToBounds = YES;
    [self.showImageImageView sd_setImageWithURL:self.pictureUrl placeholderImage:[UIImage imageNamed:@"loading"]];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleCloseButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
