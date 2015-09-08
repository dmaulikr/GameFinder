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
#import "EditLocationViewController.h"
#import "PlacePictureCustomCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "CustomCollectionViewLayout.h"
#import "ShowPictureViewController.h"

@interface PlaceDetailViewController ()


@end

@implementation PlaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self isNear];
    self.navigationItem.title = self.titleString;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.takePictureButton.layer.cornerRadius = 4.0;
    self.takePictureButton.layer.borderWidth = 1.0;
    self.takePictureButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.takePictureButton.clipsToBounds = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocation:) name:@"updatedLocation" object:nil];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self checkForIconImages];
    self.picturesArray = [self.placeObject objectForKey:@"pictureArray"];
    
    if (self.picturesArray.count <1) {
        self.pictureCollectionView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"collectionViewBG"]];
    }
    self.playersArray = [self.placeObject objectForKey:@"players"];
    
    
    [self.pictureCollectionView reloadData];
    [self.playerCollectionView reloadData];
    
}


-(void)viewDidAppear:(BOOL)animated{
}


#pragma mark
#pragma CollectionView DataSources

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell = nil;
    if (collectionView == self.playerCollectionView) {
        static NSString *CellIdentifier = @"PlayersCollectionViewCell";
        NSDictionary *player = self.playersArray[indexPath.row];
        
        
        PlaceDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        PFFile *file = player[@"profileImage"];
        NSURL *url = [NSURL URLWithString:file.url];
        [cell.playerProfileImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"hooper"] options:SDWebImageRefreshCached];
        cell.layer.cornerRadius = 40;
        cell.playerProfileImageView.clipsToBounds = YES;
        cell.layer.borderColor = [UIColor colorWithRed:0.18f green:0.81f blue:0.41f alpha:1.0f].CGColor;
        cell.layer.borderWidth = 2.0f;
        
        cell.playerUsernameLabel.text = player[@"username"];
        return cell;
        
    }if (collectionView == self.pictureCollectionView){
        static NSString *CellIdentifier = @"PlacePicturesCollectionViewCell";
        
        PFFile *file = self.picturesArray[indexPath.row];
        NSURL *url = [NSURL URLWithString:file.url];
        
        PlacePictureCustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        [cell.placePictureImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"collectionViewBG"] options:SDWebImageDelayPlaceholder];
        cell.placePictureImageView.clipsToBounds = YES;
        
        cell.layer.borderColor = [UIColor colorWithRed:0.18f green:0.81f blue:0.41f alpha:1.0f].CGColor;
        cell.layer.borderWidth = 2.0;
        
        return cell;
        
    }
    
    return cell;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    if (collectionView == self.playerCollectionView) {
        return self.playersArray.count;
    }
    else {
        
        return self.picturesArray.count;
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        PlayersHeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        headerView.title.text = @"People playing here right now";
        headerView.frame = CGRectMake(0, 0, self.playerCollectionView.bounds.size.width, 50);
        headerView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        headerView.layer.borderWidth = 1.0f;
        reusableview = headerView;
    }
    
    return reusableview;
}

#pragma -mark
#pragma CellectionView Delegates

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (collectionView == self.playerCollectionView) {
        PFObject *object = [self.playersArray objectAtIndex:indexPath.row];
        //Send that object along to the segue
        [self performSegueWithIdentifier:@"ShowUserDetail" sender:object];
    }
    if (collectionView == self.pictureCollectionView) {
        PFFile *file = [self.picturesArray objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"ShowPictures" sender:file];
    }
}

#pragma mark <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.pictureCollectionView) {
        return CGSizeMake(collectionView.frame.size.width-10, collectionView.frame.size.height-10);
    }else{
        return CGSizeMake(80, 80);
    }
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
    if (distance <= 500) {
        self.takePictureButton.hidden = NO;
        
        self.isCloseEnough = YES;
        
    }else if (distance >= 500){
        self.isCloseEnough = NO;
        self.takePictureButton.hidden = YES;
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
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [self.placeObject addUniqueObject:imageFile forKey:@"pictureArray"];
    [self.placeObject saveInBackground];
    
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


-(void)hideKeyboard{
    [self.view endEditing:YES];
}

#pragma mark - navigation


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ShowUserDetail"]) {
        PFObject *user = (PFObject *)sender;
        NSString *username = user[@"username"];
        NSString *experience = user[@"experience"];
        NSString *oftenPlay = user[@"oftenPlay"];
        PFFile *file = user[@"profileImage"];
        NSURL *url = [NSURL URLWithString:file.url];
        NSDate *date = user[@"birthDate"];
        NSDate* now = [NSDate date];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSCalendarUnitYear
                                           fromDate:date
                                           toDate:now
                                           options:0];
        NSInteger age = [ageComponents year];
        
        UserDetailViewController *dvc = [segue destinationViewController];
        
        //dvc.ageLabel.text = age;
        [dvc.profileImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"hooper"] options:SDWebImageHighPriority];
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
        dvc.oftenPlay = oftenPlay;
        dvc.years = age;
        
        
        
    }else if ([[segue identifier]isEqualToString:@"EditLocation"]){
        PFObject *place = (PFObject *)sender;
        NSString *name = place[@"name"];
        
        NSNumber *coveredBool = place[@"covered"];
        NSNumber *outdoorBool = place[@"outdoor"];
        NSNumber *lightsBool = place[@"lights"];
        NSNumber *publicBool = place[@"openToPublic"];
        
        
        EditLocationViewController *editLocationViewController = [segue destinationViewController];
        
        editLocationViewController.nameString = name;
        editLocationViewController.originalName = name;
        editLocationViewController.coveredBool = coveredBool;
        editLocationViewController.lightBool = lightsBool;
        editLocationViewController.publicBool = publicBool;
        editLocationViewController.outdoorBool = outdoorBool;
        editLocationViewController.placeObject = place;
        
    }else if ([[segue identifier]isEqualToString:@"ShowPictures"]){
        PFFile *file = (PFFile *)sender;
        
        ShowPictureViewController *dvc = [segue destinationViewController];
        dvc.pictureUrl = [NSURL URLWithString:file.url];
        
    }
    
}


-(void)passObject:(PFObject *)object{
    
    [self performSegueWithIdentifier:@"EditLocation" sender:object];
    
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (UIEventSubtypeMotionShake) {
        
        [self performSelector:@selector(passObject:) withObject:self.placeObject];
        
    }
}
- (IBAction)handleTakePictureButtonPressed:(id)sender {
    [self openCameraApp];
}


-(void)checkForIconImages{
    if ([self.outdoorString isEqual:@(1)]) {
        self.indoorImageView.image = [UIImage imageNamed:@"outdoor"];
    }else{
        self.indoorImageView.image = [UIImage imageNamed:@"indoor"];
    }if ([self.coveredString isEqual:@(1)]) {
        self.coveredImageView.image = [UIImage imageNamed:@"covered"];
    }else{
        self.coveredImageView.image = [UIImage imageNamed:@"not-covered"];
    }if ([self.publicString isEqual:@(1)]) {
        self.publicImageView.image = [UIImage imageNamed:@"public"];
    }else{
        self.publicImageView.image = [UIImage imageNamed:@"private"];
    }if ([self.lightString isEqual:@(1)]) {
        self.lightImageView.image = [UIImage imageNamed:@"lights"];
    }else{
        self.lightImageView.image = [UIImage imageNamed:@"no-lights"];
    }
    
}

@end
