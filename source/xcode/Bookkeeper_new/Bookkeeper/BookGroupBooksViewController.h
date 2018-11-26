//
//  BookGroupBooksViewController.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/24/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "BooksFetchedResultsViewController.h"
#import "BookGroup.h"

@interface BookGroupBooksViewController : BooksFetchedResultsViewController

@property (weak, nonatomic) BookGroup* bookGroup;

@end
