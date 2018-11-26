//
//  BookGroup.h
//  bookkeep
//
//  Created by Kelly Walker on 2/1/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BookGroupSortedBook;

@interface BookGroup : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameSortKey;
@property (nonatomic, retain) NSSet *sortedBooks;
@end

@interface BookGroup (CoreDataGeneratedAccessors)

- (void)addSortedBooksObject:(BookGroupSortedBook *)value;
- (void)removeSortedBooksObject:(BookGroupSortedBook *)value;
- (void)addSortedBooks:(NSSet *)values;
- (void)removeSortedBooks:(NSSet *)values;

@end
