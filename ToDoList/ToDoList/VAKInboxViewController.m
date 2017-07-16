#import "VAKInboxViewController.h"

@interface VAKInboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseDateOrGroupSorted;
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
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(VAKEditButton, nil) style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    if (notification.userInfo[VAKDetailTaskWasChanged]) {
        VAKTask *currentTask = notification.userInfo[VAKCurrentTask];
        NSString *newDate = notification.userInfo[VAKNewDate];
        NSString *newTaskName = notification.userInfo[VAKNewTaskName];
        NSString *newNotes = notification.userInfo[VAKNewNotes];
        if (![newDate isEqualToString:[NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute]] || ![newNotes isEqualToString:currentTask.notes] || ![newTaskName isEqualToString:currentTask.taskName]) {
            self.needToReloadData = YES;
        }
    }
    else if (notification.userInfo[VAKAddNewTask] || notification.userInfo[VAKDeleteTask] || notification.userInfo[VAKWasEditNameGroup] || notification.userInfo[VAKDeleteGroupTask]) {
        self.needToReloadData = YES;
    }
}

#pragma mark - action

- (IBAction)changeSegmentedControl:(UISegmentedControl *)sender {
    [self.tableView reloadData];
}

- (void)editButtonPressed {
    if ([self.editButton.title isEqualToString:NSLocalizedString(VAKEditButton, nil)]) {
        self.editButton.title = NSLocalizedString(VAKDoneButton, nil);
        self.tableView.editing = YES;
    }
    else {
        self.editButton.title = NSLocalizedString(VAKEditButton, nil);
        self.tableView.editing = NO;
    }
}

- (IBAction)sortDateOrGroup:(UIBarButtonItem *)sender {
    self.reverseOrder = !self.reverseOrder;
    [[VAKTaskService sharedVAKTaskService] sortArrayKeysDate:self.isReverseOrder];
    [[VAKTaskService sharedVAKTaskService] sortArrayKeysGroup:self.isReverseOrder];
    [self.tableView reloadData];
}

- (IBAction)addNewTask:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    addTaskController.task = nil;
    addTaskController.currentGroup = VAKInbox;
    [self.navigationController showViewController:addTaskController sender:nil];
}

#pragma mark - implemented UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];

    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSArray *arrayCurrentSection = [[VAKTaskService sharedVAKTaskService].dictionaryDate objectForKey:[VAKTaskService sharedVAKTaskService].arrayKeysDate[indexPath.section]];
        VAKTask *task = arrayCurrentSection[indexPath.row];
        cell.taskNameLabel.text = task.taskName;
        cell.taskNoteLabel.text = task.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
    }
    else {
        NSArray *arrayCurrentSection = [[VAKTaskService sharedVAKTaskService].dictionaryGroup objectForKey:[VAKTaskService sharedVAKTaskService].arrayKeysGroup[indexPath.section]];
        VAKTask *task = arrayCurrentSection[indexPath.row];
        cell.taskNameLabel.text = task.taskName;
        cell.taskNoteLabel.text = task.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        return [VAKTaskService sharedVAKTaskService].arrayKeysDate[section];
    }
    return [VAKTaskService sharedVAKTaskService].arrayKeysGroup[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        return [[VAKTaskService sharedVAKTaskService].dictionaryDate[[VAKTaskService sharedVAKTaskService].arrayKeysDate[section]] count];
    }
    return [[VAKTaskService sharedVAKTaskService].dictionaryGroup[[VAKTaskService sharedVAKTaskService].arrayKeysGroup[section]] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        return [[VAKTaskService sharedVAKTaskService].dictionaryDate count];
    }
    return [[VAKTaskService sharedVAKTaskService].dictionaryGroup count];
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSArray *temp = [VAKTaskService sharedVAKTaskService].dictionaryDate[[VAKTaskService sharedVAKTaskService].arrayKeysDate[indexPath.section]];
        VAKTask *task = temp[indexPath.row];
        editTaskController.task = task;
    }
    else {
        NSArray *temp = [VAKTaskService sharedVAKTaskService].dictionaryGroup[[VAKTaskService sharedVAKTaskService].arrayKeysGroup[indexPath.section]];
        VAKTask *task = temp[indexPath.row];
        editTaskController.task = task;
    }
    
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKTask *currentTask = [self currentTaskWithIndexPath:indexPath];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKDeleteTaskTitle, nil) message:NSLocalizedString(VAKWarningDeleteMessage, nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[VAKTaskService sharedVAKTaskService] removeTaskById:currentTask.taskId];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:currentTask, VAKCurrentTask, VAKDeleteTask, VAKDeleteTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
        [self.tableView reloadData];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDoneButton, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        VAKTask *currentTask = [self currentTaskWithIndexPath:indexPath];
        if (!currentTask.isCompleted) {
            [[VAKTaskService sharedVAKTaskService] updateTaskForCompleted:currentTask];
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
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDelete, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
       [self presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction, doneAction];
}

#pragma mark - helper methods

- (VAKTask *)currentTaskWithIndexPath:(NSIndexPath *)indexPath {
    VAKTask *currentTask = nil;
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSMutableArray *arrayDate = [VAKTaskService sharedVAKTaskService].dictionaryDate[[VAKTaskService sharedVAKTaskService].arrayKeysDate[indexPath.section]];
        currentTask = arrayDate[indexPath.row];
    }
    else {
        NSMutableArray *arrayGroup = [VAKTaskService sharedVAKTaskService].dictionaryGroup[[VAKTaskService sharedVAKTaskService].arrayKeysGroup[indexPath.section]];
        currentTask = arrayGroup[indexPath.row];
    }
    return currentTask;
}

#pragma mark - implemented deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
