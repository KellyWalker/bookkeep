//
//  BookTableViewCell.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/11/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "BookTableViewCell.h"
#import "BookLibrary.h"
#import "Book+API.h"

@implementation BookTableViewCell

- (void) setBook:(Book *)book
{    
    self.textLabel.text = book.title;
    self.detailTextLabel.text = book.author;

    self.progressView.progress = book.percentComplete;
}

@end
