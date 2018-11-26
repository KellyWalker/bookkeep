//
//  ViewBooksNewViewController.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/5/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "ViewBooksViewController.h"
#import "AddOrEditBookViewController.h"
#import "ViewBookDetailsViewController.h"
#import "AddOrEditBookGroupViewController.h"
#import "BookTableViewCell.h"
#import "BookkeepDatabaseAvailability.h"
#import "BookLibrary.h"
#import "Book.h"
#import "Book+API.h"

#define TrashActionSheetTag 0
#define SortActionSheetTag 1

#define DeleteButtonTitle @"Delete"

#define SortByTitleButtonTitle @"Sort by Title"
#define SortByAuthorLastNameButtonTitle @"Sort by Author Last Name"
#define SortByAuthorFirstNameButtonTitle @"Sort by Author First Name"
#define SortByDateAddedButtonTitle @"Sort by Date Added"

@interface ViewBooksViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBookButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@end

@implementation ViewBooksViewController

@synthesize managedObjectContext = _managedObjectContext;

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;

    [self fetchBooksInUserPreferredBookSortOrder];
}

- (void) awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserverForName:BookkeepDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification* note){
                                                      self.managedObjectContext = note.userInfo[BookkeepDatabaseAvailabilityContext];
                                                  }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    self.allowBookSelectionToDetails = YES;
    
    // Add sort button to navigation bar
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonClicked:)];
    NSArray *rightButtonsArray = [[NSArray alloc] initWithObjects:self.addBookButton, sortButton, nil];
    self.navigationItem.rightBarButtonItems = rightButtonsArray;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    
    [self updateEditButton];
    [self updateEditToolbarButtons];
}

- (void) fetchBooksInUserPreferredBookSortOrder
{
    NSFetchRequest* fetchAllBooks = [[BookLibrary sharedBookLibrary] createFetchRequestForBooksSortedByUserPreferredBookSortOrder];
    NSString* sectionNameKeyPath = [[BookLibrary sharedBookLibrary] getFetchedResultsSectionNameKeyPathForBooksForUserPreferredSortOrder];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchAllBooks
                                                                       managedObjectContext:self.managedObjectContext
                                                                         sectionNameKeyPath:sectionNameKeyPath
                                                                                  cacheName:nil];
}

- (void) deleteSelectedBooks
{
    NSArray* indexPathsForSelectedRows = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath* indexPath in indexPathsForSelectedRows)
    {
        Book* book = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[BookLibrary sharedBookLibrary] deleteBook:book];
    }

    if ([[BookLibrary sharedBookLibrary] bookCount] == 0)
    {
        self.editing = NO;
    }
    
    [self updateEditButton];
    [self updateEditToolbarButtons];

    [[BookLibrary sharedBookLibrary] notifyChange];
}

- (void) updateEditButton
{
    self.editButtonItem.enabled = [self.tableView numberOfSections] > 0 && [self.tableView numberOfRowsInSection:0] > 0;
}

- (void) updateEditToolbarButtons
{
    BOOL anySelected = self.tableView.indexPathsForSelectedRows.count > 0;
    
    self.trashButton.enabled = anySelected;
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    self.addBookButton.enabled = !editing;

    [self updateEditToolbarButtons];
    
    self.navigationController.toolbarHidden = !editing;
    //self.tabBarController.tabBar.hidden = editing;
}

- (IBAction)trashButtonClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:DeleteButtonTitle
                                                    otherButtonTitles:nil];
    actionSheet.tag = TrashActionSheetTag;
    [actionSheet showInView:self.view];
}

- (IBAction)sortButtonClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:SortByTitleButtonTitle,
                                                                      SortByAuthorLastNameButtonTitle,
                                                                      SortByAuthorFirstNameButtonTitle,
                                                                      SortByDateAddedButtonTitle,
                                                                      nil];
    actionSheet.tag = SortActionSheetTag;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
 
    if (actionSheet.tag == SortActionSheetTag && ![buttonTitle isEqualToString:@"Cancel"])
    {
        BookSortOrder newUserPreferredBookSortOrder = BookSortOrderTitle;
        
        if ([buttonTitle isEqualToString:SortByTitleButtonTitle])
        {
            newUserPreferredBookSortOrder = BookSortOrderTitle;
        }
        else if ([buttonTitle isEqualToString:SortByAuthorLastNameButtonTitle])
        {
            newUserPreferredBookSortOrder = BookSortOrderAuthorLastName;
        }
        else if ([buttonTitle isEqualToString:SortByAuthorFirstNameButtonTitle])
        {
            newUserPreferredBookSortOrder = BookSortOrderAuthorFirstName;
        }
        else if ([buttonTitle isEqualToString:SortByDateAddedButtonTitle])
        {
            newUserPreferredBookSortOrder = BookSortOrderDateAdded;
        }
        
        [[BookLibrary sharedBookLibrary] setUserPreferredBookSortOrder:newUserPreferredBookSortOrder];
        [self fetchBooksInUserPreferredBookSortOrder];
        
        self.editing = NO;
    }
    else if (actionSheet.tag == TrashActionSheetTag)
    {
        if ([buttonTitle isEqualToString:DeleteButtonTitle])
        {
            [self deleteSelectedBooks];
        }
    }
}

#pragma mark - Table view data source

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // If a book header has been set, use it for just the first section; otherwise do not show headers
    if (self.booksTableHeader)
    {
        if (section == 0)
        {
            return self.booksTableHeader;
        }
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateEditButton];
}

- (void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateEditButton];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateEditToolbarButtons];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateEditToolbarButtons];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([[segue destinationViewController] isKindOfClass:[AddOrEditBookViewController class]])
    {
        self.tabBarController.tabBar.hidden = YES;
    }
}

@end
