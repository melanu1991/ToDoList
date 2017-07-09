#import "VAKAddProjectViewController.h"

@interface VAKAddProjectViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameProjectField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation VAKAddProjectViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameProjectField.delegate = self;
    self.doneButton.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameProjectField resignFirstResponder];
    if ([self.nameProjectField.text length] > VAKZero) {
        self.doneButton.enabled = YES;
    }
    else {
        self.doneButton.enabled = NO;
    }
    return YES;
}

#pragma mark - action

- (IBAction)doneButtonPressed:(UIBarButtonItem *)sender {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.nameProjectField.text, VAKNameNewProject, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:VAKAddProject object:nil userInfo:dic];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
