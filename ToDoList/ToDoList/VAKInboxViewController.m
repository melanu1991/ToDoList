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
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    if (notification.userInfo[VAKDetailTaskWasChanged]) {
        Task *currentTask = notification.userInfo[VAKCurrentTask];
        NSString *newDate = notification.userInfo[VAKNewDate];
        NSString *newTaskName = notification.userInfo[VAKNewTaskName];
        NSString *newNotes = notification.userInfo[VAKNewNotes];
        if (![newDate isEqualToString:[NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute]] || ![newNotes isEqualToString:currentTask.notes] || ![newTaskName isEqualToString:currentTask.name]) {
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
    [self.tableView reloadData];
}

- (IBAction)addNewTask:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    addTaskController.task = nil;
    for (ToDoList *item in [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil]) {
        if ([item.name isEqualToString:VAKInbox]) {
            addTaskController.currentGroup = item;
            break;
        }
    }
    [self.navigationController showViewController:addTaskController sender:nil];
}

#pragma mark - implemented UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];

    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Date" sortDescriptor:descriptor];
        Date *date = arrayEntity[indexPath.section];
        NSArray *arrayTasksCurrentDate = [date.tasks allObjects];
        Task *currentTask = arrayTasksCurrentDate[indexPath.row];
        cell.taskNameLabel.text = currentTask.name;
        cell.taskNoteLabel.text = currentTask.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
    }
    else {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:descriptor];
        ToDoList *currentToDoList = arrayEntity[indexPath.section];
        Task *currentTask = [currentToDoList.arrayTasks allObjects][indexPath.row];
        cell.taskNameLabel.text = currentTask.name;
        cell.taskNoteLabel.text = currentTask.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Date" sortDescriptor:descriptor];
        Date *date = arrayEntity[section];
        return date.date;
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:self.reverseOrder];
    NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:descriptor];
    ToDoList *toDoList = arrayEntity[section];
    return toDoList.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Date" sortDescriptor:descriptor];
        Date *date = arrayEntity[section];
        return date.tasks.count;
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:self.reverseOrder];
    NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:descriptor];
    ToDoList *toDoList = arrayEntity[section];
    return toDoList.arrayTasks.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Date" sortDescriptor:descriptor];
        return arrayEntity.count;
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:self.reverseOrder];
    NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:descriptor];
    return arrayEntity.count;
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    
    
    
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKDeleteTaskTitle, nil) message:NSLocalizedString(VAKWarningDeleteMessage, nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [self.tableView reloadData];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDoneButton, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        
        
    }];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDelete, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
       [self presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction, doneAction];
}

#pragma mark - implemented deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
