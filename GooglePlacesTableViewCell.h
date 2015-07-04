//
//  GooglePlacesTableViewCell.h
//  GameFinder
//
//  Created by Nick Reeder on 7/4/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GooglePlacesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *placeImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
