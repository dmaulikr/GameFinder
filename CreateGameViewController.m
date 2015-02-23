//
//  CreateGameViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 2/20/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "CreateGameViewController.h"

@interface CreateGameViewController ()

@end

@implementation CreateGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.datePicker.datePickerMode = UIDatePickerModeTime;
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
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
