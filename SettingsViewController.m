//
//  SettingsViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 4/6/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "SettingsViewController.h"
#import <Parse/Parse.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profileImage.image = [UIImage imageNamed:@"profile"];
    self.usernameLabel.text = [PFUser currentUser].username;
    self.pickerData = @[@"Recreational", @"High School", @"Junior College",@"Division II or III", @"Division I College", @"Professional"];

    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    self.experienceTextField.inputView = pickerView;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)stepper:(UIStepper *)sender {
    
    
    double value = [sender value];
    sender.maximumValue = 10;
    sender.minimumValue = 1;
    
    [self.oftenPlayLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
}
- (IBAction)saveButton:(id)sender {
   
    PFUser *user = [PFUser currentUser];
    NSString *oftenPlay = self.oftenPlayLabel.text;
    [user setObject:oftenPlay forKey:@"oftenPlay"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Saved");
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

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    pickerView.tintColor = [UIColor blackColor];
    return self.pickerData[row];
    
    
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.experienceTextField.text = [self.pickerData objectAtIndex:row];
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
