#import "VAKAddTaskController.h"
#import "VAKSelectDateController.h"
#import "VAKTask.h"

@interface VAKAddTaskController ()
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *taskNameField;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation VAKAddTaskController

- (void)setNewDateWithDate:(NSDate *)date {
    NSString *temp = [self.formatter stringFromDate:date];
    [self.dateButton setTitle:temp forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc]init];
    self.formatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    NSString *today = [self.formatter stringFromDate:[NSDate date]];
    [self.dateButton setTitle:today forState:UIControlStateNormal];
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonSystemItemSave target:self action:@selector(saveTask)];
    self.navigationItem.rightBarButtonItem = save;
    UITapGestureRecognizer *handleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleEndEditing)];
    [self.view addGestureRecognizer:handleTap];
}

- (void)handleEndEditing {
    [self.view endEditing:YES];
}

- (IBAction)selectDateButton:(UIButton *)sender {
    VAKSelectDateController *selectDate = [[VAKSelectDateController alloc]initWithNibName:@"VAKSelectDateController" bundle:nil];
    selectDate.delegate = self;
    [self showViewController:selectDate sender:nil];
}

- (void)saveTask {
    VAKTask *newTask = [[VAKTask alloc]initTaskWithId:@"taskId" taskName:self.taskNameField.text];
    [self.delegate addNewTaskWithTask:newTask];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
