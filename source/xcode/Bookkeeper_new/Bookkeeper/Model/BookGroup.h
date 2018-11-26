//
//  BookGroup.h
//  Bookkeeper
//
//  Created by Kelly Walker on 1/31/14.
//  Copyright (c) 2014 Kelly Walker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface BookGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nameSortKey;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSSet *books;
@end

@interface BookGroup (CoreDataGeneratedAccessors)

- (void)addBooksObject:(Book *)value;
- (void)removeBooksObject:(Book *)value;
- (void)addBooks:(NSSet *)values;
- (void)removeBooks:(NSSet *)values;

@end
