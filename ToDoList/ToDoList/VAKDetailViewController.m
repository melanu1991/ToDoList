#import "VAKDetailViewController.h"
#import "VAKAddTaskController.h"

@interface VAKDetailViewController ()

@end

@implementation VAKDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc]initWithNibName:@"VAKAddTaskController" bundle:nil];
    [self.navigationController pushViewController:addTaskController animated:YES];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
}

@end
