//
//  AddLocationViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 7/4/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "AddLocationViewController.h"
#import "GooglePlacesTableViewCell.h"


@interface AddLocationViewController ()

@end

@implementation AddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getPlacesFromGoogle];
    // Do any additional setup after loading the view.
}
#pragma -mark
#pragma TableView datasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //returns the number of sections you need.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //how many rows are in each of the above sections (Total number of cells needing to be displayed).
    return self.placesFoundArray.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //This sets the size of the cell at any given index.
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //The actual code to return each cell, configured with the data you want to display.
    
    static NSString *CellIdentifier = @"PlacesCell";
    
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

-(void)getPlacesFromGoogle{
    
    NSString *urlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=300&sensor=false&keyword=%@&key=AIzaSyCztQb26KkhKbuLQIk48Byyo6u8aTuUlIg",self.currentLocation.latitude, self.currentLocation.longitude,self.searchBar.text];
    
    NSURL  *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSError *jsonError;
        
        NSMutableDictionary *allData = [NSJSONSerialization
                                        JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        NSLog(@"data is: %@", data);
        NSArray *results = [allData objectForKey:@"results"];
        NSLog(@"Results = %@", results);
        NSMutableArray *placesFound = self.placesFoundArray;
        
        if (results.count >= 1){
            
            for (id object in results) {
                
                NSDictionary *places = object;
                
                NSString *name = [places objectForKey:@"name"];
                
                NSString *googlePlacesID = [places objectForKey:@"place_id"];
                
                NSDictionary *geometry = [places objectForKey:@"geometry"];
                
                NSDictionary *location = [geometry objectForKey:@"location"];
                
                NSNumber *lat = [location objectForKey:@"lat"];
                
                NSNumber *lng = [location objectForKey:@"lng"];
                
                CLLocationCoordinate2D latlng = CLLocationCoordinate2DMake(lat.doubleValue, lng.doubleValue);
                
                
                GooglePlacesTableViewCell *customCell = [[GooglePlacesTableViewCell alloc]init];
                customCell.nameLabel.text = name;
                
            
                
            }
            
            
            
            
        }
        
        
        
    }] resume];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
