//
//  ProfileTableViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 4/21/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "ProfileTableViewController.h"
#import <Parse/Parse.h>
#import "SDWebImage/UIImageView+WebCache.h"
@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSelector:@selector(queryParse)];
    self.profileImageView.layer.cornerRadius = 50;
    
    self.headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"profile-bg"]];
    
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 3;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Profile";
}
-(void)viewWillAppear:(BOOL)animated{
    self.logOutButton.alpha = 0;
    self.profileImageView.alpha = 0;
}
-(void)viewDidAppear:(BOOL)animated{
    [UIView animateWithDuration:1 animations:^{
        self.logOutButton.alpha = 1;
        self.profileImageView.alpha = 1;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 3;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)queryParse{
    
    NSString *username = [[PFUser currentUser] objectForKey:@"username"];
    self.usernameCell.detailTextLabel.text = username;
    NSString *email = [[PFUser currentUser] objectForKey:@"email"];
    NSString *oftenPlay = [[PFUser currentUser] objectForKey:@"oftenPlay"];
    NSString *experience = [[PFUser currentUser] objectForKey:@"experience"];
    NSString *birthday = [[PFUser currentUser] objectForKey:@"birthday"];
    NSString *facebookImageUrl = [[PFUser currentUser] objectForKey:@"facebookImageUrl"];
    NSURL *url = [NSURL URLWithString:facebookImageUrl];
    
    [self.profileImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"hooper"]];
    self.usernameCell.detailTextLabel.text = username;
    self.emailCell.detailTextLabel.text = email;
    self.birthdayTableViewCell.detailTextLabel.text = birthday;
    self.oftenPlayCell.detailTextLabel.text = oftenPlay;
    self.experienceCell.detailTextLabel.text = experience;
}

- (IBAction)logOutButton:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Log Out" message:@"Are you sure you want to log out?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [PFUser logOutInBackground];
        
        //* take user out of "checked in" games *//
        
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"LogInScreen"];
        [self presentViewController:vc animated:YES completion:nil];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:yes];
    [alert addAction:no];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
