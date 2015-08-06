//
//  PlaceDetailViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 2/12/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "Parse/Parse.h"
#import "AppDelegate.h"
#import "PlayersHeaderCollectionReusableView.h"
#import "ScheduledGamesTableViewCell.h"
#import "SVProgressHUD.h"
#import "UserDetailViewController.h"

@interface PlaceDetailViewController ()


@end

@implementation PlaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playersArray = self.placeObject[@"players"];
   self.navigationController.hidesBarsOnSwipe = NO;
    self.scheduledGamesArray = self.placeObject[@"scheduledGames"];
    if (self.scheduledGamesArray.count == 0) {
        self.tableView.hidden = YES;
    }
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
    
    
    self.takePictureLabel.hidden = YES;
    self.placeImageView.layer.borderWidth = 1.0f;
    self.placeImageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.placeImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.placeImageView.clipsToBounds = YES;
    if (![self.playersArray containsObject:[PFUser currentUser]]) {
        self.addNumberOfPlayersTextField.hidden = YES;
        self.addPlayersLabel.hidden = YES;
    }
    self.saveAddPlayersButton.hidden = YES;
    self.saveScheduleButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocation:) name:@"updatedLocation" object:nil];
    
    
    UIPickerView *pickerView = [[UIPickerView alloc]init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    self.addNumberOfPlayersTextField.inputView = pickerView;
    self.numberPickerArray = @[@"< 5", @"5-15", @"15-25", @"> 25"];
    self.scheduleGameTextField.inputView = [self configureDatePicker];
}
-(void)viewDidAppear:(BOOL)animated{
    if (!self.placeImageView.image) {
        self.placeImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(isNear)];
        tap.numberOfTapsRequired = 1.0;
        self.placeImageView.image = [UIImage imageNamed:@"take-picture"];
        [self.placeImageView addGestureRecognizer:tap];
        self.takePictureLabel.hidden = NO;
        self.placeImageView.backgroundColor = [UIColor colorWithWhite:.9 alpha:1.0];
        self.placeImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.placeImageView.clipsToBounds = YES;
    }
    
}

#pragma mark
#pragma CollectionView DataSources

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier = @"PlayersCollectionViewCell";
    NSDictionary *player = [self.playersArray objectAtIndex:indexPath.row];
    PFFile *file = player[@"profileImage"];
    
    PlaceDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            cell.playerProfileImageView.image = image;
        }
    }];
    cell.layer.cornerRadius = 40;
    cell.playerProfileImageView.clipsToBounds = YES;
    cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.layer.borderWidth = 2.0f;
    
    cell.playerUsernameLabel.text = player[@"username"];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return self.playersArray.count;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        PlayersHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        NSString *title = [NSString stringWithFormat:@"There are %@ more players here", self.placeObject[@"numberOfExtraPlayers"]];
        headerView.title.text = title;
        headerView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        headerView.layer.borderWidth = 1.0f;
        
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma -mark
#pragma CellectionView Delegates

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *object = [self.playersArray objectAtIndex:indexPath.row];
    
    //Send that object along to the segue
    [self performSegueWithIdentifier:@"ShowUserDetail" sender:object];
}


- (IBAction)shareLocation:(id)sender {
    
    CLLocationCoordinate2D placeLocation = CLLocationCoordinate2DMake(self.locationCoordinate.latitude, self.locationCoordinate.longitude);
    
    NSString *msg = @"Come play with me.";
    // *make this my icon
    //UIImage *img = [UIImage imageNamed:@"compass"];
    
    NSString *coordinates = [NSString stringWithFormat:@"http://maps.apple.com/?q=%f,%f", placeLocation.latitude, placeLocation.longitude];
    NSURL *myUrl = [NSURL URLWithString:coordinates];
    NSLog(@"myUrl = %@", myUrl);
    
    
    UIActivityViewController *uac = [[UIActivityViewController alloc]initWithActivityItems:@[msg,myUrl] applicationActivities:nil];
    
    
    [self presentViewController:uac animated:YES completion:^{
        
    }];
}

-(void)isNear{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    CLLocation *placeLocation = [[CLLocation alloc]initWithLatitude:self.locationCoordinate.latitude longitude:self.locationCoordinate.longitude];
    CLLocationDistance distance = [currentLocation distanceFromLocation:placeLocation];
    if (distance <= 160.01) {
        [self openCameraApp];
        
        
    }else if (distance >= 160.05){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sorry!" message:@"you need to be at the court to take a picture" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:dismiss];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateLocation:(NSNotification *)notif{
    
    [self.playerCollectionView reloadData];
}

#pragma mark -camera methods
-(void)openCameraApp{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        
        [self presentViewController:picker animated:YES completion:NULL];
        
    } else {
        
        UIAlertController *noCamera = [UIAlertController alertControllerWithTitle:@"Alert!" message:@"Must have a camera." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        }];
        
        [noCamera addAction:action];
        
        [self presentViewController:noCamera animated:YES completion:nil];
    }
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.placeImageView.image = chosenImage;
    self.takePictureLabel.hidden = YES;
    NSData *imageData = UIImagePNGRepresentation(self.placeImageView.image);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query whereKey:@"name" equalTo:self.navigationItem.title];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        self.placeImageView.userInteractionEnabled = NO;
        [object setObject:imageFile forKey:@"locationImage"];
        [object saveInBackground];
    }];
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

#pragma mark -uitextfield delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.scheduleGameTextField) {
        self.saveAddPlayersButton.hidden = YES;
        self.saveScheduleButton.hidden = NO;
        
    }else{
        self.saveScheduleButton.hidden = YES;
        self.saveAddPlayersButton.hidden = NO;
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.numberOfTapsRequired = 1.0;
    [self.view addGestureRecognizer:tap];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField.text.length < 1) {
        self.saveScheduleButton.hidden = YES;
        self.saveAddPlayersButton.hidden = YES;
    }
    
    return YES;
}

- (UIDatePicker *)configureDatePicker
{
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.minimumDate = [NSDate date];
    datePicker.minuteInterval = 15;
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    [datePicker addTarget:self action:@selector(handleDatePickerValueChanged:)forControlEvents:UIControlEventValueChanged];
    
    
    return datePicker;
}



-(void)handleDatePickerValueChanged:(UIDatePicker *)datePicker
{
    NSDate *date = datePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
    self.scheduleGameTextField.text = [dateFormat stringFromDate:date];
    
}


#pragma mark - uipickerview delegates and data methods

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.numberPickerArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    return self.numberPickerArray[row];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.addNumberOfPlayersTextField.text = self.numberPickerArray[row];
    
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}
#pragma mark - save button methods
- (IBAction)handleSaveScheduledGamePressed:(id)sender {
    UIDatePicker *datePicker = (UIDatePicker *)self.scheduleGameTextField.inputView;
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query whereKey:@"name" equalTo:self.navigationItem.title];
    self.saveScheduleButton.enabled = NO;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [object setObject:[PFUser currentUser].username forKey:@"userWhoScheduledGame"];
        [object addUniqueObject:datePicker.date forKey:@"scheduledGames"];
        [object saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (success) {
                self.saveScheduleButton.hidden = YES;
                [self hideKeyboard];
                self.scheduleGameTextField.text = @"Got it, thanks.";
                [self.tableView reloadData];
                //Need this to be a cloud call to delete scheduled game after the time has passed.
            }else{
                NSLog(@"%@", error);
            }
        }];
    }];
}

- (IBAction)handleAddNumberOfPlayersButtonPressed:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    [query whereKey:@"name" equalTo:self.navigationItem.title];
    self.saveAddPlayersButton.enabled = NO;
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        object[@"numberOfExtraPlayers"] = self.addNumberOfPlayersTextField.text;
        [object saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            if (success) {
                self.saveAddPlayersButton.hidden = YES;
                [self hideKeyboard];
                self.addNumberOfPlayersTextField.text = @"Got it!" ;
                [self.tableView reloadData];
            }else{
                NSLog(@"%@", error);
            }
        }];
    }];
}

#pragma mark - tableview delgates and methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.scheduledGamesArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ScheduledGamesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduledGamesTableView"];
    NSDate *date = self.scheduledGamesArray[indexPath.row];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"MMM dd, yyyy hh:mm a"];
    NSString *string = [dateFormat stringFromDate:date];
    NSString *username = self.placeObject[@"userWhoScheduledGame"];
    cell.title.text = [NSString stringWithFormat:@"%@ set up a game for %@", username, string];
    
        return cell;
 
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[PFUser currentUser].username isEqualToString:self.placeObject[@"userWhoScheduledGame"]]) {
        return YES;
    }else{
        return NO;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.0f;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Scheduled games at this locations";
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.scheduledGamesArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
       //This needs to be a cloud call to delete scheduled time and user name
    }
}

#pragma mark - navigation


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ShowUserDetail"]) {
        NSDictionary *user = (NSDictionary *)sender;
        NSString *username = user[@"username"];
        NSString *experience = user[@"experience"];
        PFFile *file = user[@"profileImage"];
        //NSDate *date = user[@"birthDate"];
        
        UserDetailViewController *dvc = [segue destinationViewController];
        
        //dvc.ageLabel.text = age;
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                dvc.profileImageView.image = image;
                
            }
        }];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        dvc.username = username;
        dvc.experience = experience;
        
        
    }

}
@end
