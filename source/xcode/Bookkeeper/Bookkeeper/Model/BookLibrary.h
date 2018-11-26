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
#import "BookGroupSortedBook.h"

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

@property (strong, nonatomic) NSManagedObjectContext* bookDatabaseContext;

@property (nonatomic) BookSortOrder userPreferredBookSortOrder;
@property (nonatomic) BookGroupSortOrder userPreferredBookGroupSortOrder;

+ sharedBookLibrary;

- (void) loadBookkeepDatabase;

- (void)clearLibrary;

- (NSUInteger)bookCount;
- (Book*)createBook;
- (void)deleteBook:(Book *)book;
- (void)clearAllBooks;

- (BookGroupSortedBook *)createBookGroupSortedBook;

- (NSUInteger)bookGroupCount;
- (BookGroup*)createBookGroup;
- (void)deleteBookGroup:(BookGroup *)bookGroup;
- (void)clearAllBookGroups;

- (NSFetchRequest*) createFetchRequestForBooksSortedByUserPreferredBookSortOrder;
- (NSFetchRequest*) createFetchRequestForBooksSortedBy:(BookSortOrder)bookSortOrder;

- (NSString*) getFetchedResultsSectionNameKeyPathForBooksForUserPreferredSortOrder;
- (NSString*) getFetchedResultsSectionNameKeyPathForBooksFor:(BookSortOrder)bookSortOrder;

- (NSFetchRequest*) createFetchRequestForBookGroupsSortedByUserPreferredBookGroupSortOrder;
- (NSFetchRequest*) createFetchRequestForBookGroupsSortedBy:(BookGroupSortOrder)bookGroupSortOrder;

- (NSString*) getFetchedResultsSectionNameKeyPathForBookGroupsForUserPreferredSortOrder;
- (NSString*) getFetchedResultsSectionNameKeyPathForBookGroupsFor:(BookGroupSortOrder)bookGroupSortOrder;

- (NSFetchRequest*) createFetchRequestForBookGroupSortedBooks:(BookGroup*)bookGroup;

- (void) notifyChange;

@end
