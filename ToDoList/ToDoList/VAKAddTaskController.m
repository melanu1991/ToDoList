#import "VAKAddTaskController.h"
#import "VAKNSDate+Formatters.h"
#import "Constants.h"

@interface VAKAddTaskController ()

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *taskNameField;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;

@end

@implementation VAKAddTaskController

- (void)setNewDateWithDate:(NSDate *)date {
    NSString *temp = [NSDate dateStringFromDate:date format:VAKDateFormat];
    [self.dateButton setTitle:temp forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle:VAKSaveTitle style:UIBarButtonItemStyleDone target:self action:@selector(saveTask)];
    self.navigationItem.rightBarButtonItem = save;
    
    UITapGestureRecognizer *handleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleEndEditing)];
    [self.view addGestureRecognizer:handleTap];
    
    NSDate *date = [NSDate date];
    NSString *title = VAKAddTaskTitle;

    if (self.task) {
        date = self.task.startedAt;
        title = VAKEditTaskTitle;
        self.taskNameField.text = self.task.taskName;
        self.taskNotesTextView.text = self.task.notes;
    }
    
    [self.dateButton setTitle:[NSDate dateStringFromDate:date format:VAKDateFormat] forState:UIControlStateNormal];
    [self.navigationItem setTitle:title];

}

- (void)handleEndEditing {
    [self.view endEditing:YES];
}

- (IBAction)selectDateButton:(UIButton *)sender {
    VAKSelectDateController *selectDate = [[VAKSelectDateController alloc]initWithNibName:VAKDateController bundle:nil];
    selectDate.delegate = self;
    [self showViewController:selectDate sender:nil];
}

- (void)saveTask {
    if (!self.task) {
        NSString *taskId = [NSString stringWithFormat:@"%u",arc4random()%1000];
        VAKTask *newTask = [[VAKTask alloc]initTaskWithId:taskId taskName:self.taskNameField.text];
        NSDate *startDate = [NSDate dateFromString:self.dateButton.titleLabel.text format:VAKDateFormat];
        newTask.startedAt = startDate;
        newTask.notes = self.taskNotesTextView.text;
        newTask.finishedAt = nil;
        [self.delegate addNewTaskWithTask:newTask];
    }
    else {
        self.task.taskName = self.taskNameField.text;
        self.task.notes = self.taskNotesTextView.text;
        self.task.startedAt = [NSDate dateFromString:self.dateButton.titleLabel.text format:VAKDateFormat];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChanged object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
