//
//  BookGroup+API.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/13/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "BookGroup+API.h"
#import "Book.h"
#import "BookGroupSortedBook.h"
#import "Book+API.h"

@implementation BookGroup (API)

- (void) awakeFromInsert
{
    NSDate *now = [NSDate date];
    self.dateAdded = now;
}

- (NSInteger)pageTotalCount
{
    int count = 0;
    for (BookGroupSortedBook* sortedBook in self.sortedBooks)
    {
        count += [sortedBook.book.pageTotalCount integerValue];
    }
    return count;
}

- (NSInteger)pageReadableCount
{
    int count = 0;
    for (BookGroupSortedBook* sortedBook in self.sortedBooks)
    {
        count += sortedBook.book.pageReadableCount;
    }
    return count;
}

- (NSInteger)pageReadCount
{
    int count = 0;
    for (BookGroupSortedBook* sortedBook in self.sortedBooks)
    {
        count += sortedBook.book.pageReadCount;
    }
    return count;
}

- (double)percentComplete
{
    return self.pageReadableCount ? (double)self.pageReadCount / self.pageReadableCount : 1;
}

- (BOOL)isComplete
{
    for (BookGroupSortedBook* sortedBook in self.sortedBooks)
   {
        if (!sortedBook.book.isComplete)
        {
            return NO;
        }
    }
    return YES;
}

- (void) updateNameSortKey
{
    self.nameSortKey = self.name;
    
    NSRange nameFirstSpace = [self.name rangeOfString:@" "];
    if (nameFirstSpace.length > 0)
    {
        NSString* nameFirstWord = [[self.name substringToIndex:nameFirstSpace.location] lowercaseString];
        if ([nameFirstWord isEqualToString:@"a"] ||
            [nameFirstWord isEqualToString:@"an"] ||
            [nameFirstWord isEqualToString:@"the"])
        {
            self.nameSortKey = [self.name substringFromIndex:nameFirstSpace.location+1];
        }
    }
    
    self.nameSortKey = [self.nameSortKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) updateSortKeys
{
    [self updateNameSortKey];
}

- (BOOL) containsBook:(Book*) book
{
    return [self sortedBookForBook:book] != nil;
    
}

- (BookGroupSortedBook*) sortedBookForBook:(Book*) book
{
    NSSet* results = [self.sortedBooks objectsPassingTest:
                         ^BOOL(BookGroupSortedBook* obj, BOOL* stop)
                         {
                             return obj.book == book;
                         }];
    
    return results.anyObject;
}

+ (NSSortDescriptor*) nameSortDescriptor
{
    return [[NSSortDescriptor alloc] initWithKey:@"name"
                                       ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (NSSortDescriptor*) nameSortKeySortDescriptor
{
    return [[NSSortDescriptor alloc] initWithKey:@"nameSortKey"
                                       ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (NSSortDescriptor*) dateAddedSortDescriptor
{
    return [[NSSortDescriptor alloc] initWithKey:@"dateAdded"
                                       ascending:YES
                                        selector:@selector(compare:)];
}

+ (NSArray*) nameSortDescriptors
{
    return @[self.nameSortKeySortDescriptor, self.nameSortDescriptor];
}

+ (NSArray*) dateAddedSortDescriptors
{
    return @[self.dateAddedSortDescriptor];
}

@end
