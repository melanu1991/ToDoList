#import "VAKAddTaskController.h"

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

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc]init];
    self.formatter.dateFormat = VAKDateFormatWithHourAndMinute;
    
    self.doneButton = [[UIBarButtonItem alloc]initWithTitle:VAKDoneButton style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:VAKCancelButton style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    NSString *title = nil;
    if (!self.task) {
        title = VAKAddTaskTitle;
        self.selectPriority = VAKNone;
        if (!self.currentGroup) {
            self.currentGroup = VAKInbox;
        }
        self.selectDate = [NSDate date];
        self.doneButton.enabled = NO;
    }
    else {
        title = VAKEditTaskTitle;
        self.selectPriority = self.task.priority;
        self.selectDate = self.task.startedAt;
        self.remindMeOnADay = self.task.remindMeOnADay;
        self.taskName = self.task.taskName;
        self.taskNotes = self.task.notes;
        self.doneButton.enabled = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dateWasChanged:) name:VAKSelectedDate object:nil];
    
    [self.navigationItem setTitle:title];
}

#pragma mark - Notification

- (void)dateWasChanged:(NSNotification *)notification {
    if (notification.userInfo[VAKSelectedDate]) {
        self.selectDate = notification.userInfo[VAKSelectedDate];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - implemented UITableViewDataSource

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
        cell.textField.text = self.task.taskName;
        return cell;
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            VAKRemindCell *cell = (VAKRemindCell *)[self cellForIdentifier:VAKRemindCellIdentifier tableView:tableView];
            [cell.remindSwitch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
            if (self.remindMeOnADay) {
                [cell.remindSwitch setOn:YES animated:YES];
            }
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
        cell.notes.text = self.task.notes;
        cell.notes.delegate = self;
        return cell;
    }
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

- (UITableViewCell *)cellForIdentifier:(NSString *)identifier tableView:(UITableView *)tableView {
    UITableViewCell *cell = nil;
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

#pragma mark - implemented UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return 200.f;
    }
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1) {
        VAKSelectDateController *selectDateController = [[VAKSelectDateController alloc] init];
        [self.navigationController pushViewController:selectDateController animated:YES];
    }
    else if (indexPath.section == 2) {
        UIAlertController *priorityAlertController = [UIAlertController alertControllerWithTitle:VAKSelectPriority message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noneAction = [UIAlertAction actionWithTitle:VAKNone style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = VAKNone;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        UIAlertAction *lowAction = [UIAlertAction actionWithTitle:VAKLow style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = VAKLow;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        UIAlertAction *mediumAction = [UIAlertAction actionWithTitle:VAKMedium style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = VAKMedium;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        UIAlertAction *highAction = [UIAlertAction actionWithTitle:VAKHigh style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = VAKHigh;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:VAKCancelButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
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

#pragma mark - implemented UITextFieldDelegate

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

#pragma mark - implemented UITextViewdDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.taskNotes = textView.text;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range  replacementText:(NSString *)text
{
    if([text isEqualToString:VAKReturnKey]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma  mark - action

- (void)switchAction {
    self.remindMeOnADay = !self.remindMeOnADay;
}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    NSDictionary *addOrChangedTask = nil;
    if (!self.task) {
        NSString *taskId = [NSString stringWithFormat:@"%u",arc4random()%1000];
        VAKTask *newTask = [[VAKTask alloc] initTaskWithId:taskId taskName:self.taskName];
        newTask.priority = self.selectPriority;
        newTask.remindMeOnADay = self.remindMeOnADay;
        newTask.notes = self.taskNotes;
        newTask.startedAt = self.selectDate;
        newTask.currentGroup = self.currentGroup;
        addOrChangedTask = [NSDictionary dictionaryWithObjectsAndKeys:newTask, VAKCurrentTask, VAKAddNewTask, VAKAddNewTask, nil];
    }
    else {
        self.formatter.dateFormat = VAKDateFormatWithoutHourAndMinute;
        NSString *lastDate = [self.formatter stringFromDate:self.task.startedAt];
        
        //заплатка если не задан нотес, иначе дикшенари не создается!
        if (self.task.notes == nil) {
            self.task.notes = @"";
        }
        
        addOrChangedTask = [NSDictionary dictionaryWithObjectsAndKeys:self.task.notes, VAKLastNotes, self.task.taskName, VAKLastTaskName, lastDate, VAKLastDate, self.task, VAKCurrentTask, VAKDetailTaskWasChanged, VAKDetailTaskWasChanged, nil];
        self.task.taskName = self.taskName;
        self.task.priority = self.selectPriority;
        self.task.remindMeOnADay = self.remindMeOnADay;
        self.task.notes = self.taskNotes;
        self.task.startedAt = self.selectDate;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:addOrChangedTask];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
