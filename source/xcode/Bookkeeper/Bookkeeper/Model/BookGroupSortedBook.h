//
//  BookGroupSortedBook.h
//  bookkeep
//
//  Created by Kelly Walker on 2/1/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book, BookGroup;

@interface BookGroupSortedBook : NSManagedObject

@property (nonatomic, retain) NSNumber * sortIndex;
@property (nonatomic, retain) BookGroup *bookGroup;
@property (nonatomic, retain) Book *book;

@end
