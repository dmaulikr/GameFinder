//
//  IconExplanaionViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 8/13/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "IconExplanaionViewController.h"

@interface IconExplanaionViewController ()

@end

@implementation IconExplanaionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    // Do any additional setup after loading the view.
}

-(void)viewWillLayoutSubviews{
    self.view.superview.bounds = CGRectMake(0, -90, self.view.frame.size.width, self.view.frame.size.height);
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    self.view.layer.borderWidth = 6.0f;
    self.view.layer.cornerRadius = 2.0f;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)handleCloseButtonPressed:(id)sender {
    [UIView animateWithDuration:0.5f animations:^{
        self.view.superview.bounds = CGRectMake(0, self.view.superview.frame.origin.y-800, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

@end
