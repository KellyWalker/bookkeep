//
//  AddBookViewController.m
//  ReadingTracker
//
//  Created by Kelly Walker on 12/26/13.
//  Copyright (c) 2013 Kelly Walker. All rights reserved.
//

#import "AddOrEditBookViewController.h"
#import "BookLibrary.h"
#import "Book.h"
#import "Book+API.h"

@interface AddOrEditBookViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *authorTextField;
@property (weak, nonatomic) IBOutlet UITextField *pageCountTextField;
@property (weak, nonatomic) IBOutlet UITextField *pageStartTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation AddOrEditBookViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageCountTextField.delegate = self;
    self.pageStartTextField.delegate = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self loadBookDetailsIfEditing];
    [self updateDoneButton];    
}

- (void) loadBookDetailsIfEditing
{
    if (self.book)
    {
        self.title = @"Edit Book";
        
        self.titleTextField.text = self.book.title;
        self.authorTextField.text = self.book.author;
        self.pageCountTextField.text = [NSString stringWithFormat:@"%d", [self.book.pageTotalCount intValue]];
        self.pageStartTextField.text = [NSString stringWithFormat:@"%d", [self.book.pageStart intValue]];
    }
}

- (void) updateDoneButton
{
    self.doneButton.enabled =
        self.titleTextField.text.length > 0 &&
        self.authorTextField.text.length > 0 &&
        self.pageCountTextField.text.length > 0 &&
        self.pageStartTextField.text.length > 0;
}

- (IBAction)textFieldEditingChanged
{
    [self updateDoneButton];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.pageCountTextField ||
        textField == self.pageStartTextField)
    {
        NSCharacterSet* charactersToRemove = [[ NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSString *trimmedReplacement = [[string componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
        return (trimmedReplacement.length == string.length) || [string isEqualToString:@""];
    }
    
    return NO;
}
- (IBAction)clickDoneButton:(id)sender
{
    int pageTotalCount = [self.pageCountTextField.text intValue];
    int pageStart = [self.pageStartTextField.text intValue];
    
    if (pageStart > pageTotalCount)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Starting page cannot be greater than page count"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    Book* book = self.book;

    BOOL isNewBook = !book;
    if (isNewBook)
    {
        book = [[BookLibrary sharedBookLibrary] createBook];
    }

    book.title = self.titleTextField.text;
    book.author = self.authorTextField.text;
    book.pageTotalCount = [NSNumber numberWithInt:pageTotalCount];
    book.pageStart = [NSNumber numberWithInt:pageStart];
    
    if (isNewBook || book.pageLastRead < book.pageStart)
    {
        book.pageLastRead = book.pageStart;
    }
    
    [book updateSortKeys];
    
    [[BookLibrary sharedBookLibrary] notifyChange];
    
    // Dismiss view controller
    [self.navigationController popViewControllerAnimated:YES];
}

@end
