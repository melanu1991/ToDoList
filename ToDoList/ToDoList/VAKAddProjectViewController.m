#import "VAKAddProjectViewController.h"

@interface VAKAddProjectViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameProjectField;

@end

@implementation VAKAddProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameProjectField.delegate = self;
}

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
