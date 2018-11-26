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
#import "BookGroupSortedBook.h"
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

- (void)bookTableViewSelectionChanged:(NSNotification*)notification
{
    [self.nameTextField resignFirstResponder];
    
    [self updateDoneButton];
}

- (void) viewDidLoad
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bookTableViewSelectionChanged:) name:UITableViewSelectionDidChangeNotification object:self.embeddedViewBooksViewController.tableView];
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
        
        NSInteger sectionCount = [self.embeddedViewBooksViewController.tableView numberOfSections];

        for (NSInteger iSection = 0; iSection < sectionCount; ++iSection)
        {
            NSInteger bookCount = [self.embeddedViewBooksViewController.tableView numberOfRowsInSection:iSection];
            
            for (NSInteger iBook = 0; iBook < bookCount; ++iBook)
            {
                NSIndexPath *bookIndexPath = [NSIndexPath indexPathForRow:iBook inSection:iSection];
                Book *book = [self.embeddedViewBooksViewController.fetchedResultsController objectAtIndexPath:bookIndexPath];
                
                if ([self.bookGroup containsBook:book])
                {
                    [self.embeddedViewBooksViewController.tableView selectRowAtIndexPath:bookIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
    }
}

- (void) updateDoneButton
{
    self.addBookGroupButton.enabled =
        self.nameTextField.text.length > 0;
}

- (IBAction)touchUpInside:(id)sender
{
    [self.nameTextField resignFirstResponder];
}

- (IBAction)textFieldEditingChanged
{
    [self updateDoneButton];
}

- (IBAction)clickDoneButton:(id)sender
{
    // Get or create book group
    BookGroup* bookGroup = self.bookGroup;
    if (!bookGroup)
    {
        bookGroup = [[BookLibrary sharedBookLibrary] createBookGroup];
    }

    bookGroup.name = self.nameTextField.text;
    [bookGroup updateSortKeys];
    
    // Get all books
    NSMutableSet* books = [[NSMutableSet alloc] init];
    NSArray* indexPathsForSelectedRows = [self.embeddedViewBooksViewController.tableView indexPathsForSelectedRows];
    for (NSIndexPath* indexPath in indexPathsForSelectedRows)
    {
        Book* book = [self.embeddedViewBooksViewController.fetchedResultsController objectAtIndexPath:indexPath];
        
        [books addObject:book];
    }
    
    // Get existing sorted books that will remain in group
    NSMutableArray* sortedBooksRemaining = [[NSMutableArray alloc] init];
    for (Book* book in books)
    {
        BookGroupSortedBook* sortedBook = [bookGroup sortedBookForBook:book];
        if (sortedBook)
        {
            [sortedBooksRemaining addObject:sortedBook];
        }
    }
    
    // Update sort indexes of remaining sorted books
    NSArray* sortedBooksRemainingResorted = [sortedBooksRemaining sortedArrayUsingComparator:^
        NSComparisonResult(BookGroupSortedBook* obj1, BookGroupSortedBook* obj2)
        {
            return [obj1.sortIndex compare:obj2.sortIndex];
        }
     ];
    NSMutableSet* bookGroupSortedBooks = [[NSMutableSet alloc] init];
    for (int newSortIndex = 0; newSortIndex < sortedBooksRemainingResorted.count; ++newSortIndex)
    {
        BookGroupSortedBook* sortedBook = (BookGroupSortedBook*)sortedBooksRemainingResorted[newSortIndex];
        sortedBook.sortIndex = [NSNumber numberWithInt:newSortIndex];
        [bookGroupSortedBooks addObject:sortedBook];
    }
    
    // Add sorted books for books newly added to book group
    for (Book* book in books)
    {
        BookGroupSortedBook* sortedBook = [bookGroup sortedBookForBook:book];
        if (!sortedBook)
        {
            sortedBook = [[BookLibrary sharedBookLibrary] createBookGroupSortedBook];
            sortedBook.book = book;
            sortedBook.bookGroup = bookGroup;
            sortedBook.sortIndex = [NSNumber numberWithUnsignedInteger:bookGroupSortedBooks.count];
            
            [bookGroupSortedBooks addObject:sortedBook];
        }
    }

    bookGroup.sortedBooks = bookGroupSortedBooks;
    
    [[BookLibrary sharedBookLibrary] notifyChange];
    
    // Dismiss view controller
    [self.navigationController popViewControllerAnimated:YES];
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
