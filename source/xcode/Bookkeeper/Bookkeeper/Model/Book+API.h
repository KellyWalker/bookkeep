//
//  Book+API.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/13/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "Book.h"

@interface Book (API)

@property (readonly, nonatomic) NSInteger pageReadableCount;
@property (readonly, nonatomic) NSInteger pageReadCount;
@property (readonly, nonatomic) double    percentComplete;
@property (readonly, nonatomic) BOOL      isComplete;

- (void) setBookComplete;
- (void) updateSortKeys;

+ (NSArray*) titleSortDescriptors;
+ (NSArray*) authorLastNameSortDescriptors;
+ (NSArray*) authorFirstNameSortDescriptors;
+ (NSArray*) dateAddedSortDescriptors;

@end
