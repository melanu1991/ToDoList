#import "VAKTodayViewController.h"

@interface VAKTodayViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) NSDictionary *dictionaryTasksToday;
@property (assign, nonatomic) BOOL needToReloadData;

@end

@implementation VAKTodayViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.dictionaryTasksForSelectedGroup) {
        self.navigationItem.title = NSLocalizedString(VAKTaskOfSelectedGroup, nil);
        self.editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(VAKEditButton, nil) style:UIBarButtonItemStyleDone target:self action:@selector(editTaskButtonPressed)];
        self.navigationItem.leftBarButtonItem = self.editButton;
        self.backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(VAKBackButton, nil) style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        NSArray *arrayLeftButton = [NSArray arrayWithObjects:self.editButton, self.backButton, nil];
        self.navigationItem.leftBarButtonItems = arrayLeftButton;
    }
    else {
        self.navigationItem.title = NSLocalizedString(VAKToday, nil);
        self.editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(VAKEditButton, nil) style:UIBarButtonItemStyleDone target:self action:@selector(editTaskButtonPressed)];
        self.navigationItem.leftBarButtonItem = self.editButton;
        [self arrayTasksToday];
    }
    
    self.addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(VAKAddButton, nil) style:UIBarButtonItemStylePlain target:self action:@selector(addTaskButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.needToReloadData) {
        [self.tableView reloadData];
    }
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    VAKTask *currentTask = notification.userInfo[VAKCurrentTask];
    NSString *newDate = notification.userInfo[VAKNewDate];
    NSString *newTaskName = notification.userInfo[VAKNewTaskName];
    NSString *newNotes = notification.userInfo[VAKNewNotes];
    
    if (notification.userInfo[VAKDetailTaskWasChanged]) {
        if (![newNotes isEqualToString:currentTask.notes] || ![newTaskName isEqualToString:currentTask.taskName]) {
            self.needToReloadData = YES;
        }
        else if (![newDate isEqualToString:[NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute]]) {
            [self arrayTasksToday];
            self.needToReloadData = YES;
        }
    }
    else if (((notification.userInfo[VAKAddNewTask] && [NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute]) || (notification.userInfo[VAKDeleteTask] && [NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute])) && !self.dictionaryTasksForSelectedGroup) {
        [self arrayTasksToday];
        self.needToReloadData = YES;
    }
    else if ((notification.userInfo[VAKAddNewTask] || notification.userInfo[VAKDeleteTask]) && self.dictionaryTasksForSelectedGroup) {
        if (notification.userInfo[VAKAddNewTask]) {
            NSMutableArray *arrayCurrentGroup = self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask];
            [arrayCurrentGroup addObject:currentTask];
        }
        else {
            if (currentTask.isCompleted) {
                NSMutableArray *arrayCurrentGroup = self.dictionaryTasksForSelectedGroup[VAKCompletedTask];
                [arrayCurrentGroup removeObject:currentTask];
            }
            else {
                NSMutableArray *arrayCurrentGroup = self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask];
                [arrayCurrentGroup removeObject:currentTask];
            }
        }
        self.needToReloadData = YES;
    }
    else if (notification.userInfo[VAKDoneTask]  || notification.userInfo[VAKWasEditNameGroup] || notification.userInfo[VAKDeleteGroupTask]) {
        self.needToReloadData = YES;
    }
}

#pragma mark - lazy getters

- (NSDictionary *)dictionaryTasksToday {
    if (!_dictionaryTasksToday) {
        _dictionaryTasksToday = [NSDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], VAKCompletedTask, [NSMutableArray array], VAKNotCompletedTask, nil];
    }
    return _dictionaryTasksToday;
}

#pragma mark - helpers method

- (void)arrayTasksToday {
    NSString *currentDate = [NSDate dateStringFromDate:[NSDate date] format:VAKDateFormatWithoutHourAndMinute];
    [self.dictionaryTasksToday[VAKCompletedTask] removeAllObjects];
    [self.dictionaryTasksToday[VAKNotCompletedTask] removeAllObjects];
    for (VAKTask *task in [VAKTaskService sharedVAKTaskService].dictionaryCompletedOrNotCompletedTasks[VAKCompletedTask]) {
        if ([[NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute] isEqualToString:currentDate] ) {
            [self.dictionaryTasksToday[VAKCompletedTask] addObject:task];
        }
    }
    for (VAKTask *task in [VAKTaskService sharedVAKTaskService].dictionaryCompletedOrNotCompletedTasks[VAKNotCompletedTask]) {
        if ([[NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute] isEqualToString:currentDate] ) {
            [self.dictionaryTasksToday[VAKNotCompletedTask] addObject:task];
        }
    }
}

#pragma mark - action

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTaskButtonPressed {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc] init];
    addTaskController.currentGroup = self.currentGroup;
    [self.navigationController pushViewController:addTaskController animated:YES];
}

- (void)editTaskButtonPressed {
    if ([self.editButton.title isEqualToString:VAKEditButton]) {
        self.editButton.title = NSLocalizedString(VAKDoneButton, nil);
    }
    else {
        self.editButton.title = NSLocalizedString(VAKEditButton, nil);
    }
    [self.tableView setEditing:!self.tableView.editing];
}

#pragma mark - implemented UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return VAKTwo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dictionaryTasksForSelectedGroup) {
        if (section == VAKZero) {
            return [self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask] count];
        }
        return [self.dictionaryTasksForSelectedGroup[VAKCompletedTask] count];
    }
    else {
        if (section == VAKZero) {
            return [self.dictionaryTasksToday[VAKNotCompletedTask] count];
        }
        return [self.dictionaryTasksToday[VAKCompletedTask] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];
    
    if (self.dictionaryTasksForSelectedGroup) {
        if (indexPath.section == VAKZero) {
            VAKTask *notCompletedTask = self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask][indexPath.row];
            cell.taskNameLabel.text = notCompletedTask.taskName;
            cell.taskNoteLabel.text = notCompletedTask.notes;
            cell.taskStartDateLabel.text = [NSDate dateStringFromDate:notCompletedTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
        }
        else {
            VAKTask *completedTask = self.dictionaryTasksForSelectedGroup[VAKCompletedTask][indexPath.row];
            cell.taskNameLabel.text = completedTask.taskName;
            cell.taskNoteLabel.text = completedTask.notes;
            cell.taskStartDateLabel.text = [NSDate dateStringFromDate:completedTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
        }
    }
    else {
        if (indexPath.section == VAKZero) {
            VAKTask *notCompletedTask = self.dictionaryTasksToday[VAKNotCompletedTask][indexPath.row];
            cell.taskNameLabel.text = notCompletedTask.taskName;
            cell.taskNoteLabel.text = notCompletedTask.notes;
            cell.taskStartDateLabel.text = [NSDate dateStringFromDate:notCompletedTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
        }
        else {
            VAKTask *completedTask = self.dictionaryTasksToday[VAKCompletedTask][indexPath.row];
            cell.taskNameLabel.text = completedTask.taskName;
            cell.taskNoteLabel.text = completedTask.notes;
            cell.taskStartDateLabel.text = [NSDate dateStringFromDate:completedTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == VAKZero) {
        return nil;
    }
    return NSLocalizedString(VAKTitleForHeaderCompleted, nil);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    if (sourceIndexPath.section == destinationIndexPath.section) {
        if (sourceIndexPath.section == VAKZero) {
            [self.dictionaryTasksToday[VAKNotCompletedTask] exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        }
        else {
            [self.dictionaryTasksToday[VAKCompletedTask] exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        }
    }

}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    VAKTask *currentTask = nil;
    
    if (self.dictionaryTasksForSelectedGroup) {
        if (indexPath.section == VAKZero) {
            currentTask = self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask][indexPath.row];
        }
        else {
            currentTask = self.dictionaryTasksForSelectedGroup[VAKCompletedTask][indexPath.row];
        }
    }
    else {
        if (indexPath.section == VAKZero) {
            currentTask = self.dictionaryTasksToday[VAKNotCompletedTask][indexPath.row];
        }
        else {
            currentTask = self.dictionaryTasksToday[VAKCompletedTask][indexPath.row];
        }
    }

    editTaskController.task = currentTask;
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKTask *currentTask = nil;
    
    if (self.dictionaryTasksForSelectedGroup) {
        if (indexPath.section == VAKZero) {
            currentTask = self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask][indexPath.row];
        }
        else {
            currentTask = self.dictionaryTasksForSelectedGroup[VAKCompletedTask][indexPath.row];
        }
    }
    else {
        if (indexPath.section == VAKZero) {
            currentTask = self.dictionaryTasksToday[VAKNotCompletedTask][indexPath.row];
        }
        else {
            currentTask = self.dictionaryTasksToday[VAKCompletedTask][indexPath.row];
        }
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKDeleteTaskTitle, nil) message:NSLocalizedString(VAKWarningDeleteMessage, nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.dictionaryTasksForSelectedGroup) {
            if (indexPath.section == VAKZero)
            {
                [self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask] removeObjectAtIndex:indexPath.row];
            }
            else {
                [self.dictionaryTasksForSelectedGroup[VAKCompletedTask] removeObjectAtIndex:indexPath.row];
            }
        }
        else {
            if (indexPath.section == VAKZero)
            {
                [self.dictionaryTasksToday[VAKNotCompletedTask] removeObjectAtIndex:indexPath.row];
            }
            else {
                [self.dictionaryTasksToday[VAKCompletedTask] removeObjectAtIndex:indexPath.row];
            }
        }

        [[VAKTaskService sharedVAKTaskService] removeTaskById:currentTask.taskId];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:VAKDeleteTask, VAKDeleteTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDoneButton, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (self.dictionaryTasksForSelectedGroup) {
            if (indexPath.section == VAKZero) {
                [self.dictionaryTasksForSelectedGroup[VAKCompletedTask] addObject:self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask][indexPath.row]];
                [self.dictionaryTasksForSelectedGroup[VAKNotCompletedTask] removeObjectAtIndex:indexPath.row];
                currentTask.completed = YES;
                currentTask.finishedAt = [NSDate date];
                [self.tableView reloadData];
            }
        }
        else {
            if (indexPath.section == VAKZero) {
                [self.dictionaryTasksToday[VAKCompletedTask] addObject:self.dictionaryTasksToday[VAKNotCompletedTask][indexPath.row]];
                [self.dictionaryTasksToday[VAKNotCompletedTask] removeObjectAtIndex:indexPath.row];
                currentTask.completed = YES;
                currentTask.finishedAt = [NSDate date];
                [self.tableView reloadData];
            }
        }
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:currentTask, VAKCurrentTask, VAKDoneTask, VAKDoneTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];

    }];
    
    if (currentTask.isCompleted) {
        doneAction.backgroundColor = [UIColor grayColor];
    }
    else {
        doneAction.backgroundColor = [UIColor blueColor];
    }
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDelete, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction, doneAction];
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
