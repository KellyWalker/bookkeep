//
//  ViewBookGroupDetailsViewController.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/9/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "ViewBookGroupDetailsViewController.h"
#import "ViewBookDetailsViewController.h"
#import "BookGroupBooksViewController.h"
#import "AddOrEditBookGroupViewController.h"
#import "BookTableViewCell.h"
#import "BookLibrary.h"
#import "Book.h"
#import "BookGroup+API.h"

@interface ViewBookGroupDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageCountContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pagesReadContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentCompleteContentsLabel;

@end

@implementation ViewBookGroupDetailsViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadBookGroupDetails];
}

- (void) loadBookGroupDetails
{
    if (self.bookGroup)
    {
        self.nameContentsLabel.text = self.bookGroup.name;
        self.pageCountContentsLabel.text = [NSString stringWithFormat:@"%d", (int)self.bookGroup.pageTotalCount];
        self.pagesReadContentsLabel.text = [NSString stringWithFormat:@"%d", (int)self.bookGroup.pageReadCount];
        self.percentCompleteContentsLabel.text = [NSString stringWithFormat:@"%2.0f", self.bookGroup.percentComplete * 100];
   }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[BookGroupBooksViewController class]])
    {
        ((BookGroupBooksViewController*)[segue destinationViewController]).bookGroup = self.bookGroup;
    }
    else if ([[segue destinationViewController] isKindOfClass:[AddOrEditBookGroupViewController class]])
    {
        ((AddOrEditBookGroupViewController*)[segue destinationViewController]).bookGroup = self.bookGroup;
    }
}

@end
