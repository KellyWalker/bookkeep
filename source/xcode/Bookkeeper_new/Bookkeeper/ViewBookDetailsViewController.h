//
//  ViewBookDetailsViewController.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/9/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"

@interface ViewBookDetailsViewController : UITableViewController

@property (weak, nonatomic) Book* book;

@end
