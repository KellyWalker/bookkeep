//
//  BooksFetchedResultsViewController.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/25/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "BooksFetchedResultsViewController.h"
#import "BookTableViewCell.h"
#import "ViewBookDetailsViewController.h"
#import "Book+API.h"

@interface BooksFetchedResultsViewController ()

@end

@implementation BooksFetchedResultsViewController

- (void) viewWillDisappear:(BOOL)animated
{
    self.editing = NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookCell";
    BookTableViewCell *cell = (BookTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Book* book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.book = book;
    
    if (self.allowBookSelectionToDetails)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"viewBookDetailsSegue"])
    {
        return !self.editing && self.allowBookSelectionToDetails;
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue destinationViewController] isKindOfClass:[ViewBookDetailsViewController class]])
    {
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        Book* book = [self.fetchedResultsController objectAtIndexPath:indexPath];
        ((ViewBookDetailsViewController*)[segue destinationViewController]).book = book;
    }
}

@end
