//
//  ViewBookDetailsViewController.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/9/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "ViewBookDetailsViewController.h"
#import "Book+API.h"
#import "BookLibrary.h"
#import "AddOrEditBookViewController.h"

@interface ViewBookDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pageCountContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *startingPageContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *readablePageCountContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPageContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pagesReadContentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *percentCompleteContentsLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIStepper *currentPageStepper;

@end

@implementation ViewBookDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do not show empty cells below stats
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadBookDetails];
}

- (void) loadBookDetails
{
    if (self.book)
    {
        self.titleContentsLabel.text = self.book.title;
        self.authorContentsLabel.text = self.book.author;
        self.pageCountContentsLabel.text = [NSString stringWithFormat:@"%d", [self.book.pageTotalCount intValue]];
        self.startingPageContentsLabel.text = [NSString stringWithFormat:@"%d", [self.book.pageStart intValue]];
        self.readablePageCountContentsLabel.text = [NSString stringWithFormat:@"%d", (int)self.book.pageReadableCount];

        [self loadBookProgressStats];
        
        self.currentPageStepper.minimumValue = [self.book.pageStart integerValue];
        self.currentPageStepper.maximumValue = [self.book.pageTotalCount integerValue];
        self.currentPageStepper.value = [self.book.pageLastRead integerValue];
        
        self.progressSlider.minimumValue = [self.book.pageStart integerValue];
        self.progressSlider.maximumValue = [self.book.pageTotalCount integerValue];
        self.progressSlider.value = [self.book.pageLastRead integerValue];
    }
}

- (void) loadBookProgressStats
{
    self.currentPageContentsLabel.text = [NSString stringWithFormat:@"%d", [self.book.pageLastRead intValue]];
    self.pagesReadContentsLabel.text = [NSString stringWithFormat:@"%d", (int)self.book.pageReadCount];
    self.percentCompleteContentsLabel.text = [NSString stringWithFormat:@"%2.0f", self.book.percentComplete * 100];

    self.currentPageStepper.value = [self.book.pageLastRead integerValue];
    self.progressSlider.value = [self.book.pageLastRead integerValue];
}

- (IBAction)currentPageStepperValueChanged:(id)sender
{
    self.book.pageLastRead = [NSNumber numberWithInt:(int)self.currentPageStepper.value];
    [self loadBookProgressStats];
    
    [[BookLibrary sharedBookLibrary] notifyChange];
}

- (IBAction)progressSliderValueChanged:(id)sender
{
    self.book.pageLastRead = [NSNumber numberWithInt:(int)self.progressSlider.value];
    [self loadBookProgressStats];
    
    [[BookLibrary sharedBookLibrary] notifyChange];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"";
    }
    else
    {
        return @"Progress";
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[AddOrEditBookViewController class]])
    {
        self.tabBarController.tabBar.hidden = YES;
        
        ((AddOrEditBookViewController*)[segue destinationViewController]).book = self.book;
    }
}

@end
