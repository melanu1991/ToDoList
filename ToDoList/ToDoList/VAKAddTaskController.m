#import "VAKAddTaskController.h"
#import "VAKRemindCell.h"
#import "VAKDateCell.h"
#import "VAKTaskNameCell.h"
#import "VAKNotesCell.h"
#import "VAKPriorityCell.h"
#import "Constants.h"

@interface VAKAddTaskController ()

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDate *selectDate;
@property (strong, nonatomic) NSString *selectPriority;
@property (strong, nonatomic) NSString *taskName;
@property (strong, nonatomic) NSString *taskNotes;
@property (assign, nonatomic, getter=isRemindMeOnADay) BOOL remindMeOnADay;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

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
    
    if (indexPath.section == 0) {
        VAKTaskNameCell *cell = (VAKTaskNameCell *)[self cellForIdentifier:VAKTaskNameCellIdentifier tableView:tableView];
        cell.textField.delegate = self;
        return cell;
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            VAKRemindCell *cell = (VAKRemindCell *)[self cellForIdentifier:VAKRemindCellIdentifier tableView:tableView];
            [cell.remindSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        else {
            VAKDateCell *cell = (VAKDateCell *)[self cellForIdentifier:VAKDateCellIdentifier tableView:tableView];
            cell.textLabel.text = [self.formatter stringFromDate:self.selectDate];
            return cell;
        }
    }
    else if (indexPath.section == 2) {
        VAKPriorityCell *cell = (VAKPriorityCell *)[self cellForIdentifier:VAKPriorityCellIdentifier tableView:tableView];
        cell.detailTextLabel.text = self.selectPriority;
        return cell;
    }
    else {
        VAKNotesCell *cell = (VAKNotesCell *)[self cellForIdentifier:VAKNotesCellIdentifier tableView:tableView];
        cell.notes.delegate = self;
        return cell;
    }
    
}

- (UITableViewCell *)cellForIdentifier:(NSString *)identifier tableView:(UITableView *)tableView {
    UITableViewCell *cell = nil;
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
    self.selectDate = date;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    NSArray *rowToReload = [NSArray arrayWithObjects:indexPath, nil];
    [self.tableView reloadRowsAtIndexPaths:rowToReload withRowAnimation:UITableViewRowAnimationRight];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc]init];
    self.formatter.dateFormat = @"EEEE, dd MMMM yyyy г., H:m";
    
    self.selectPriority = @"None";
    self.selectDate = [NSDate date];
    
    self.doneButton = [[UIBarButtonItem alloc]initWithTitle:VAKDoneButton style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    self.doneButton.enabled = NO;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:VAKCancelTitle style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    NSString *title = nil;
    if (!self.task) {
        title = VAKAddTaskTitle;
    }
    else {
        title = VAKEditTaskTitle;
    }

    [self.navigationItem setTitle:title];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1) {
        VAKSelectDateController *selectDateController = [[VAKSelectDateController alloc] init];
        selectDateController.delegate = self;
        [self.navigationController pushViewController:selectDateController animated:YES];
    }
    else if (indexPath.section == 2) {
        UIAlertController *priorityAlertController = [UIAlertController alertControllerWithTitle:@"Select Priority" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noneAction = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = @"None";
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        UIAlertAction *lowAction = [UIAlertAction actionWithTitle:@"Low" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = @"Low";
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        UIAlertAction *mediumAction = [UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = @"Medium";
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        UIAlertAction *highAction = [UIAlertAction actionWithTitle:@"High" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = @"High";
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        [priorityAlertController addAction:noneAction];
        [priorityAlertController addAction:lowAction];
        [priorityAlertController addAction:mediumAction];
        [priorityAlertController addAction:highAction];
        [priorityAlertController addAction:cancelAction];
        [self presentViewController:priorityAlertController animated:YES completion:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.taskName = textField.text;
    if ([textField.text length] > 0) {
        self.doneButton.enabled = YES;
    }
    else {
        self.doneButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.taskNotes = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range  replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)switchAction {
    self.remindMeOnADay = !self.remindMeOnADay;
}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    if (!self.task) {
        NSString *taskId = [NSString stringWithFormat:@"%u",arc4random()%1000];
        VAKTask *newTask = [[VAKTask alloc]initTaskWithId:taskId taskName:self.taskName];
        newTask.priority = self.selectPriority;
        newTask.remindMeOnADay = self.remindMeOnADay;
        newTask.notes = self.taskNotes;
        newTask.startedAt = self.selectDate;
        [self.delegate addNewTaskWithTask:newTask];
    }
    else {
        self.task.taskName = self.taskName;
        self.task.priority = self.selectPriority;
        self.task.remindMeOnADay = self.remindMeOnADay;
        self.task.startedAt = self.selectDate;
        self.task.notes = self.taskNotes;
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChanged object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
