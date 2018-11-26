//
//  BookGroupBooksViewController.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/24/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "BookGroupBooksViewController.h"
#import "BookTableViewCell.h"
#import "ViewBookDetailsViewController.h"
#import "Book+API.h"
#import "BookLibrary.h"

@interface BookGroupBooksViewController ()

@end

@implementation BookGroupBooksViewController

- (void) viewDidLoad
{
    self.allowBookSelectionToDetails = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self fetchBooksForBookGroup];
    self.editing = YES;
}

- (void) setBookGroup:(BookGroup *)bookGroup
{
    _bookGroup = bookGroup;

    [self fetchBooksForBookGroup];
}

- (void) fetchBooksForBookGroup
{
    if (self.bookGroup)
    {
        NSFetchRequest* fetchSortedBooksInBookGroup = [[BookLibrary sharedBookLibrary] createFetchRequestForBookGroupSortedBooks:self.bookGroup];

        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchSortedBooksInBookGroup
                                                                           managedObjectContext:self.bookGroup.managedObjectContext
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Books";
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    BookGroupSortedBook* bookGroupSortedBook = [self.fetchedResultsController objectAtIndexPath:sourceIndexPath];
    
    NSInteger originalSortIndex = [bookGroupSortedBook.sortIndex integerValue];
    NSInteger newSortIndex = destinationIndexPath.row;
    
    if (originalSortIndex == newSortIndex)
    {
        return;
    }
    
    bookGroupSortedBook.sortIndex = [NSNumber numberWithInteger:newSortIndex];
    
    BOOL isMovedDown = (originalSortIndex - newSortIndex) < 0;
    BOOL isMovedUp = (originalSortIndex - newSortIndex) > 0;
    
    NSInteger minChangedSortIndex = MIN(originalSortIndex, newSortIndex);
    NSInteger maxChangedSortIndex = MAX(originalSortIndex, newSortIndex);
    
    for (BookGroupSortedBook* sortedBook in self.bookGroup.sortedBooks)
    {
        if (sortedBook != bookGroupSortedBook)
        {
            NSInteger sortIndex = [sortedBook.sortIndex integerValue];
            if (sortIndex >= minChangedSortIndex && sortIndex <= maxChangedSortIndex)
            {
                if (isMovedDown)
                {
                    --sortIndex;
                }
                else if (isMovedUp)
                {
                    ++sortIndex;
                }
                
                sortedBook.sortIndex = [NSNumber numberWithInteger:sortIndex];
            }
        }
    }
}

@end
