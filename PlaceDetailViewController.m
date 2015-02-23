//
//  PlaceDetailViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 2/12/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "PlaceDetailViewController.h"
#import "Parse/Parse.h"

@interface PlaceDetailViewController ()

@end

@implementation PlaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addressLabel.text = self.address;
    
    self.nameLabel.text = self.locationNameString;
    
    self.cityLabel.text = self.locationCityString;
    
    self.stateLabel.text = self.locationStateString;
    
    self.typeLabel.text = self.locationTypeString;
    
    self.zipLabel.text = self.locationZipString;
    
    [self.mapDetailView setRegion:MKCoordinateRegionMake(CLLocationCoordinate2DMake(self.locationCoordinate.latitude, self.locationCoordinate.longitude), MKCoordinateSpanMake(0.0004, 0.0004))];
    self.mapDetailView.userInteractionEnabled = NO;
    self.mapDetailView.mapType = MKMapTypeSatellite;
    
    
    
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
- (IBAction)parseTest:(id)sender {
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        PFQuery *query = [PFQuery queryWithClassName:@"Games"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            PFUser *user = [PFUser currentUser];
            NSString *playerName = [user objectForKey:@"username"];
            
            PFObject *player = [PFObject objectWithClassName:@"Games"];
            [player setObject:playerName forKey:@"players"];
            
            [player saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"All good.");

                }
                
            }];
        }];
    }];
}

#pragma -mark
#pragma TableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //returns the number of sections you need.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //how many rows are in each of the above sections (Total number of cells needing to be displayed).
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //This sets the size of the cell at any given index.
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //The actual code to return each cell, configured with the data you want to display.
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }
    
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




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
