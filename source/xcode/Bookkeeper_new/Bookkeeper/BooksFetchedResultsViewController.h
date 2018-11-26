//
//  BooksFetchedResultsViewController.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/25/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface BooksFetchedResultsViewController : CoreDataTableViewController

@property (nonatomic) BOOL allowBookSelectionToDetails;

// Set fetchedResultsController to a Book fetch
// Name prototype book cell BookCell of type BookTableViewCell

@end
