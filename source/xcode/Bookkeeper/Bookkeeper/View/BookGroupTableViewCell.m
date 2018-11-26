//
//  BookGroupTableViewCell.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/11/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "BookGroupTableViewCell.h"
#import "BookLibrary.h"
#import "BookGroup+API.h"

@implementation BookGroupTableViewCell

- (void) setBookGroup:(BookGroup *)bookGroup
{
    self.textLabel.text = bookGroup.name;

    self.progressView.progress = bookGroup.percentComplete;
}

@end
