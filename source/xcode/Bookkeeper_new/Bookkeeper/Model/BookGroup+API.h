//
//  BookGroup+API.h
//  ReadingTracker
//
//  Created by Kelly Walker on 1/13/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import "BookGroup.h"

@interface BookGroup (API)

@property (readonly, nonatomic) NSInteger pageTotalCount;
@property (readonly, nonatomic) NSInteger pageReadableCount;

@property (readonly, nonatomic) NSInteger pageReadCount;
@property (readonly, nonatomic) double    percentComplete;
@property (readonly, nonatomic) BOOL      isComplete;

- (void) updateSortKeys;

+ (NSArray*) nameSortDescriptors;
+ (NSArray*) dateAddedSortDescriptors;

@end
