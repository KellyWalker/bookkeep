//
//  ReadingProgressTableViewCell.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/12/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "ProgressTableViewCell.h"

@implementation ProgressTableViewCell

- (UIProgressView*) progressView
{
    if (!_progressView)
    {
        _progressView = [[UIProgressView alloc] init];
        [self.contentView addSubview:_progressView];
        
        [self updateProgressViewFrame];
        
    }
    return _progressView;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self updateProgressViewFrame];
}

- (void) updateProgressViewFrame
{
    self.progressView.frame = CGRectMake(self.contentView.bounds.origin.x + 15,
                                         self.contentView.bounds.origin.y + self.contentView.bounds.size.height - 7,
                                         self.contentView.bounds.size.width - 30,
                                         5);
}

@end
