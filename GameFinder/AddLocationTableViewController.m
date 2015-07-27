//
//  AddLocationTableViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 7/26/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "AddLocationTableViewController.h"
#import <Parse/Parse.h>

@interface AddLocationTableViewController ()

@end

@implementation AddLocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    self.lightsTextField.inputView = pickerView;
    self.coveredTextField.inputView = pickerView;
    self.openToPublicTextField.inputView = pickerView;
    self.pickerOptions = @[@"Yes", @"NO"];
    

  
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, 300, 400);
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 6;
}
- (IBAction)handleCloseButtonPressed:(id)sender {
    [UIView animateWithDuration:1.0f animations:^{
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y +500);
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    
}

-(void)saveLocationToParse{
    PFObject *gameObject = [PFObject objectWithClassName:@"Games"];
    gameObject[@"name"] = self.nameLocationTextField.text;
    gameObject[@"indoor"] = self.indoorTextField.text;
    gameObject[@"openToPublic"] = self.openToPublicTextField.text;
    gameObject[@"bestTimeToPlay"] = self.timeToPlayTextField.text;
    gameObject[@"lights"] = self.lightsTextField.text;
    gameObject[@"covered"] = self.coveredTextField.text;
    [gameObject saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        
    }];
}

#pragma mark -textField delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

#pragma mark -UIPickerView delegates and methods
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.pickerOptions[row];
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerOptions.count;
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}
- (IBAction)handleSaveButtonPressed:(id)sender {
    [self saveLocationToParse];
}

@end
