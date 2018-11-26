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

-(UIFont*)boldFontFromFont:(UIFont *)font
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    return [UIFont fontWithDescriptor:fontD size:0];
}

-(UIFont*)italicFontFromFont:(UIFont *)font
{
    UIFontDescriptor * fontD = [font.fontDescriptor
                                fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    return [UIFont fontWithDescriptor:fontD size:0];
}

- (void) setBook:(Book *)book
{    
    self.textLabel.text = book.title;
    self.detailTextLabel.text = book.author;

    self.progressView.progress = book.percentComplete;

    self.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    
    if (book.percentComplete > 0)
    {
        if (book.percentComplete < 1.0)
        {
            // Books currently being read are bold
            self.textLabel.font = [self boldFontFromFont:self.textLabel.font];
        }
    }
}

@end
