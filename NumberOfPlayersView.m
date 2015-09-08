//
//  NumberOfPlayersView.m
//  GameFinder
//
//  Created by Nick Reeder on 9/4/15.
//  Copyright (c) 2015 Nick Reeder. All rights reserved.
//

#import "NumberOfPlayersView.h"

@implementation NumberOfPlayersView

-(id) init{
    self = [super init];
    if (self) {
      
        self.frame = CGRectMake(0 , 0, 20, 20);
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2.0f;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = self.frame.size.width/2;
     
    }
    return self;
}
@end
