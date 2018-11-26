//
//  BookLibrary.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/6/13.
//  Copyright (c) 2013 Kelly Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"
#import "BookGroup.h"

typedef NS_ENUM(NSUInteger, BookSortOrder)
{
    BookSortOrderTitle,
    BookSortOrderAuthorLastName,
    BookSortOrderAuthorFirstName,
    BookSortOrderDateAdded,
};

typedef NS_ENUM(NSUInteger, BookGroupSortOrder)
{
    BookGroupSortOrderName,
    BookGroupSortOrderDateAdded,
};

@interface BookLibrary : NSObject

@property (strong, nonatomic) UIDocument* bookDatabaseDocument;
@property (strong, nonatomic) NSManagedObjectContext* bookDatabaseContext;

@property (nonatomic) BookSortOrder userPreferredBookSortOrder;
@property (nonatomic) BookGroupSortOrder userPreferredBookGroupSortOrder;

+ sharedBookLibrary;

- (void)clearLibrary;

- (Book*)createBook;
- (void)deleteBook:(Book *)book;
- (void)clearAllBooks;

- (BookGroup*)createBookGroup;
- (void)deleteBookGroup:(BookGroup *)bookGroup;
- (void)clearAllBookGroups;

- (void)loadDefaultBooks;

- (NSFetchRequest*) createFetchRequestForBooksSortedByUserPreferredBookSortOrder;
- (NSFetchRequest*) createFetchRequestForBooksSortedBy:(BookSortOrder)bookSortOrder;

- (NSFetchRequest*) createFetchRequestForBookGroupsSortedByUserPreferredBookGroupSortOrder;
- (NSFetchRequest*) createFetchRequestForBookGroupsSortedBy:(BookGroupSortOrder)bookGroupSortOrder;


- (void) notifyChange;

@end
