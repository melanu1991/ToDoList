#import "VAKAddTaskController.h"
#import "VAKDateFormatterHelper.h"
#import "Constants.h"

@interface VAKAddTaskController ()

@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UITextField *taskNameField;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (strong, nonatomic) VAKDateFormatterHelper *dateFormatterHelper;

@end

@implementation VAKAddTaskController

- (void)setNewDateWithDate:(NSDate *)date {
    NSString *temp = [self.formatter stringFromDate:date];
    [self.dateButton setTitle:temp forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formatter = [VAKDateFormatterHelper sharedDateFormatter];
    self.formatter.dateFormat = VAKDateFormat;
    
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
    
    [self.dateButton setTitle:[self.formatter stringFromDate:date] forState:UIControlStateNormal];
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
