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
    self.reverseOrder = YES;
    self.tabBarController.delegate = self;
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(VAKEditButton, nil) style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    self.needToReloadData = YES;
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
    for (ToDoList *item in [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:nil]) {
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

    Task *currentTask = [self returnSelectedTaskByIndexPath:indexPath];
    cell.taskNameLabel.text = currentTask.name;
    cell.taskNoteLabel.text = currentTask.notes;
    cell.taskStartDateLabel.text = [NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Date" sortDescriptor:descriptor predicate:nil];
        Date *date = arrayEntity[section];
        return date.date;
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:self.reverseOrder];
    NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:descriptor predicate:nil];
    ToDoList *toDoList = arrayEntity[section];
    return toDoList.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Date" sortDescriptor:descriptor predicate:nil];
        Date *date = arrayEntity[section];
        return date.tasks.count;
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:self.reverseOrder];
    NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:descriptor predicate:nil];
    ToDoList *toDoList = arrayEntity[section];
    return toDoList.arrayTasks.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Date" sortDescriptor:nil predicate:nil];
        return arrayEntity.count;
    }
    NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:nil];
    return arrayEntity.count;
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    
    editTaskController.task = [self returnSelectedTaskByIndexPath:indexPath];
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Task *task = [self returnSelectedTaskByIndexPath:indexPath];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDoneButton, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:VAKDoneTask, VAKDoneTask, task, VAKCurrentTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
        
    }];
    
    if (task.completed) {
        doneAction.backgroundColor = [UIColor grayColor];
    }
    else {
        doneAction.backgroundColor = [UIColor blueColor];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKDeleteTaskTitle, nil) message:NSLocalizedString(VAKWarningDeleteMessage, nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:VAKDeleteTask, VAKDeleteTask, task, VAKCurrentTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
        [self.tableView reloadData];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDelete, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
       [self presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    return @[deleteAction, doneAction];
}

#pragma mark - helpers

- (Task *)returnSelectedTaskByIndexPath:(NSIndexPath *)indexPath {
    Task *task = nil;
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == VAKZero) {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Date" sortDescriptor:descriptor predicate:nil];
        Date *date = arrayEntity[indexPath.section];
        NSArray *arrayTask = [date.tasks allObjects];
        task = arrayTask[indexPath.row];
    }
    else {
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:self.reverseOrder];
        NSArray *arrayEntity = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:descriptor predicate:nil];
        ToDoList *toDoList = arrayEntity[indexPath.section];
        NSArray *arrayTasks = [toDoList.arrayTasks allObjects];
        arrayTasks = [arrayTasks sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            Task *task1 = (Task *)obj1;
            Task *task2 = (Task *)obj2;
            return [task1.startedAt compare:task2.startedAt];
        }];
        task = arrayTasks[indexPath.row];
    }
    return task;
}

#pragma mark - implemented deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
