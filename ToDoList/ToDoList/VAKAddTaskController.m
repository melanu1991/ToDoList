#import "VAKAddTaskController.h"
#import "Constants.h"

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
    
//    self.formatter = [[NSDateFormatter alloc]init];
//    self.formatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:VAKDoneTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:VAKCancelTitle style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UITapGestureRecognizer *handleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleEndEditing)];
    [self.view addGestureRecognizer:handleTap];
    
//    NSDate *date = nil;
//    NSString *title = nil;
//    if (!self.task) {
//        date = [NSDate date];
//        title = VAKAddTaskTitle;
//    }
//    else {
//        date = self.task.startedAt;
//        title = VAKEditTaskTitle;
//        self.taskNameField.text = self.task.taskName;
//        self.taskNotesTextView.text = self.task.notes;
//    }
//    
//    [self.dateButton setTitle:[self.formatter stringFromDate:date] forState:UIControlStateNormal];
//    [self.navigationItem setTitle:title];

}

- (void)handleEndEditing {
    [self.view endEditing:YES];
}

- (IBAction)selectDateButton:(UIButton *)sender {
    VAKSelectDateController *selectDate = [[VAKSelectDateController alloc]initWithNibName:VAKDateController bundle:nil];
    selectDate.delegate = self;
    [self showViewController:selectDate sender:nil];
}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    if (!self.task) {
        NSString *taskId = [NSString stringWithFormat:@"%u",arc4random()%1000];
        VAKTask *newTask = [[VAKTask alloc]initTaskWithId:taskId taskName:self.taskNameField.text];
        NSDate *startDate = [self.formatter dateFromString:self.dateButton.titleLabel.text];
        newTask.startedAt = startDate;
        newTask.notes = self.taskNotesTextView.text;
        newTask.finishedAt = nil;
        [self.delegate addNewTaskWithTask:newTask];
    }
    else {
        self.task.taskName = self.taskNameField.text;
        self.task.notes = self.taskNotesTextView.text;
        self.task.startedAt = [self.formatter dateFromString:self.dateButton.titleLabel.text];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChanged object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
