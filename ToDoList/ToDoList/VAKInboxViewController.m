#import "VAKInboxViewController.h"

@interface VAKInboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseDateOrGroupSorted;
@property (nonatomic, strong) VAKTaskService *taskService;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (assign, nonatomic, getter=isReverseOrder) BOOL reverseOrder;
@property (assign, nonatomic) BOOL needToReloadData;

@end

@implementation VAKInboxViewController

#pragma mark - life cycle view controller

- (void)viewWillAppear:(BOOL)animated {
    if (self.needToReloadData) {
        [self.tableView reloadData];
        self.needToReloadData = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;

    self.taskService = [VAKTaskService sharedVAKTaskService];

    self.editButton = [[UIBarButtonItem alloc] initWithTitle:VAKEditButton style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    if (notification.userInfo[VAKDetailTaskWasChanged]) {
        VAKTask *currentTask = notification.userInfo[VAKCurrentTask];
        NSString *lastDate = notification.userInfo[VAKLastDate];
        NSString *lastTaskName = notification.userInfo[VAKLastTaskName];
        NSString *lastNotes = notification.userInfo[VAKLastNotes];
        if (![lastDate isEqualToString:[NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute]] || ![lastNotes isEqualToString:currentTask.notes] || ![lastTaskName isEqualToString:currentTask.taskName]) {
            self.needToReloadData = YES;
        }
    }
    else if (notification.userInfo[VAKAddNewTask] || notification.userInfo[VAKDeleteTask] || notification.userInfo[VAKWasEditNameGroup] || notification.userInfo[VAKDeleteGroupTask] || notification.userInfo[VAKAddProject]) {
        self.needToReloadData = YES;
    }
}

#pragma mark - action

- (IBAction)changeSegmentedControl:(UISegmentedControl *)sender {
    [self.tableView reloadData];
}

- (void)editButtonPressed {
    if ([self.editButton.title isEqualToString:VAKEditButton]) {
        self.editButton.title = VAKDoneButton;
        self.tableView.editing = YES;
    }
    else {
        self.editButton.title = VAKEditButton;
        self.tableView.editing = NO;
    }
}

- (IBAction)sortDateOrGroup:(UIBarButtonItem *)sender {
    self.reverseOrder = !self.reverseOrder;
    [self.taskService sortArrayKeysDate:self.isReverseOrder];
    [self.taskService sortArrayKeysGroup:self.isReverseOrder];
    [self.tableView reloadData];
}

- (IBAction)addNewTask:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    addTaskController.task = nil;
    for (VAKToDoList *item in self.taskService.toDoListArray) {
        if ([item.toDoListName isEqualToString:VAKInbox]) {
            addTaskController.currentGroup = item;
            break;
        }
    }
    [self.navigationController showViewController:addTaskController sender:nil];
}

#pragma mark - implemented UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];

    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        NSArray *arrayCurrentSection = [self.taskService.dictionaryDate objectForKey:self.taskService.arrayKeysDate[indexPath.section]];
        VAKTask *task = arrayCurrentSection[indexPath.row];
        cell.taskNameLabel.text = task.taskName;
        cell.taskNoteLabel.text = task.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
    }
    else {
        VAKToDoList *currentProject = self.taskService.toDoListArray[indexPath.section];
        VAKTask *task = currentProject.toDoListArrayTasks[indexPath.row];
        cell.taskNameLabel.text = task.taskName;
        cell.taskNoteLabel.text = task.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        return self.taskService.arrayKeysDate[section];
    }
    else {
        VAKToDoList *currentProject = self.taskService.toDoListArray[section];
        return currentProject.toDoListName;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        return [self.taskService.dictionaryDate[self.taskService.arrayKeysDate[section]] count];
    }
    else {
        VAKToDoList *currentProject = self.taskService.toDoListArray[section];
        return [currentProject.toDoListArrayTasks count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        return [self.taskService.dictionaryDate count];
    }
    else {
        return [self.taskService.toDoListArray count];
    }
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        NSArray *temp = self.taskService.dictionaryDate[self.taskService.arrayKeysDate[indexPath.section]];
        VAKTask *task = temp[indexPath.row];
        editTaskController.task = task;
    }
    else {
        VAKToDoList *currentProject = self.taskService.toDoListArray[indexPath.section];
        VAKTask *task = currentProject.toDoListArrayTasks[indexPath.row];
        editTaskController.task = task;
    }
    
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKTask *currentTask = [self currentTaskWithIndexPath:indexPath];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VAKDeleteTaskTitle message:VAKWarningDeleteMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:VAKOkButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.taskService removeTaskById:currentTask.taskId];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:currentTask, VAKCurrentTask, VAKDeleteTask, VAKDeleteTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
        [self.tableView reloadData];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:VAKCancelButton style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:VAKDoneButton handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        VAKTask *currentTask = [self currentTaskWithIndexPath:indexPath];
        if (!currentTask.isCompleted) {
            [self.taskService updateTaskForCompleted:currentTask];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:currentTask, VAKCurrentTask, VAKDoneTask, VAKDoneTask, nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
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

#pragma mark - helper methods

- (VAKTask *)currentTaskWithIndexPath:(NSIndexPath *)indexPath {
    VAKTask *currentTask = nil;
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        NSMutableArray *arrayDate = self.taskService.dictionaryDate[self.taskService.arrayKeysDate[indexPath.section]];
        currentTask = arrayDate[indexPath.row];
    }
    else {
        VAKToDoList *currentProject = self.taskService.toDoListArray[indexPath.section];
        currentTask = currentProject.toDoListArrayTasks[indexPath.row];
    }
    return currentTask;
}

#pragma mark - implemented deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
