//
//  LoadingViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 4/23/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "LoadingViewController.h"
#import <Parse/Parse.h>

@interface LoadingViewController ()

@end

@implementation LoadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    UIViewController *logIn = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"NavigationScreen"];
    UIViewController *newUser = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"LogInScreen"];
    
    
    if ([PFUser currentUser] != NULL) {
        [self presentViewController:logIn animated:YES completion:nil];
    }else{
        [self presentViewController:newUser animated:YES completion:nil];
    }
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
