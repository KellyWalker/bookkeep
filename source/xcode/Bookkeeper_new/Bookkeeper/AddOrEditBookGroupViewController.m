//
//  AddBookGroupViewController.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/9/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "AddOrEditBookGroupViewController.h"
#import "ViewBooksViewController.h"
#import "BookTableViewCell.h"
#import "BookLibrary.h"
#import "BookGroup.h"
#import "BookGroup+API.h"

@interface AddOrEditBookGroupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBookGroupButton;
@property (weak, nonatomic, readonly) ViewBooksViewController* embeddedViewBooksViewController;

@end

@implementation AddOrEditBookGroupViewController

@synthesize embeddedViewBooksViewController = _embeddedViewBooksViewController;

- (ViewBooksViewController*) embeddedViewBooksViewController
{
    return self.childViewControllers.count ? self.childViewControllers[0] : nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadBookGroupDetailsIfEditing];
    [self updateDoneButton];
}

- (void) loadBookGroupDetailsIfEditing
{
    if (self.bookGroup)
    {
        self.title = @"Edit Group";
        
        self.nameTextField.text = self.bookGroup.name;
        
        NSInteger bookCount = [self.embeddedViewBooksViewController.tableView numberOfRowsInSection:0];
        for (NSInteger iBook = 0; iBook < bookCount; ++iBook)
        {
            NSIndexPath *bookIndexPath = [NSIndexPath indexPathForRow:iBook inSection:0];
            Book *book = [self.embeddedViewBooksViewController.fetchedResultsController objectAtIndexPath:bookIndexPath];
            if ([self.bookGroup.books containsObject:book])
            {
                [self.embeddedViewBooksViewController.tableView selectRowAtIndexPath:bookIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    }
}

- (void) updateDoneButton
{
    self.addBookGroupButton.enabled =
        self.nameTextField.text.length > 0;
}
- (IBAction)textFieldEditingChanged
{
    [self updateDoneButton];
}

- (IBAction)clickDoneButton:(id)sender
{
    BookGroup* bookGroup = self.bookGroup;
    if (!bookGroup)
    {
        bookGroup = [[BookLibrary sharedBookLibrary] createBookGroup];
    }

    bookGroup.name = self.nameTextField.text;
    [bookGroup updateSortKeys];
    
    NSMutableSet* books = [[NSMutableSet alloc] init];
    
    NSArray* indexPathsForSelectedRows = [self.embeddedViewBooksViewController.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath* indexPath in indexPathsForSelectedRows)
    {
        Book* book = [self.embeddedViewBooksViewController.fetchedResultsController objectAtIndexPath:indexPath];
        [books addObject:book];
    }

    bookGroup.books = books;
    
    [[BookLibrary sharedBookLibrary] notifyChange];
    
    // Dismiss view controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.nameTextField resignFirstResponder];
    
    [self updateDoneButton];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.nameTextField resignFirstResponder];
    
    [self updateDoneButton];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[ViewBooksViewController class]])
    {
        ViewBooksViewController* vbvc =(ViewBooksViewController*)[segue destinationViewController];
        vbvc.booksTableHeader = @"Books";
        vbvc.managedObjectContext = [[BookLibrary sharedBookLibrary] bookDatabaseContext];
        vbvc.editing = YES;
    }
}

@end
