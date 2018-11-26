//
//  BookLibrary.m
//  ReadingTracker
//
//  Created by Kelly Walker on 1/6/13.
//  Copyright (c) 2013 Kelly Walker. All rights reserved.
//

#import "BookLibrary.h"
#import "bookkeepDatabaseAvailability.h"
#import "Book+API.h"
#import "BookGroup+API.h"

#define BookSortOrderKey @"bookSortOrder"

#define BookTitleSortOrderValue @"title"
#define BookAuthorLastNameSortOrderValue @"authorLastName"
#define BookAuthorFirstNameSortOrderValue @"authorFirstName"
#define BookDateAddedSortOrderValue @"dateAdded"

#define BookGroupSortOrderKey @"bookGroupSortOrder"

#define BookGroupNameSortOrderValue @"name"
#define BookGroupDateAddedSortOrderValue @"dateAdded"

@interface BookLibrary()

@property (strong, nonatomic) UIManagedDocument* bookDatabaseDocument;

@end

@implementation BookLibrary

+ (BookLibrary *)sharedBookLibrary
{
    static BookLibrary *sharedBookLibrary;
    
    @synchronized(self)
    {
        if (!sharedBookLibrary)
        {
            sharedBookLibrary = [[self alloc] init];
        }
        
        return sharedBookLibrary;
    }
}

- (void) loadBookkeepDatabase
{
    // Create managed document in user's Document's directory for bookkeep model database
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString* documentName = @"bookkeepModel";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.bookDatabaseDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    
    // Listen for saves so we can log them
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.bookDatabaseDocument.managedObjectContext];
    
    // If the file exists, open it
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        [self.bookDatabaseDocument openWithCompletionHandler:^(BOOL success)
         {
             if (success)
             {
                 NSLog(@"opened document at %@", url);
                 [self documentIsReady];
             }
             else
             {
                 NSLog(@"couldn’t open document at %@", url);
             }
         }];
    }
    // Otherwise, create it
    else
    {
        [self.bookDatabaseDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
         {
             if (success)
             {
                 NSLog(@"created document at %@", url);
                 [self documentIsReady];
             }
             else
             {
                 NSLog(@"couldn’t create document at %@", url);
             }
         }];
    }
}

- (void) documentIsReady
{
    if (self.bookDatabaseDocument.documentState == UIDocumentStateNormal)
    {
        [self setBookDatabaseContext:self.bookDatabaseDocument.managedObjectContext];
    }
}

- (void) contextChanged:(NSNotification*)notification
{
    NSLog(@"saved model document");
}

- (void) setBookDatabaseContext:(NSManagedObjectContext*)bookDatabaseContext
{
    _bookDatabaseContext = bookDatabaseContext;
    
    NSDictionary* userInfo = self.bookDatabaseContext ? @ { BookkeepDatabaseAvailabilityContext : self.bookDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:BookkeepDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
    
    //[self loadDefaultBooks];
}

- (void) notifyChange
{
    [self.bookDatabaseDocument updateChangeCount:UIDocumentChangeDone];
}

- (void)clearLibrary
{
    [self clearAllBookGroups];
    [self clearAllBooks];
}

- (NSArray *) allBooks
{
    NSFetchRequest* fetchAllBooks = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    NSArray* result = [self.bookDatabaseContext executeFetchRequest:fetchAllBooks error:nil];
    // TODO: check error
    return result;
}

- (NSUInteger)bookCount
{
    NSFetchRequest* fetchAllBooks = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    return [self.bookDatabaseContext countForFetchRequest:fetchAllBooks error:nil];
    // TODO: check error
}

- (Book *)createBook
{
    Book* book = [NSEntityDescription insertNewObjectForEntityForName:@"Book"
                                                inManagedObjectContext:self.self.bookDatabaseContext];
    
    return book;
}

- (BookGroupSortedBook *)createBookGroupSortedBook
{
    BookGroupSortedBook* bookGroupSortedBook = [NSEntityDescription insertNewObjectForEntityForName:@"BookGroupSortedBook"
                                               inManagedObjectContext:self.self.bookDatabaseContext];
    
    return bookGroupSortedBook;
}

- (void)deleteBook:(Book *)book
{
    [self.bookDatabaseContext deleteObject:book];
}

- (void)clearAllBooks
{
    NSArray* allBooks = self.allBooks;
    for (id book in allBooks)
    {
        [self.bookDatabaseContext deleteObject:book];
    }
}

- (NSArray *) allBookGroups
{
    NSFetchRequest* fetchAllBookGroups = [[NSFetchRequest alloc] initWithEntityName:@"BookGroup"];
    NSArray* result = [self.bookDatabaseContext executeFetchRequest:fetchAllBookGroups error:nil];
    // TODO: check error
    return result;
}

- (NSUInteger)bookGroupCount
{
    NSFetchRequest* fetchAllBookGroups = [[NSFetchRequest alloc] initWithEntityName:@"BookGroup"];
    return [self.bookDatabaseContext countForFetchRequest:fetchAllBookGroups error:nil];
    // TODO: check error
}

- (BookGroup *)createBookGroup
{
    BookGroup* bookGroup = [NSEntityDescription insertNewObjectForEntityForName:@"BookGroup"
                                                          inManagedObjectContext:self.bookDatabaseContext];
    
    return bookGroup;
}

- (void)deleteBookGroup:(BookGroup *)bookGroup
{
    [self.bookDatabaseContext deleteObject:bookGroup];

}

- (void)clearAllBookGroups
{
    NSArray* allBookGroups = self.allBookGroups;
    for (id bookGroup in allBookGroups)
    {
        [self.bookDatabaseContext deleteObject:bookGroup];
    }
}

@synthesize userPreferredBookSortOrder = _userPreferredBookSortOrder;

- (BookSortOrder) userPreferredBookSortOrder
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* bookSortOrder = [userDefaults objectForKey:BookSortOrderKey];

    if ([bookSortOrder isEqualToString:BookTitleSortOrderValue])
    {
        return BookSortOrderTitle;
    }
    else if ([bookSortOrder isEqualToString:BookAuthorLastNameSortOrderValue])
    {
        return BookSortOrderAuthorLastName;
    }
    else if ([bookSortOrder isEqualToString:BookAuthorFirstNameSortOrderValue])
    {
        return BookSortOrderAuthorFirstName;
    }
    else if ([bookSortOrder isEqualToString:BookDateAddedSortOrderValue])
    {
        return BookSortOrderDateAdded;
    }
    else
    {
        self.userPreferredBookSortOrder = BookSortOrderTitle;
        return BookSortOrderTitle;
    }
}

- (void) setUserPreferredBookSortOrder:(BookSortOrder)userPreferredBookSortOrder
{
    NSString* sortOrderValue = nil;
    
    if (userPreferredBookSortOrder == BookSortOrderTitle)
    {
        sortOrderValue = BookTitleSortOrderValue;
    }
    else if (userPreferredBookSortOrder == BookSortOrderAuthorLastName)
    {
        sortOrderValue = BookAuthorLastNameSortOrderValue;
    }
    else if (userPreferredBookSortOrder == BookSortOrderAuthorFirstName)
    {
        sortOrderValue = BookAuthorFirstNameSortOrderValue;
    }
    else if (userPreferredBookSortOrder == BookSortOrderDateAdded)
    {
        sortOrderValue = BookDateAddedSortOrderValue;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:sortOrderValue forKey:BookSortOrderKey];
}

- (NSFetchRequest*) createFetchRequestForBooksSortedByUserPreferredBookSortOrder
{
    return [self createFetchRequestForBooksSortedBy:self.userPreferredBookSortOrder];
}

- (NSFetchRequest*) createFetchRequestForBooksSortedBy:(BookSortOrder)bookSortOrder
{
    NSArray *sortDescriptors = nil;
    
    switch (bookSortOrder) {
        case BookSortOrderTitle:
            sortDescriptors = [Book titleSortDescriptors];
            break;
            
        case BookSortOrderAuthorLastName:
            sortDescriptors = [Book authorLastNameSortDescriptors];
            break;
            
        case BookSortOrderAuthorFirstName:
            sortDescriptors = [Book authorFirstNameSortDescriptors];
            break;
            
        case BookSortOrderDateAdded:
            sortDescriptors = [Book dateAddedSortDescriptors];
            break;
            
        default:
            break;
    }
    
    NSFetchRequest* fetchAllBooks = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    fetchAllBooks.sortDescriptors = sortDescriptors;
    return fetchAllBooks;
}

- (NSString*) getFetchedResultsSectionNameKeyPathForBooksForUserPreferredSortOrder
{
    return [self getFetchedResultsSectionNameKeyPathForBooksFor:self.userPreferredBookSortOrder];
}

- (NSString*) getFetchedResultsSectionNameKeyPathForBooksFor:(BookSortOrder)bookSortOrder
{
    NSString* sectionNameKeyPath = nil;
    
    switch (bookSortOrder) {
        case BookSortOrderTitle:
            sectionNameKeyPath = @"titleSortKey";
            break;
            
        case BookSortOrderAuthorLastName:
            sectionNameKeyPath = @"authorLastNameSortKey";
            break;
            
        case BookSortOrderAuthorFirstName:
            sectionNameKeyPath = @"author";
            break;
            
        case BookSortOrderDateAdded:
            break;
            
        default:
            break;
    }

    return sectionNameKeyPath;
}

@synthesize userPreferredBookGroupSortOrder = _userPreferredBookGroupSortOrder;

- (BookGroupSortOrder) userPreferredBookGroupSortOrder
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* bookGroupSortOrder = [userDefaults objectForKey:BookGroupSortOrderKey];
    
    if ([bookGroupSortOrder isEqualToString:BookGroupNameSortOrderValue])
    {
        return BookGroupSortOrderName;
    }
    else if ([bookGroupSortOrder isEqualToString:BookGroupDateAddedSortOrderValue])
    {
        return BookGroupSortOrderDateAdded;
    }
    else
    {
        self.userPreferredBookGroupSortOrder = BookGroupSortOrderName;
        return BookGroupSortOrderName;
    }
}

- (void) setUserPreferredBookGroupSortOrder:(BookGroupSortOrder)userPreferredBookGroupSortOrder
{
    NSString* sortOrderValue = nil;
    
    if (userPreferredBookGroupSortOrder == BookGroupSortOrderName)
    {
        sortOrderValue = BookGroupNameSortOrderValue;
    }
    else if (userPreferredBookGroupSortOrder == BookGroupSortOrderDateAdded)
    {
        sortOrderValue = BookGroupDateAddedSortOrderValue;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:sortOrderValue forKey:BookGroupSortOrderKey];
}

- (NSFetchRequest*) createFetchRequestForBookGroupsSortedByUserPreferredBookGroupSortOrder
{
    return [self createFetchRequestForBookGroupsSortedBy:self.userPreferredBookGroupSortOrder];
}

- (NSFetchRequest*) createFetchRequestForBookGroupsSortedBy:(BookGroupSortOrder)bookGroupSortOrder
{
    NSArray *sortDescriptors = nil;
    
    switch (bookGroupSortOrder) {
        case BookGroupSortOrderName:
            sortDescriptors = [BookGroup nameSortDescriptors];
            break;
            
        case BookGroupSortOrderDateAdded:
            sortDescriptors = [BookGroup dateAddedSortDescriptors];
            break;
            
        default:
            break;
    }
    
    NSFetchRequest* fetchAllBookGroups = [[NSFetchRequest alloc] initWithEntityName:@"BookGroup"];
    fetchAllBookGroups.sortDescriptors = sortDescriptors;
    return fetchAllBookGroups;
}

- (NSString*) getFetchedResultsSectionNameKeyPathForBookGroupsForUserPreferredSortOrder
{
    return [self getFetchedResultsSectionNameKeyPathForBookGroupsFor:self.userPreferredBookGroupSortOrder];
}

- (NSString*) getFetchedResultsSectionNameKeyPathForBookGroupsFor:(BookGroupSortOrder)bookGroupSortOrder
{
    NSString* sectionNameKeyPath = nil;
    
    switch (bookGroupSortOrder) {
        case BookGroupSortOrderName:
            sectionNameKeyPath = @"nameSortKey";
            break;
        
        default:
            break;
    }
    
    return sectionNameKeyPath;
}

- (NSFetchRequest*) createFetchRequestForBookGroupSortedBooks:(BookGroup *)bookGroup
{
    NSFetchRequest* fetchSortedBooksInBookGroup = [[NSFetchRequest alloc] initWithEntityName:@"BookGroupSortedBook"];
    fetchSortedBooksInBookGroup.predicate = [NSPredicate predicateWithFormat:@"bookGroup == %@", bookGroup];
    
    NSSortDescriptor* sortByIndexInGroup = [[NSSortDescriptor alloc] initWithKey:@"sortIndex" ascending:YES];
    
    fetchSortedBooksInBookGroup.sortDescriptors = @[sortByIndexInGroup];
    
    return fetchSortedBooksInBookGroup;
}

- (void) loadDefaultBooks
{
    //return;
    
    [self clearLibrary];
    
    BookGroup* wotBookGroup = [self createBookGroup];
    wotBookGroup.name = @"The Wheel of Time";
    [wotBookGroup updateSortKeys];
    
    {
        // Create and configure new book
        Book* newBook = [self createBook];
        newBook.title = @"The Eye of the World";
        newBook.author = @"Robert Jordan";
        newBook.pageTotalCount = @1000;
        newBook.pageStart = @10;
        newBook.pageLastRead = @485;
        [newBook updateSortKeys];
        
        BookGroupSortedBook* bookGroupSortedBook = [self createBookGroupSortedBook];
        bookGroupSortedBook.book = newBook;
        bookGroupSortedBook.bookGroup = wotBookGroup;
        bookGroupSortedBook.sortIndex = [NSNumber numberWithInt:0];
        
        [wotBookGroup addSortedBooksObject:bookGroupSortedBook];
    }
    {
        // Create and configure new book
        Book* newBook = [self createBook];
        newBook.title = @"The Great Hunt";
        newBook.author = @"Robert Jordan";
        newBook.pageTotalCount = @800;
        newBook.pageStart = @15;
        newBook.pageLastRead = @15;
        [newBook updateSortKeys];
        
        BookGroupSortedBook* bookGroupSortedBook = [self createBookGroupSortedBook];
        bookGroupSortedBook.book = newBook;
        bookGroupSortedBook.bookGroup = wotBookGroup;
        bookGroupSortedBook.sortIndex = [NSNumber numberWithInt:1];
        
        [wotBookGroup addSortedBooksObject:bookGroupSortedBook];
    }
    {
        // Create and configure new book
        Book* newBook = [self createBook];
        newBook.title = @"The Dragon Reborn";
        newBook.author = @"Robert Jordan";
        newBook.pageTotalCount = @956;
        newBook.pageStart = @10;
        newBook.pageLastRead = @10;
        [newBook updateSortKeys];
        
        BookGroupSortedBook* bookGroupSortedBook = [self createBookGroupSortedBook];
        bookGroupSortedBook.book = newBook;
        bookGroupSortedBook.bookGroup = wotBookGroup;
        bookGroupSortedBook.sortIndex = [NSNumber numberWithInt:2];
        
        [wotBookGroup addSortedBooksObject:bookGroupSortedBook];
    }
    {
        // Create and configure new book
        Book* newBook = [self createBook];
        newBook.title = @"A Memory of Light";
        newBook.author = @"Robert Jordan and Brandon Sanderson";
        newBook.pageTotalCount = @1250;
        newBook.pageStart = @10;
        newBook.pageLastRead = @10;
        [newBook updateSortKeys];
        
        BookGroupSortedBook* bookGroupSortedBook = [self createBookGroupSortedBook];
        bookGroupSortedBook.book = newBook;
        bookGroupSortedBook.bookGroup = wotBookGroup;
        bookGroupSortedBook.sortIndex = [NSNumber numberWithInt:3];
        
        [wotBookGroup addSortedBooksObject:bookGroupSortedBook];
    }
    {
        // Create and configure new book
        Book* newBook = [self createBook];
        newBook.title = @"Ender's Game";
        newBook.author = @"Orson Scott Card";
        newBook.pageTotalCount = @256;
        newBook.pageStart = @1;
        [newBook setBookComplete];
        [newBook updateSortKeys];
    }
    {
        // Create and configure new book
        Book* newBook = [self createBook];
        newBook.title = @"Mistborn";
        newBook.author = @"Brandon Sanderson";
        newBook.pageTotalCount = @536;
        newBook.pageStart = @0;
        newBook.pageLastRead = @500;
        [newBook updateSortKeys];
    }
    {
        // Create and configure new book
        Book* newBook = [self createBook];
        newBook.title = @"The Color of Church";
        newBook.author = @"Rodney Woo";
        newBook.pageTotalCount = @198;
        newBook.pageStart = @0;
        newBook.pageLastRead = @35;
        [newBook updateSortKeys];
    }
}

@end
