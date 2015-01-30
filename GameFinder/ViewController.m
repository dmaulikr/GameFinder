//
//  ViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 1/22/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ViewController.h"




@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)signInButton:(id)sender {
   
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
   
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
