#import "VAKTodayViewController.h"
#import "VAKAddTaskController.h"
#import "VAKDetailViewController.h"

@interface VAKTodayViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) NSMutableArray *arrayTodayTaskCompleted;
@property (strong, nonatomic) NSMutableArray *arrayTodayTaskNotCompleted;

@end

@implementation VAKTodayViewController

#pragma mark - lazy initialize

- (NSMutableArray *)arrayTodayTaskCompleted {
    if (!_arrayTodayTaskCompleted) {
        _arrayTodayTaskCompleted = [[NSMutableArray alloc] init];
    }
    return _arrayTodayTaskCompleted;
}

- (NSMutableArray *)arrayTodayTaskNotCompleted {
    if (!_arrayTodayTaskNotCompleted) {
        _arrayTodayTaskNotCompleted = [[NSMutableArray alloc] init];
    }
    return _arrayTodayTaskNotCompleted;
}

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = VAKDateFormatWithoutHourAndMinute;
    
    NSString *currentDate = [self.formatter stringFromDate:[NSDate date]];
    
    self.taskService = [VAKTaskService sharedVAKTaskService];
    
    if (self.arrayOfTasksForSelectedGroup) {
        self.navigationItem.title = VAKTaskOfSelectedGroup;
        self.editButton = [[UIBarButtonItem alloc] initWithTitle:VAKEditButton style:UIBarButtonItemStyleDone target:self action:@selector(editTaskButtonPressed)];
        self.navigationItem.leftBarButtonItem = self.editButton;
        self.backButton = [[UIBarButtonItem alloc] initWithTitle:VAKBackButton style:UIBarButtonItemStylePlain target:self action:@selector(backButtonPressed)];
        NSArray *arrayLeftButton = [NSArray arrayWithObjects:self.editButton, self.backButton, nil];
        self.navigationItem.leftBarButtonItems = arrayLeftButton;
        for (VAKTask *task in self.arrayOfTasksForSelectedGroup) {
            if (task.isCompleted) {
                [self.arrayTodayTaskCompleted addObject:task];
            }
            else {
                [self.arrayTodayTaskNotCompleted addObject:task];
            }
        }
    }
    else {
        self.navigationItem.title = VAKToday;
        self.editButton = [[UIBarButtonItem alloc] initWithTitle:VAKEditButton style:UIBarButtonItemStyleDone target:self action:@selector(editTaskButtonPressed)];
        self.navigationItem.leftBarButtonItem = self.editButton;
        for (VAKTask *task in self.taskService.groupCompletedTasks) {
            NSString *taskDate = [self.formatter stringFromDate:task.startedAt];
            if (task.isCompleted && [taskDate isEqualToString:currentDate]) {
                [self.arrayTodayTaskCompleted addObject:task];
            }
        }
        for (VAKTask *task in self.taskService.groupNotCompletedTasks) {
            NSString *taskDate = [self.formatter stringFromDate:task.startedAt];
            if (!task.isCompleted && [taskDate isEqualToString:currentDate]) {
                [self.arrayTodayTaskNotCompleted addObject:task];
            }
        }
    }
    
    self.addButton = [[UIBarButtonItem alloc] initWithTitle:VAKAddButton style:UIBarButtonItemStylePlain target:self action:@selector(addTaskButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.addButton;
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
    if (section == 0) {
        return [self.arrayTodayTaskNotCompleted count];
    }
    return [self.arrayTodayTaskCompleted count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];
    
    if (indexPath.section == 0) {
        VAKTask *notCompletedTask = self.arrayTodayTaskNotCompleted[indexPath.row];
        cell.taskNameLabel.text = notCompletedTask.taskName;
        cell.taskNoteLabel.text = notCompletedTask.notes;
        cell.taskStartDateLabel.text = [self.formatter stringFromDate:notCompletedTask.startedAt];
    }
    else {
        VAKTask *completedTask = self.arrayTodayTaskCompleted[indexPath.row];
        cell.taskNameLabel.text = completedTask.taskName;
        cell.taskNoteLabel.text = completedTask.notes;
        cell.taskStartDateLabel.text = [self.formatter stringFromDate:completedTask.startedAt];
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
            [self.arrayTodayTaskNotCompleted exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        }
        else {
            [self.arrayTodayTaskCompleted exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        }
    }

}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKStoriboardIdentifierDetailTask];
    VAKTask *currentTask = nil;
    if (indexPath.section == 0) {
        currentTask = self.arrayTodayTaskNotCompleted[indexPath.row];
    }
    else {
        currentTask = self.arrayTodayTaskCompleted[indexPath.row];
    }
    detailViewController.task = currentTask;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VAKDeleteTaskTitle message:VAKWarningDeleteMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:VAKOkButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (indexPath.section == 0)
        {
            [self.arrayTodayTaskNotCompleted removeObjectAtIndex:indexPath.row];
        }
        else {
            [self.arrayTodayTaskCompleted removeObjectAtIndex:indexPath.row];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:VAKCancelButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:VAKDoneButton handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.section == 0) {
            VAKTask *task = self.arrayTodayTaskNotCompleted[indexPath.row];
            [self.arrayTodayTaskCompleted addObject:self.arrayTodayTaskNotCompleted[indexPath.row]];
            [self.arrayTodayTaskNotCompleted removeObjectAtIndex:indexPath.row];
            task.completed = YES;
            [self.tableView reloadData];
        }
    }];
    doneAction.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:VAKDelete handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction, doneAction];
}

#pragma mark - delegate add task

- (void)addNewTaskWithTask:(VAKTask *)task {
    [self.taskService addTask:task];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:VAKKeySort ascending:YES];
    [self.taskService.tasks sortUsingDescriptors:@[sortDescriptor]];
    if (task.isCompleted) {
        [self.arrayTodayTaskCompleted addObject:task];
    }
    else {
        [self.arrayTodayTaskNotCompleted addObject:task];
    }
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:VAKAddTaskForGroup object:nil];
}

@end
