#import "VAKAddTaskController.h"

@interface VAKAddTaskController () <VAKRemindDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDate *selectDate;
@property (strong, nonatomic) NSString *selectPriority;
@property (strong, nonatomic) NSString *taskName;
@property (strong, nonatomic) NSString *taskNotes;
@property (assign, nonatomic, getter=isRemindMeOnADay) BOOL remindMeOnADay;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) NSArray *priorities;

@end

@implementation VAKAddTaskController

#pragma mark - Lazy getters

- (NSArray *)priorities {
    if (!_priorities) {
        _priorities = [NSArray arrayWithObjects:VAKNone, VAKLow, VAKMedium, VAKHigh, nil];
    }
    return _priorities;
}

#pragma mark - Delegate

- (void)setRemind:(BOOL)isOn {
    self.remindMeOnADay = isOn;
}

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];

    self.doneButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(VAKDoneButton, nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    NSString *title = NSLocalizedString(VAKAddTaskTitle, nil);
    if (!self.task) {
        self.selectPriority = VAKNone;
        self.taskNotes = @"";
        if (!self.currentGroup) {
            self.currentGroup = VAKInbox;
        }
        self.selectDate = [NSDate date];
        self.doneButton.enabled = NO;
    }
    else {
        title = NSLocalizedString(VAKEditTaskTitle, nil);
        self.selectPriority = self.task.priority;
        self.selectDate = self.task.startedAt;
        self.remindMeOnADay = self.task.remindMeOnADay;
        self.taskName = self.task.taskName;
        self.taskNotes = self.task.notes;
        self.doneButton.enabled = YES;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKTaskNameCellIdentifier bundle:nil] forCellReuseIdentifier:VAKTaskNameCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:VAKRemindCellIdentifier bundle:nil] forCellReuseIdentifier:VAKRemindCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:VAKDateCellIdentifier bundle:nil] forCellReuseIdentifier:VAKDateCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:VAKPriorityCellIdentifier bundle:nil] forCellReuseIdentifier:VAKPriorityCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:VAKNotesCellIdentifier bundle:nil] forCellReuseIdentifier:VAKNotesCellIdentifier];
    
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
    return VAKFour;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == VAKOne) {
        return VAKTwo;
    }
    return VAKOne;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == VAKZero) {
        VAKTaskNameCell *cell = (VAKTaskNameCell *)[self cellForIdentifier:VAKTaskNameCellIdentifier tableView:tableView];
        cell.textField.delegate = self;
        cell.textField.text = self.task.taskName;
        cell.textField.placeholder = NSLocalizedString(VAKWhatToDo, nil);
        return cell;
    }
    else if (indexPath.section == VAKOne) {
        if (indexPath.row == VAKZero) {
            VAKRemindCell *cell = (VAKRemindCell *)[self cellForIdentifier:VAKRemindCellIdentifier tableView:tableView];
            cell.delegate = self;
            cell.remindLabel.text = NSLocalizedString(VAKRemindMeOnADay, nil);
            if (self.remindMeOnADay) {
                [cell.remindSwitch setOn:YES animated:YES];
            }
            return cell;
        }
        else {
            VAKDateCell *cell = (VAKDateCell *)[self cellForIdentifier:VAKDateCellIdentifier tableView:tableView];
            cell.textLabel.text = [NSDate dateStringFromDate:self.selectDate format:VAKDateFormatWithHourAndMinute];
            return cell;
        }
    }
    else if (indexPath.section == VAKTwo) {
        VAKPriorityCell *cell = (VAKPriorityCell *)[self cellForIdentifier:VAKPriorityCellIdentifier tableView:tableView];
        cell.textLabel.text = NSLocalizedString(VAKPriority, nil);
        cell.detailTextLabel.text = NSLocalizedString(self.selectPriority, nil);
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
    if (section == VAKZero) {
        return NSLocalizedString(VAKTaskTitle, nil);
    }
    else if (section == VAKOne) {
        return NSLocalizedString(VAKRemindTitle, nil);
    }
    else if (section == VAKTwo) {
        return NSLocalizedString(VAKPriorityTitle, nil);
    }
    return NSLocalizedString(VAKNotesTitle, nil);
}

- (UITableViewCell *)cellForIdentifier:(NSString *)identifier tableView:(UITableView *)tableView {
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

#pragma mark - implemented UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VAKThree) {
        return VAKHeightBigCell;
    }
    return VAKHeightRegularCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == VAKOne && indexPath.row == VAKOne) {
        VAKSelectDateController *selectDateController = [[VAKSelectDateController alloc] init];
        [self.navigationController pushViewController:selectDateController animated:YES];
    }
    else if (indexPath.section == VAKTwo) {
        UIAlertController *priorityAlertController = [UIAlertController alertControllerWithTitle:VAKSelectPriority message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self changedPriority:priorityAlertController withIndexPath:indexPath];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:VAKCancelButton style:UIAlertActionStyleDefault handler:nil];
        [priorityAlertController addAction:cancelAction];
        [self presentViewController:priorityAlertController animated:YES completion:nil];
    }
}

- (void)changedPriority:(UIAlertController *)priorityController withIndexPath:(NSIndexPath *)indexPath {
    for (NSString *priority in self.priorities) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:priority style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = priority;
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        }];
        [priorityController addAction:action];
    }
}

#pragma mark - implemented UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.taskName = textField.text;
    if ([textField.text length] > VAKZero) {
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
        NSString *newDate = [NSDate dateStringFromDate:self.selectDate format:VAKDateFormatWithoutHourAndMinute];
        addOrChangedTask = [NSDictionary dictionaryWithObjectsAndKeys:self.taskNotes, VAKNewNotes, self.taskName, VAKNewTaskName, newDate, VAKNewDate, self.task, VAKCurrentTask, VAKDetailTaskWasChanged, VAKDetailTaskWasChanged, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:addOrChangedTask];
        if (self.task.remindMeOnADay && !self.remindMeOnADay) {
            [self deleteRemind:self.task];
        }
        if (![[NSDate dateStringFromDate:self.task.startedAt format:VAKDateFormatWithHourAndMinute] isEqualToString:[NSDate dateStringFromDate:self.selectDate format:VAKDateFormatWithHourAndMinute]]) {
            [self updateDateRemind:self.task];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - remind task

- (void)remind:(VAKTask *)task {
    NSString *eventInfo = [NSString stringWithFormat:@"Name: %@ and notes: %@", task.taskName, task.notes];
    NSString *eventDate = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithHourAndMinute];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:eventInfo, @"eventInfo", eventDate, @"eventDate", task.taskId, @"taskId", nil];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.userInfo = dic;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.fireDate = task.startedAt;
    notification.alertBody = eventInfo;
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)deleteRemind:(VAKTask *)task {
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([notification.userInfo[@"taskId"] isEqualToString:task.taskId]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)updateDateRemind:(VAKTask *)task {
    [self deleteRemind:task];
    [self remind:task];
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

