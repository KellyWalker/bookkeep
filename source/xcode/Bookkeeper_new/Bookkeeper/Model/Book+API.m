//
//  BookZ+API.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/13/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "Book+API.h"

@implementation Book (API)

- (void) awakeFromInsert
{
    NSDate *now = [NSDate date];
    self.dateAdded = now;
}

- (NSInteger)pageReadableCount
{
    return [self.pageTotalCount integerValue] - [self.pageStart integerValue] + 1;
}

- (NSInteger)pageReadCount
{
    return [self.pageLastRead integerValue] - [self.pageStart integerValue] + 1;
}

- (double)percentComplete
{
    return (double)self.pageReadCount / self.pageReadableCount;
}

- (BOOL)isComplete
{
    return self.pageLastRead == self.pageTotalCount;
}

- (void) setBookComplete
{
    self.pageLastRead = self.pageTotalCount;
}

- (void) updateTitleSortKey
{
    self.titleSortKey = self.title;
    
    NSRange titleFirstSpace = [self.title rangeOfString:@" "];
    if (titleFirstSpace.length > 0)
    {
        NSString* titleFirstWord = [[self.title substringToIndex:titleFirstSpace.location] lowercaseString];
        if ([titleFirstWord isEqualToString:@"a"] ||
            [titleFirstWord isEqualToString:@"an"] ||
            [titleFirstWord isEqualToString:@"the"])
        {
            self.titleSortKey = [self.title substringFromIndex:titleFirstSpace.location+1];
        }
    }
    
    self.titleSortKey = [self.titleSortKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) updateAuthorLastNameSortKey
{
    NSString* firstAuthor = self.author;
    
    NSRange authorFirstComma = [self.author rangeOfString:@","];
    NSRange authorFirstAnd = [self.author rangeOfString:@" and" options:NSCaseInsensitiveSearch];
    NSRange authorFirstAmp = [self.author rangeOfString:@"&"];
    
    // Find first delimeter
    NSRange authorFirstDelim = authorFirstComma;
    if (authorFirstAnd.location < authorFirstDelim.location)
    {
        authorFirstDelim = authorFirstAnd;
    }
    if (authorFirstAmp.location < authorFirstDelim.location)
    {
        authorFirstDelim = authorFirstAmp;
    }
    
    // Get first author
    if (authorFirstDelim.length > 0)
    {
        firstAuthor = [self.author substringToIndex:authorFirstDelim.location];
    }
    
    firstAuthor = [firstAuthor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.authorLastNameSortKey = firstAuthor;

    // Get last name of first author
    NSRange firstAuthorLastSpace = [firstAuthor rangeOfString:@" " options:NSBackwardsSearch];
    if (firstAuthorLastSpace.length > 0)
    {
        self.authorLastNameSortKey = [firstAuthor substringFromIndex:firstAuthorLastSpace.location+1];
    }
    
    self.authorLastNameSortKey = [self.authorLastNameSortKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) updateSortKeys
{
    [self updateTitleSortKey];
    [self updateAuthorLastNameSortKey];
}

+ (NSSortDescriptor*) titleSortKeySortDescriptor
{
    return [[NSSortDescriptor alloc] initWithKey:@"titleSortKey"
                                       ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    
}

+ (NSSortDescriptor*) titleSortDescriptor
{
    return [[NSSortDescriptor alloc] initWithKey:@"title"
                                       ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
    
}

+ (NSSortDescriptor*) authorLastNameSortKeySortDescriptor
{
    return [[NSSortDescriptor alloc] initWithKey:@"authorLastNameSortKey"
                                       ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (NSSortDescriptor*) authorFirstNameSortKeySortDescriptor
{
    return [[NSSortDescriptor alloc] initWithKey:@"author"
                                       ascending:YES
                                        selector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (NSSortDescriptor*) dateAddedSortDescriptor
{
    return [[NSSortDescriptor alloc] initWithKey:@"dateAdded"
                                       ascending:YES
                                        selector:@selector(compare:)];
}

+ (NSArray*) titleSortDescriptors
{
    return @[[Book titleSortKeySortDescriptor], [Book titleSortDescriptor]];
}

+ (NSArray*) authorLastNameSortDescriptors
{
    return @[self.authorLastNameSortKeySortDescriptor, self.titleSortKeySortDescriptor, self.titleSortDescriptor];
}

+ (NSArray*) authorFirstNameSortDescriptors
{
    return @[self.authorFirstNameSortKeySortDescriptor, self.titleSortKeySortDescriptor, self.titleSortDescriptor];
}

+ (NSArray*) dateAddedSortDescriptors
{
    return @[self.dateAddedSortDescriptor];
}

@end
