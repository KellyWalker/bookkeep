//
//  Book.h
//  bookkeep
//
//  Created by Kelly Walker on 2/1/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BookGroupSortedBook;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * authorLastNameSortKey;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSNumber * pageLastRead;
@property (nonatomic, retain) NSNumber * pageStart;
@property (nonatomic, retain) NSNumber * pageTotalCount;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleSortKey;
@property (nonatomic, retain) NSSet *bookGroupSortedBooks;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addBookGroupSortedBooksObject:(BookGroupSortedBook *)value;
- (void)removeBookGroupSortedBooksObject:(BookGroupSortedBook *)value;
- (void)addBookGroupSortedBooks:(NSSet *)values;
- (void)removeBookGroupSortedBooks:(NSSet *)values;

@end
