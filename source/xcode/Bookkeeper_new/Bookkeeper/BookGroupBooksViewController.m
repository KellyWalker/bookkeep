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
        NSFetchRequest* fetchBooksForBookGroup = [[BookLibrary sharedBookLibrary] createFetchRequestForBooksSortedByUserPreferredBookSortOrder];
        fetchBooksForBookGroup.predicate = [NSPredicate predicateWithFormat:@"ANY bookGroups == %@", self.bookGroup];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchBooksForBookGroup
                                                                           managedObjectContext:self.bookGroup.managedObjectContext
                                                                             sectionNameKeyPath:nil
                                                                                      cacheName:nil];
    }
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Books";
}

@end
