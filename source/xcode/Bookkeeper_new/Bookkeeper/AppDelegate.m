//
//  AppDelegate.m
//  ReadingTracker
//
//  Created by Kelly Walker on 12/26/13.
//  Copyright (c) 2013 Kelly Walker. All rights reserved.
//

#import "AppDelegate.h"
#import "BookDatabaseAvailability.h"
#import "BookLibrary.h"

@interface AppDelegate()

@property (strong, nonatomic) NSManagedObjectContext* bookDatabaseContext;
@property (strong, nonatomic) UIManagedDocument* document;

@end

@implementation AppDelegate

- (void) contextChanged:(NSNotification*)notification
{
    NSLog(@"saved model document");
}

- (void) setBookDatabaseContext:(NSManagedObjectContext*)bookDatabaseContext
{
    _bookDatabaseContext = bookDatabaseContext;
    
    NSDictionary* userInfo = self.bookDatabaseContext ? @ { BookDatabaseAvailabilityContext : self.bookDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:BookDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (void) loadBookDatabase
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory
                                                     inDomains:NSUserDomainMask] firstObject];
    NSString* documentName = @"bookkeeperModel";
    NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.document.managedObjectContext];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        [self.document openWithCompletionHandler:^(BOOL success)
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
    else
    {
        [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success)
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
    if (self.document.documentState == UIDocumentStateNormal)
    {
        self.bookDatabaseContext = self.document.managedObjectContext;

        [[BookLibrary sharedBookLibrary] setBookDatabaseDocument:self.document];
        [[BookLibrary sharedBookLibrary] setBookDatabaseContext:self.bookDatabaseContext];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadBookDatabase];
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
