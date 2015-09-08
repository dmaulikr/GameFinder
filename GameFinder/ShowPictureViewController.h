//
//  ShowPictureViewController.h
//  GameFinder
//
//  Created by Nick Reeder on 9/8/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowPictureViewController : UIViewController
@property NSURL *pictureUrl;
@property (weak, nonatomic) IBOutlet UIImageView *showImageImageView;

@end
