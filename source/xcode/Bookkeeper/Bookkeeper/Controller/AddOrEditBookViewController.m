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
    
    self.titleTextField.delegate = self;
    self.authorTextField.delegate = self;
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

- (IBAction)touchUpInside:(id)sender
{
    [self.titleTextField resignFirstResponder];
    [self.authorTextField resignFirstResponder];
    [self.pageCountTextField resignFirstResponder];
    [self.pageStartTextField resignFirstResponder];
}

- (IBAction)textFieldEditingChanged
{
    [self updateDoneButton];
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
        book.pageLastRead = [NSNumber numberWithInt:[book.pageStart intValue] - 1];
    }
    
    [book updateSortKeys];
    
    [[BookLibrary sharedBookLibrary] notifyChange];
    
    // Dismiss view controller
    [self.navigationController popViewControllerAnimated:YES];
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
    
    return YES;
}

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect = [self.view convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view convertRect:self.view.bounds fromView:self.view];
    
    // Calculate the fraction between the top and bottom of the middle section for the text field's midline
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;

    // Clamp this fraction so that the top section is all "0.0" and the bottom section is all "1.0".
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    CGFloat animatedDistance = 0;
    
    // Now take this fraction and convert it into an amount to scroll by multiplying by the keyboard height for the current screen orientation. Notice the calls to floor so that we only scroll by whole pixel amounts.
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    // Apply the animation; use of setAnimationBeginsFromCurrentState allows a smooth transition to new text field if the user taps on another.
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y = 0;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
