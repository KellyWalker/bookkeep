//
//  Book.h
//  Bookkeeper
//
//  Created by Kelly Walker on 1/31/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BookGroup;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * authorLastNameSortKey;
@property (nonatomic, retain) NSNumber * pageLastRead;
@property (nonatomic, retain) NSNumber * pageStart;
@property (nonatomic, retain) NSNumber * pageTotalCount;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titleSortKey;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSSet *bookGroups;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addBookGroupsObject:(BookGroup *)value;
- (void)removeBookGroupsObject:(BookGroup *)value;
- (void)addBookGroups:(NSSet *)values;
- (void)removeBookGroups:(NSSet *)values;

@end
