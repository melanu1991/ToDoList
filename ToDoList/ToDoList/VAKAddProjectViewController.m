#import "VAKAddProjectViewController.h"

@interface VAKAddProjectViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameProjectField;

@end

@implementation VAKAddProjectViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameProjectField.delegate = self;
}

#pragma mark - action

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameProjectField resignFirstResponder];
    return YES;
}

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate addNewProjectWithName:self.nameProjectField.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
