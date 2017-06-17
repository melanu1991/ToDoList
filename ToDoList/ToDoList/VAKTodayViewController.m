#import "VAKTodayViewController.h"

@interface VAKTodayViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) NSDictionary *dictionaryTasksToday;

@end

@implementation VAKTodayViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = VAKDateFormatWithoutHourAndMinute;
    
    self.taskService = [VAKTaskService sharedVAKTaskService];
    [self arrayTasksToday];
    
    if (self.dictionaryTasksForSelectedGroup) {
        self.navigationItem.title = VAKTaskOfSelectedGroup;
        self.editButton = [[UIBarButtonItem alloc] initWithTitle:VAKEditButton style:UIBarButtonItemStyleDone target:self action:@selector(editTaskButtonPressed)];
        self.navigationItem.leftBarButtonItem = self.editButton;
        self.backButton = [[UIBarButtonItem alloc] initWithTitle:VAKBackButton style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        NSArray *arrayLeftButton = [NSArray arrayWithObjects:self.editButton, self.backButton, nil];
        self.navigationItem.leftBarButtonItems = arrayLeftButton;
    }
    else {
        self.navigationItem.title = VAKToday;
        self.editButton = [[UIBarButtonItem alloc] initWithTitle:VAKEditButton style:UIBarButtonItemStyleDone target:self action:@selector(editTaskButtonPressed)];
        self.navigationItem.leftBarButtonItem = self.editButton;
    }
    
    self.addButton = [[UIBarButtonItem alloc] initWithTitle:VAKAddButton style:UIBarButtonItemStylePlain target:self action:@selector(addTaskButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.addButton;
}

//будет выполняться каждый раз при переходе на эту вкладку (в первый раз только viewDidLoad)
- (void)viewWillAppear:(BOOL)animated {
    [self arrayTasksToday];
    [self.tableView reloadData];
}

#pragma mark - lazy getters

- (NSDictionary *)dictionaryTasksToday {
    if (!_dictionaryTasksToday) {
        _dictionaryTasksToday = [NSDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], @"completedTasks", [NSMutableArray array], @"notCompletedTasks", nil];
    }
    return _dictionaryTasksToday;
}

#pragma mark - helpers method

- (void)arrayTasksToday {
    NSString *currentDate = [self.formatter stringFromDate:[NSDate date]];
    [self.dictionaryTasksToday[@"completedTasks"] removeAllObjects];
    [self.dictionaryTasksToday[@"notCompletedTasks"] removeAllObjects];
    for (VAKTask *task in self.taskService.dictionaryCompletedOrNotCompletedTasks[@"completedTasks"]) {
        if ([[self.formatter stringFromDate:task.startedAt] isEqualToString:currentDate] ) {
            [self.dictionaryTasksToday[@"completedTasks"] addObject:task];
        }
    }
    for (VAKTask *task in self.taskService.dictionaryCompletedOrNotCompletedTasks[@"notCompletedTasks"]) {
        if ([[self.formatter stringFromDate:task.startedAt] isEqualToString:currentDate] ) {
            [self.dictionaryTasksToday[@"notCompletedTasks"] addObject:task];
        }
    }
}

#pragma mark - action

- (void)backButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTaskButtonPressed {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc] init];
    addTaskController.delegate = self;
    addTaskController.currentGroup = self.currentGroup;
    [self.navigationController pushViewController:addTaskController animated:YES];
}

- (void)editTaskButtonPressed {
    if ([self.editButton.title isEqualToString:VAKEditButton]) {
        self.editButton.title = VAKDoneButton;
    }
    else {
        self.editButton.title = VAKEditButton;
    }
    [self.tableView setEditing:!self.tableView.editing];
}

#pragma mark - implemented UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dictionaryTasksForSelectedGroup) {
        if (section == 0) {
            return [self.dictionaryTasksForSelectedGroup[@"notCompletedTasks"] count];
        }
        return [self.dictionaryTasksForSelectedGroup[@"completedTasks"] count];
    }
    else {
        if (section == 0) {
            return [self.dictionaryTasksToday[@"notCompletedTasks"] count];
        }
        return [self.dictionaryTasksToday[@"completedTasks"] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];
    
    if (self.dictionaryTasksForSelectedGroup) {
        if (indexPath.section == 0) {
            VAKTask *notCompletedTask = self.dictionaryTasksForSelectedGroup[@"notCompletedTasks"][indexPath.row];
            cell.taskNameLabel.text = notCompletedTask.taskName;
            cell.taskNoteLabel.text = notCompletedTask.notes;
            cell.taskStartDateLabel.text = [self.formatter stringFromDate:notCompletedTask.startedAt];
        }
        else {
            VAKTask *completedTask = self.dictionaryTasksForSelectedGroup[@"completedTasks"][indexPath.row];
            cell.taskNameLabel.text = completedTask.taskName;
            cell.taskNoteLabel.text = completedTask.notes;
            cell.taskStartDateLabel.text = [self.formatter stringFromDate:completedTask.startedAt];
        }
    }
    else {
        if (indexPath.section == 0) {
            VAKTask *notCompletedTask = self.dictionaryTasksToday[@"notCompletedTasks"][indexPath.row];
            cell.taskNameLabel.text = notCompletedTask.taskName;
            cell.taskNoteLabel.text = notCompletedTask.notes;
            cell.taskStartDateLabel.text = [self.formatter stringFromDate:notCompletedTask.startedAt];
        }
        else {
            VAKTask *completedTask = self.dictionaryTasksToday[@"completedTasks"][indexPath.row];
            cell.taskNameLabel.text = completedTask.taskName;
            cell.taskNoteLabel.text = completedTask.notes;
            cell.taskStartDateLabel.text = [self.formatter stringFromDate:completedTask.startedAt];
        }
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return VAKTitleForHeaderCompleted;
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
    
    //пока в пределах одной секции
    if (sourceIndexPath.section == destinationIndexPath.section) {
        if (sourceIndexPath.section == 0) {
            [self.dictionaryTasksToday[@"notCompletedTasks"] exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        }
        else {
            [self.dictionaryTasksToday[@"completedTasks"] exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        }
    }

}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    VAKTask *currentTask = nil;
    
    if (self.dictionaryTasksForSelectedGroup) {
        if (indexPath.section == 0) {
            currentTask = self.dictionaryTasksForSelectedGroup[@"notCompletedTasks"][indexPath.row];
        }
        else {
            currentTask = self.dictionaryTasksForSelectedGroup[@"completedTasks"][indexPath.row];
        }
    }
    else {
        if (indexPath.section == 0) {
            currentTask = self.dictionaryTasksToday[@"notCompletedTasks"][indexPath.row];
        }
        else {
            currentTask = self.dictionaryTasksToday[@"completedTasks"][indexPath.row];
        }
    }

    editTaskController.task = currentTask;
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKTask *currentTask = nil;
    
    if (self.dictionaryTasksForSelectedGroup) {
        if (indexPath.section == 0) {
            currentTask = self.dictionaryTasksForSelectedGroup[@"notCompletedTasks"][indexPath.row];
        }
        else {
            currentTask = self.dictionaryTasksForSelectedGroup[@"completedTasks"][indexPath.row];
        }
    }
    else {
        if (indexPath.section == 0) {
            currentTask = self.dictionaryTasksToday[@"notCompletedTasks"][indexPath.row];
        }
        else {
            currentTask = self.dictionaryTasksToday[@"completedTasks"][indexPath.row];
        }
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VAKDeleteTaskTitle message:VAKWarningDeleteMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:VAKOkButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (self.dictionaryTasksForSelectedGroup) {
            if (indexPath.section == 0)
            {
                [self.dictionaryTasksForSelectedGroup[@"notCompletedTasks"] removeObjectAtIndex:indexPath.row];
            }
            else {
                [self.dictionaryTasksForSelectedGroup[@"completedTasks"] removeObjectAtIndex:indexPath.row];
            }
        }
        else {
            if (indexPath.section == 0)
            {
                [self.dictionaryTasksToday[@"notCompletedTasks"] removeObjectAtIndex:indexPath.row];
            }
            else {
                [self.dictionaryTasksToday[@"completedTasks"] removeObjectAtIndex:indexPath.row];
            }
        }

        [self.taskService removeTaskById:currentTask.taskId];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKDeleteTaskToDoList object:nil];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:VAKCancelButton style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:VAKDoneButton handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (self.dictionaryTasksForSelectedGroup) {
            if (indexPath.section == 0) {
                [self.dictionaryTasksForSelectedGroup[@"completedTasks"] addObject:self.dictionaryTasksForSelectedGroup[@"notCompletedTasks"][indexPath.row]];
                [self.dictionaryTasksForSelectedGroup[@"notCompletedTasks"] removeObjectAtIndex:indexPath.row];
                currentTask.completed = YES;
                [self.tableView reloadData];
            }
        }
        else {
            if (indexPath.section == 0) {
                [self.dictionaryTasksToday[@"completedTasks"] addObject:self.dictionaryTasksToday[@"notCompletedTasks"][indexPath.row]];
                [self.dictionaryTasksToday[@"notCompletedTasks"] removeObjectAtIndex:indexPath.row];
                currentTask.completed = YES;
                [self.tableView reloadData];
            }
        }

    }];
    
    if (currentTask.isCompleted) {
        doneAction.backgroundColor = [UIColor grayColor];
    }
    else {
        doneAction.backgroundColor = [UIColor blueColor];
    }
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:VAKDelete handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction, doneAction];
}

#pragma mark - delegate add task

- (void)addNewTaskWithTask:(VAKTask *)task {
    [self.taskService addTask:task];
    if (task.isCompleted) {
        [self.dictionaryTasksToday[@"completedTasks"] addObject:task];
    }
    else {
        [self.dictionaryTasksToday[@"notCompletedTasks"] addObject:task];
    }
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:VAKAddNewTask object:nil];
}

@end
