//
//  ViewBooksNewViewController.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/5/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "ViewBookGroupsViewController.h"
#import "AddOrEditBookGroupViewController.h"
#import "ViewBookGroupDetailsViewController.h"
#import "BookGroupTableViewCell.h"
#import "BookkeepDatabaseAvailability.h"
#import "BookLibrary.h"
#import "Book.h"

#define TrashActionSheetTag 0
#define SortActionSheetTag 1

#define DeleteButtonTitle @"Delete"

#define SortByNameButtonTitle @"Sort by Name"
#define SortByDateAddedButtonTitle @"Sort by Date Added"

@interface ViewBookGroupsViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBookGroupButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;

@end

@implementation ViewBookGroupsViewController

@synthesize managedObjectContext = _managedObjectContext;

- (void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    [self fetchBookGroupsInUserPreferredBookGroupSortOrder];
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
    
    // Add sort button to navigation bar
    UIBarButtonItem *sortButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(sortButtonClicked:)];
    NSArray *rightButtonsArray = [[NSArray alloc] initWithObjects:self.addBookGroupButton, sortButton, nil];
    self.navigationItem.rightBarButtonItems = rightButtonsArray;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
    
    [self updateEditButton];
    [self updateEditToolbarButtons];
    
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.editing = NO;
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

    self.addBookGroupButton.enabled = !editing;

    [self updateEditToolbarButtons];

    self.navigationController.toolbarHidden = !editing;
    //self.tabBarController.tabBar.hidden = editing;
}

- (void) fetchBookGroupsInUserPreferredBookGroupSortOrder
{
    NSFetchRequest* fetchAllBookGroups = [[BookLibrary sharedBookLibrary] createFetchRequestForBookGroupsSortedByUserPreferredBookGroupSortOrder];
    NSString* sectionNameKeyPath = [[BookLibrary sharedBookLibrary] getFetchedResultsSectionNameKeyPathForBookGroupsForUserPreferredSortOrder];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchAllBookGroups
                                                                       managedObjectContext:self.managedObjectContext
                                                                         sectionNameKeyPath:sectionNameKeyPath
                                                                                  cacheName:nil];
}

- (void) deleteSelectedBookGroups
{
    NSArray* indexPathsForSelectedRows = [self.tableView indexPathsForSelectedRows];
    
    for (NSIndexPath* indexPath in indexPathsForSelectedRows)
    {
        BookGroup* bookGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[BookLibrary sharedBookLibrary] deleteBookGroup:bookGroup];
    }
    
    if ([[BookLibrary sharedBookLibrary] bookGroupCount] == 0)
    {
        self.editing = NO;
    }
    
    [self updateEditButton];
    [self updateEditToolbarButtons];

    [[BookLibrary sharedBookLibrary] notifyChange];
}

- (IBAction)sortButtonClicked:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:SortByNameButtonTitle,
                                                                      SortByDateAddedButtonTitle,
                                                                      nil];
    actionSheet.tag = SortActionSheetTag;
    [actionSheet showInView:self.view];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (actionSheet.tag == SortActionSheetTag && ![buttonTitle isEqualToString:@"Cancel"])
    {
        BookGroupSortOrder newUserPreferredBookGroupSortOrder = BookGroupSortOrderName;
        
        if ([buttonTitle isEqualToString:SortByNameButtonTitle])
        {
            newUserPreferredBookGroupSortOrder = BookGroupSortOrderName;
        }
        else if ([buttonTitle isEqualToString:SortByDateAddedButtonTitle])
        {
            newUserPreferredBookGroupSortOrder = BookGroupSortOrderDateAdded;
        }
        
        [[BookLibrary sharedBookLibrary] setUserPreferredBookGroupSortOrder:newUserPreferredBookGroupSortOrder];
        [self fetchBookGroupsInUserPreferredBookGroupSortOrder];
        
        self.editing = NO;
    }
    else if (actionSheet.tag == TrashActionSheetTag)
    {
        if ([buttonTitle isEqualToString:DeleteButtonTitle])
        {
            [self deleteSelectedBookGroups];
        }
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    BookGroupTableViewCell *cell = (BookGroupTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    BookGroup* bookGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.bookGroup = bookGroup;
    
    return cell;
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

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Do not show section headers since they are just the names of the groups when sorted by name
    return nil;
}

#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"viewBookGroupDetailsSegue"])
    {
        return !self.editing;
    }
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[AddOrEditBookGroupViewController class]])
    {
        self.tabBarController.tabBar.hidden = YES;
    }
    else if ([[segue destinationViewController] isKindOfClass:[ViewBookGroupDetailsViewController class]])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        BookGroup* bookGroup = [self.fetchedResultsController objectAtIndexPath:indexPath];
        ((ViewBookGroupDetailsViewController*)[segue destinationViewController]).bookGroup = bookGroup;
    }
}

@end
