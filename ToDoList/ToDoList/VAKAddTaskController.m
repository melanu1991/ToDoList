#import "VAKAddTaskController.h"

typedef enum : NSUInteger {
    VAKSectionZero,
    VAKSectionFirst,
    VAKSectionSecond,
    VAKSectionThird,
} VAKTaskSection;

static NSString * const VAKTaskRowIdentifierForSection[] = { @"VAKTaskNameCell", @"VAKRemindCell", @"VAKDateCell", @"VAKPriorityCell", @"VAKNotesCell" };

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

#pragma mark - Delegate

- (void)setRemind:(BOOL)isOn {
    self.remindMeOnADay = isOn;
}

#pragma mark - Lazy getters

- (NSArray *)priorities {
    if (!_priorities) {
        _priorities = [NSArray arrayWithObjects:VAKNone, VAKLow, VAKMedium, VAKHigh, nil];
    }
    return _priorities;
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
        self.remindMeOnADay = NO;
        self.selectDate = [NSDate date];
        self.doneButton.enabled = NO;
    }
    else {
        title = NSLocalizedString(VAKEditTaskTitle, nil);
        self.selectPriority = self.task.priority;
        self.selectDate = self.task.startedAt;
        self.remindMeOnADay = self.task.remind;
        self.taskName = self.task.name;
        self.taskNotes = self.task.notes;
        self.doneButton.enabled = YES;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKTaskNameCellIdentifier bundle:nil] forCellReuseIdentifier:VAKTaskNameCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:VAKDateCellIdentifier bundle:nil] forCellReuseIdentifier:VAKDateCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:VAKNotesCellIdentifier bundle:nil] forCellReuseIdentifier:VAKNotesCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:VAKRemindCellIdentifier bundle:nil] forCellReuseIdentifier:VAKRemindCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:VAKPriorityCellIdentifier bundle:nil] forCellReuseIdentifier:VAKPriorityCellIdentifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dateWasChanged:) name:VAKSelectedDate object:nil];
    
    [self.navigationItem setTitle:title];
}

#pragma mark - helpers

- (UITableViewCell *)configurationCellForIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case VAKSectionZero: {
            VAKTaskNameCell *cell = [self.tableView dequeueReusableCellWithIdentifier:VAKTaskRowIdentifierForSection[VAKSectionZero]];
            cell.textField.delegate = self;
            cell.textField.placeholder = NSLocalizedString(VAKWhatYouHaveToDo, nil);
            cell.textField.text = self.task.name;
            return cell;
        }
            break;
        case VAKSectionFirst: {
            if (indexPath.row == 0) {
                VAKRemindCell *cell = [self.tableView dequeueReusableCellWithIdentifier:VAKTaskRowIdentifierForSection[VAKSectionFirst]];
                cell.delegate = self;
                cell.remindLabel.text = NSLocalizedString(VAKRemindMeOnADay, nil);
                if (self.remindMeOnADay) {
                    [cell.remindSwitch setOn:YES animated:YES];
                }
                return cell;
            }
            VAKDateCell *cell = [self.tableView dequeueReusableCellWithIdentifier:VAKTaskRowIdentifierForSection[VAKSectionFirst + 1]];
            cell.textLabel.text = [NSDate dateStringFromDate:self.selectDate format:VAKDateFormatWithHourAndMinute];
            return cell;
        }
            break;
        case VAKSectionSecond: {
            VAKPriorityCell *cell = [self.tableView dequeueReusableCellWithIdentifier:VAKTaskRowIdentifierForSection[VAKSectionSecond + 1]];
            cell.detailTextLabel.text = NSLocalizedString(self.selectPriority, nil);
            cell.textLabel.text = NSLocalizedString(VAKPriorityTitle, nil);
            return cell;
        }
            break;
        case VAKSectionThird: {
            VAKNotesCell *cell = [self.tableView dequeueReusableCellWithIdentifier:VAKTaskRowIdentifierForSection[VAKSectionThird + 1]];
            cell.notes.text = self.task.notes;
            cell.notes.delegate = self;
            return cell;
        }
            break;
        default:
            return nil;
            break;
    }
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
    UITableViewCell *cell = [self configurationCellForIndexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case VAKSectionZero:
            return NSLocalizedString(VAKTaskTitle, nil);
            break;
        case VAKSectionFirst:
            return NSLocalizedString(VAKRemindTitle, nil);
            break;
        case VAKSectionSecond:
            return NSLocalizedString(VAKPriorityTitle, nil);
            break;
        case VAKSectionThird:
            return NSLocalizedString(VAKNotesTitle, nil);
            break;
        default:
            return nil;
            break;
    }
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
        UIAlertController *priorityAlertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKSelectPriority, nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [self changedPriority:priorityAlertController withIndexPath:indexPath];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleDefault handler:nil];
        [priorityAlertController addAction:cancelAction];
        [self presentViewController:priorityAlertController animated:YES completion:nil];
    }
}

- (void)changedPriority:(UIAlertController *)priorityController withIndexPath:(NSIndexPath *)indexPath {
    for (NSString *priority in self.priorities) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(priority, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = NSLocalizedString(priority, nil);
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

#pragma  mark - action

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    if (!self.task) {
        [self createTask];
    }
    else {
        [self updateTask];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - helpers

- (void)createTask {
    NSNumber *taskId = [NSNumber numberWithUnsignedLong:arc4random_uniform(1000)];
    Task *newTask = (Task *)[[VAKCoreDataManager sharedManager] createEntityWithName:@"Task"];
    newTask.name = self.taskName;
    newTask.taskId = taskId;
    newTask.priority = self.selectPriority;
    newTask.remind = self.remindMeOnADay;
    newTask.notes = self.taskNotes;
    newTask.startedAt = self.selectDate;
    newTask.completed = NO;
    if (newTask.remind) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:newTask, @"task", @"YES", @"remind", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKRemindTask object:nil userInfo:dic];
    }
    NSDictionary *addOrChangedTask = [NSDictionary dictionaryWithObjectsAndKeys:newTask, VAKCurrentTask, VAKAddNewTask, VAKAddNewTask, nil];
    
    [self addTaskInGroup:newTask];
    
    [self addTaskInDate:newTask];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:addOrChangedTask];
    [[VAKCoreDataManager sharedManager].managedObjectContext save:nil];
}

- (void)addTaskInDate:(Task *)task {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute]];
    NSArray *arrayEntityDate = [[VAKCoreDataManager sharedManager] allEntityWithName:@"VAKManagedData" sortDescriptor:nil predicate:predicate];
    
    if (arrayEntityDate.count > 0) {
        VAKManagedData *date = arrayEntityDate[0];
        [date addTasksObject:task];
    }
    else {
        VAKManagedData *date = (VAKManagedData *)[[VAKCoreDataManager sharedManager] createEntityWithName:@"VAKManagedData"];
        date.date = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
        [date addTasksObject:task];
    }
}

- (void)addTaskInGroup:(Task *)task {
    if (self.currentGroup != nil) {
        task.toDoList = self.currentGroup;
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", VAKInbox];
        NSArray *arr = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:predicate];
        task.toDoList = arr[0];
    }
}

- (void)updateTask {
    NSDictionary *addOrChangedTask = [NSDictionary dictionaryWithObjectsAndKeys:self.taskNotes, VAKNewNotes, self.taskName, VAKNewTaskName, self.selectDate, VAKNewDate, self.selectPriority ,VAKNewPriority, self.task, VAKCurrentTask, VAKDetailTaskWasChanged, VAKDetailTaskWasChanged, nil];
    
    if (self.task.remind && !self.remindMeOnADay) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.task, @"task", @"YES", @"delete", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKRemindTask object:nil userInfo:dic];
    }
    else if (![[NSDate dateStringFromDate:self.task.startedAt format:VAKDateFormatWithHourAndMinute] isEqualToString:[NSDate dateStringFromDate:self.selectDate format:VAKDateFormatWithHourAndMinute]]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.task, @"task", @"YES", @"update", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKRemindTask object:nil userInfo:dic];
    }
    else if (!self.task.remind && self.remindMeOnADay) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.task, @"task", @"YES", @"remind", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKRemindTask object:nil userInfo:dic];
    }
    self.task.remind = self.remindMeOnADay;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:addOrChangedTask];
    [[VAKCoreDataManager sharedManager].managedObjectContext save:nil];
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
