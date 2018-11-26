//
//  BookTableViewCell.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/11/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "ProgressTableViewCell.h"

@interface BookTableViewCell : ProgressTableViewCell

@property (weak, nonatomic) Book* book;

@end
