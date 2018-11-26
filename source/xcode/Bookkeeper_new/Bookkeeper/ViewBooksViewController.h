//
//  ViewBooksNewViewController.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/5/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "BooksFetchedResultsViewController.h"

@interface ViewBooksViewController : BooksFetchedResultsViewController

@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) NSString* booksTableHeader;

@end
