#import "VAKAddTaskController.h"
#import "VAKRemindCell.h"
#import "VAKDateCell.h"
#import "VAKTaskNameCell.h"
#import "VAKNotesCell.h"
#import "VAKPriorityCell.h"
#import "Constants.h"

@interface VAKAddTaskController ()

@property (weak, nonatomic) IBOutlet UITextField *taskNameField;
@property (weak, nonatomic) IBOutlet UITextView *taskNotesTextView;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation VAKAddTaskController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 2;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSString *identifier = nil;
    
    if (indexPath.section == 0) {
        identifier = VAKTaskNameCellIdentifier;
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            identifier = VAKRemindCellIdentifier;
        }
        else {
            identifier = VAKDateCellIdentifier;
        }
    }
    else if (indexPath.section == 2) {
        identifier = VAKPriorityCellIdentifier;
    }
    else {
        identifier = VAKNotesCellIdentifier;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return 200.f;
    }
    return 44.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return VAKTaskTitle;
    }
    else if (section == 1) {
        return VAKRemindTitle;
    }
    else if (section == 2) {
        return VAKPriorityTitle;
    }
    else {
        return VAKNotesTitle;
    }
}

- (void)setNewDateWithDate:(NSDate *)date {
//    NSString *temp = [self.formatter stringFromDate:date];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.formatter = [[NSDateFormatter alloc]init];
//    self.formatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:VAKDoneTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:VAKCancelTitle style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self.navigationItem setTitle:VAKAddTaskTitle];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        VAKSelectDateController *selectDateController = [[VAKSelectDateController alloc] init];
        [self.navigationController pushViewController:selectDateController animated:YES];
    }
}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    if (!self.task) {
        NSString *taskId = [NSString stringWithFormat:@"%u",arc4random()%1000];
        VAKTask *newTask = [[VAKTask alloc]initTaskWithId:taskId taskName:self.taskNameField.text];

        [self.delegate addNewTaskWithTask:newTask];
    }
    else {
        self.task.taskName = self.taskNameField.text;
        self.task.notes = self.taskNotesTextView.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChanged object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
