//
//  ReadingTrackerTests.m
//  ReadingTrackerTests
//
//  Created by Kelly Walker on 12/26/13.
//  Copyright (c) 2013 Kelly Walker. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "BookLibrary.h"
#import "Book.h"
#import "BookGroup.h"

@interface BookkeepTests : XCTestCase

@end

@implementation BookkeepTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [[BookLibrary sharedBookLibrary] clearLibrary];
    
    [super tearDown];
}

- (void)test_AddBook_BookExists
{
    Book* book = [[BookLibrary sharedBookLibrary] createBook];
    
    XCTAssertEqual((NSUInteger)1, [[[BookLibrary sharedBookLibrary] books] count]);
    XCTAssertEqualObjects(book, [[[BookLibrary sharedBookLibrary] books] objectAtIndex:0]);
}

- (void)test_AddBookGroup_BookGroupExists
{
    BookGroup* bookGroup = [[BookLibrary sharedBookLibrary] createBookGroup];
    
    XCTAssertEqual((NSUInteger)1, [[[BookLibrary sharedBookLibrary] allBookGroups] count]);
    XCTAssertEqualObjects(bookGroup, [[[BookLibrary sharedBookLibrary] allBookGroups] objectAtIndex:0]);
}

- (void)test_AddBookToBookGroup_BookGroupBooksContainsBook
{
    Book* book = [[BookLibrary sharedBookLibrary] createBook];
    BookGroup* bookGroup = [[BookLibrary sharedBookLibrary] createBookGroup];
    
    [bookGroup addBook:book];
    
    XCTAssertEqual((NSUInteger)1, [bookGroup.books count]);
    XCTAssertEqualObjects(book, [bookGroup.books objectAtIndex:0]);
}

- (void)test_AddBookToBookGroup_BookGroupsForBookContainsBookGroup
{
    Book* book = [[BookLibrary sharedBookLibrary] createBook];
    BookGroup* bookGroup = [[BookLibrary sharedBookLibrary] createBookGroup];
    
    [bookGroup addBook:book];
    
    XCTAssertEqual((NSUInteger)1, [[[BookLibrary sharedBookLibrary] getBookGroupsForBook:book] count]);
    XCTAssertEqualObjects(bookGroup, [[[BookLibrary sharedBookLibrary] getBookGroupsForBook:book] objectAtIndex:0]);
}

@end
