//
//  AddLocationTableViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 7/26/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddLocationTableViewController : UITableViewController <UITextFieldDelegate, UINavigationBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;

@property (weak, nonatomic) IBOutlet UITextField *nameLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *indoorTextField;
@property (weak, nonatomic) IBOutlet UITextField *openToPublicTextField;

@property (weak, nonatomic) IBOutlet UITextField *timeToPlayTextField;
@property (weak, nonatomic) IBOutlet UITextField *lightsTextField;
@property (weak, nonatomic) IBOutlet UITextField *coveredTextField;

@property (nonatomic) NSArray *pickerOptions;
@end
