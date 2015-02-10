//
//  FindGamesByTimeTableViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 1/29/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "FindGamesByTimeTableViewController.h"

@interface FindGamesByTimeTableViewController ()

@end

@implementation FindGamesByTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(retrieveFromParse)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) retrieveFromParse {
    
    PFQuery *retrieveGames = [PFQuery queryWithClassName:@"Games"];
    [retrieveGames findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"%@", objects);
            self.gameTimesArray = [[NSArray alloc]initWithArray:objects];
        }
        [self.gameTime reloadData];
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
    return self.gameTimesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 66;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //The actual code to return each cell, configured with the data you want to display.
    
    static NSString *CellIdentifier = @"TimeCell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *tempObject = [self.gameTimesArray objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:CellIdentifier];
    }

    
    cell.textLabel.text = [tempObject objectForKey:@"name"];
    
    
    return cell;
    
    
}

#pragma -mark
#pragma TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell tapped");
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
