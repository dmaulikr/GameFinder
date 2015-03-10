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

@interface PlaceDetailViewController ()

@end

@implementation PlaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrievePlayers) name:@"stillPlaying" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePlayer) name:@"notPlaying" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocation:) name:@"updatedLocation" object:nil];
    
    
    
    self.nameLabel.text = self.locationNameString;
    
    self.typeLabel.text = self.locationTypeString;
    
    
    [self performSelector:@selector(isNear)];
    [self performSelector:@selector(retrievePlayers)];
    [self.mapDetailView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.locationCoordinate.latitude, self.locationCoordinate.longitude), MKCoordinateSpanMake(0.0004, 0.0004))];
    self.mapDetailView.userInteractionEnabled = NO;
    self.mapDetailView.mapType = MKMapTypeSatellite;
    
}



-(void)retrievePlayers{
    
    PFGeoPoint *locationPoint = [PFGeoPoint geoPointWithLatitude:self.locationCoordinate.latitude longitude:self.locationCoordinate.longitude];
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"location" nearGeoPoint:locationPoint withinMiles:0.01];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (id object in objects) {
                NSArray *players = [object objectForKey:@"players"];
                if ([players containsObject:user.username]) {
                    self.playHereButton.enabled = NO;
                    [self.playHereButton setTitle:@" " forState:UIControlStateDisabled];
                    [self.playHereButton setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
                    [self.playHereButton setBackgroundImage:[UIImage imageNamed:@"player_check"] forState:UIControlStateDisabled];
                    [self.playHereButton setBackgroundColor:[UIColor clearColor]];
                    self.isCheckedIn = YES;
                }else{
                    self.playHereButton.enabled = YES;
                    self.isCheckedIn = NO;
                    
                }
                self.playersArray = [[NSArray alloc]initWithArray:players];
                NSLog(@"players are %@",players);
            }dispatch_async(dispatch_get_main_queue(), ^{
                [self.playersTableView reloadData];
            });
        }
        
    }];
    
}

- (IBAction)openMaps:(id)sender {
    
    if  ([[[UIDevice currentDevice] systemVersion] floatValue]< 8.0){
        UIActionSheet *uas = [[UIActionSheet alloc] initWithTitle:@"Open in Maps?" delegate:self cancelButtonTitle:@"Cancel"
            destructiveButtonTitle:nil
            otherButtonTitles:nil];
        
        [uas showInView:self.view];
        
    } else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Open in Maps" message:@"You will be directed from Game Finder." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *cancel) {
            
        }];

        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            CLLocationCoordinate2D placeLocation = CLLocationCoordinate2DMake(self.locationCoordinate.latitude, self.locationCoordinate.longitude);
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:placeLocation addressDictionary:nil];
            MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
            item.name = self.locationNameString;
            [item openInMapsWithLaunchOptions:nil];
        }];
    
        [alert addAction:cancel];
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark
#pragma TableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //returns the number of sections you need.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //how many rows are in each of the above sections (Total number of cells needing to be displayed).
    return self.playersArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //This sets the size of the cell at any given index.
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //The actual code to return each cell, configured with the data you want to display.
    
    static NSString *CellIdentifier = @"TimeCell";
    
    PlaceDetailCustomTableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *tempObject = [self.playersArray objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[PlaceDetailCustomTableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    
    cell.title.text = tempObject;
    cell.detail.text = @"is playing here.";
    cell.detail.textAlignment = NSTextAlignmentLeft;
    // Configure the cell.
    
    return cell;
    
    
}

#pragma -mark
#pragma TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //This delegate method gets call when a user taps a TableView cell. This method sends the index of the tapped cell in the indexpath argument.
    
    //Show an animated deselection of the selected cell.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (IBAction)playHereButton:(id)sender {
    
    PFUser *user = [PFUser currentUser];

    
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.locationCoordinate.latitude longitude:self.locationCoordinate.longitude];

    [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:0.01];
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            PFObject *postObject = [objects lastObject];
            
            [postObject addUniqueObject:user.username forKey:@"players"];
            [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self retrievePlayers];
                        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:20];
                        localNotification.alertBody = @"Are you still playing?";
                        localNotification.timeZone = [NSTimeZone defaultTimeZone];
                        localNotification.applicationIconBadgeNumber = 0;
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                        //[self setTimer];
                    });
                    
                }
                
            }];
            
        }
       
    }];
    
}

-(void)removePlayer{
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Games"];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:self.locationCoordinate.latitude longitude:self.locationCoordinate.longitude];
 
    [query whereKey:@"location" nearGeoPoint:geoPoint withinMiles:0.01];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            PFObject *players = [objects lastObject];
            
            [players removeObject:user.username forKey:@"players"];
            [players saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self retrievePlayers];
                        
                    });
                }
            }];
   
            
        }
        
        
    }];
    
}

-(void)updateLocation:(NSNotification *)notif{
    [self isNear];
    [self.playersTableView reloadData];
}

-(void)isNear{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CLLocation *currentLocation = appDelegate.locationManager.currentLocation;
    CLLocation *placeLocation = [[CLLocation alloc]initWithLatitude:self.locationCoordinate.latitude longitude:self.locationCoordinate.longitude];
    CLLocationDistance distance = [currentLocation distanceFromLocation:placeLocation];
    if (distance <= 160.01 &&  !self.isCheckedIn) {
        self.playHereButton.hidden = NO;

        
    }else if (distance >= 160.05){
        self.playHereButton.hidden = YES;
        [self removePlayer];
    }
    [self.playersTableView reloadData];
}

//-(void)setTimer{
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:2400 target:self selector:@selector(removePlayer) userInfo:nil repeats:1];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
//    NSLog(@"time remaining is %f", self.timer.fireDate.timeIntervalSinceNow);
//    
//}



@end
