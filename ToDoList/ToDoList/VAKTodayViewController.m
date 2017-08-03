#import "VAKTodayViewController.h"

@interface VAKTodayViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (assign, nonatomic, getter=isNeedToReloadData) BOOL needToReloadData;
@property (strong, nonatomic) NSArray *completedTasks;
@property (strong, nonatomic) NSArray *notCompletedTasks;

@end

@implementation VAKTodayViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
    [self initializationArraysCompletedAndNotCompletedTasks];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.isSelectedGroup) {
        self.navigationItem.title = self.currentGroup.name;
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
    }
    
    self.addButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(VAKAddButton, nil) style:UIBarButtonItemStylePlain target:self action:@selector(addTaskButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.addButton;
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    self.needToReloadData = YES;
    [self initializationArraysCompletedAndNotCompletedTasks];
    [self.tableView reloadData];
    self.needToReloadData = NO;
}

#pragma mark - action

- (void)backButtonPressed {
    self.selectedGroup = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTaskButtonPressed {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc] init];
    addTaskController.currentGroup = self.currentGroup;
    [self.navigationController pushViewController:addTaskController animated:YES];
}

- (void)editTaskButtonPressed {
    if ([self.editButton.title isEqualToString:NSLocalizedString(VAKEditButton, nil)]) {
        self.editButton.title = NSLocalizedString(VAKDoneButton, nil);
    }
    else {
        self.editButton.title = NSLocalizedString(VAKEditButton, nil);
    }
    [self.tableView setEditing:!self.tableView.editing];
}

#pragma mark - helpers

- (void)initializationArraysCompletedAndNotCompletedTasks {
    if (self.isSelectedGroup) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == NO AND toDoList == %@", self.currentGroup];
        self.notCompletedTasks = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
        predicate = [NSPredicate predicateWithFormat:@"completed == YES AND toDoList == %@", self.currentGroup];
        self.completedTasks = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == NO AND startedAt >= %@ AND startedAt <= %@", [self startedCurrentDate], [self finishedCurrentDate]];
        self.notCompletedTasks = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
        predicate = [NSPredicate predicateWithFormat:@"completed == YES AND startedAt >= %@ AND startedAt <= %@", [self startedCurrentDate], [self finishedCurrentDate]];
        self.completedTasks = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
    }
}

- (NSDate *)startedCurrentDate {
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    [components setHour:00];
    [components setMinute:00];
    [components setSecond:00];
    NSDate *startDate = [calendar dateFromComponents:components];
    return startDate;
}

- (NSDate *)finishedCurrentDate {
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    NSDate *finishDate = [calendar dateFromComponents:components];
    return finishDate;
}

- (Task *)backTaskByIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == VAKZero) {
        return self.notCompletedTasks[indexPath.row];
    }
    return self.completedTasks[indexPath.row];
}

#pragma mark - implemented UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return VAKTwo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == VAKZero) {
        return self.notCompletedTasks.count;
    }
    return self.completedTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];
    
    if (indexPath.section == VAKZero) {
        Task *notCompletedTask = self.notCompletedTasks[indexPath.row];
        cell.taskNameLabel.text = notCompletedTask.name;
        cell.taskNoteLabel.text = notCompletedTask.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:notCompletedTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
    }
    else {
        Task *completedTask = self.completedTasks[indexPath.row];
        cell.taskNameLabel.text = completedTask.name;
        cell.taskNoteLabel.text = completedTask.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:completedTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
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

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    
    Task *currentTask = [self backTaskByIndexPath:indexPath];

    editTaskController.task = currentTask;
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Task *currentTask = [self backTaskByIndexPath:indexPath];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKDeleteTaskTitle, nil) message:VAKWarningDeleteMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:VAKDeleteTask, VAKDeleteTask, currentTask, VAKCurrentTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
        [self.tableView reloadData];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDoneButton, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
    
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:currentTask, VAKCurrentTask, VAKDoneTask, VAKDoneTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
        [self.tableView reloadData];

    }];
    
    if (currentTask.completed) {
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
