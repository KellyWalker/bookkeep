//
//  BookGroupTableViewCell.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/11/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookGroup.h"
#import "ProgressTableViewCell.h"

@interface BookGroupTableViewCell : ProgressTableViewCell

@property (weak, nonatomic) BookGroup* bookGroup;

@end
