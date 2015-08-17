//
//  SearchResultsTableViewController.m
//  GameFinder
//
//  Created by Nick Reeder on 8/15/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "SearchResultsTableViewController.h"
#import "LocationSearchResultsTableViewCell.h"


@interface SearchResultsTableViewController ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation SearchResultsTableViewController


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.dictionary = [self.searchResults objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"SearchResultsCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = nil;
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        cell.textLabel.text = self.dictionary[@"name"];
        cell.detailTextLabel.text = self.dictionary[@"address"];
    }

    return cell;
}


@end
