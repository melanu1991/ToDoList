#import "VAKTodayViewController.h"

@interface VAKTodayViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (assign, nonatomic) BOOL needToReloadData;

@end

@implementation VAKTodayViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
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

    if (self.needToReloadData) {
        [self.tableView reloadData];
    }
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    self.needToReloadData = YES;
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

#pragma mark - implemented UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return VAKTwo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == VAKZero) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startedAt" ascending:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == NO"];
        return [[[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:sortDescriptor predicate:predicate] count];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startedAt" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == YES"];
    return [[[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:sortDescriptor predicate:predicate] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSDate *startDate = [NSDate dateFromString:[NSString stringWithFormat:@"%ld.%ld.%ld", day, month, year] format:VAKDateFormatWithoutHourAndMinute];
    NSDate *finishDate = [NSDate dateFromString:[NSString stringWithFormat:@"%ld.%ld.%ld 23:59", day, month, year] format:@"dd.MM.YYYY H:m"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startedAt" ascending:YES];
    if (indexPath.section == VAKZero) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == NO AND startedAt >= %@ AND startedAt <= %@", startDate, finishDate];
        NSArray *arrayNotCompletedTask = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:sortDescriptor predicate:predicate];
        Task *notCompletedTask = arrayNotCompletedTask[indexPath.row];
        cell.taskNameLabel.text = notCompletedTask.name;
        cell.taskNoteLabel.text = notCompletedTask.notes;
        cell.taskStartDateLabel.text = [NSDate dateStringFromDate:notCompletedTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == YES"];
        NSArray *arrayCompletedTask = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:sortDescriptor predicate:predicate];
        Task *completedTask = arrayCompletedTask[indexPath.row];
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    

}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    Task *currentTask = nil;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startedAt" ascending:YES];
    if (indexPath.section == VAKZero) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == NO"];
        NSArray *arrayNotCompletedTask = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:sortDescriptor predicate:predicate];
        currentTask = arrayNotCompletedTask[indexPath.row];
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == YES"];
        NSArray *arrayCompletedTask = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:sortDescriptor predicate:predicate];
        currentTask = arrayCompletedTask[indexPath.row];
    }

    editTaskController.task = currentTask;
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    __block Task *currentTask = nil;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    NSDate *startDate = [NSDate dateFromString:[NSString stringWithFormat:@"%ld.%ld.%ld", day, month, year] format:VAKDateFormatWithoutHourAndMinute];
    NSDate *finishDate = [NSDate dateFromString:[NSString stringWithFormat:@"%ld.%ld.%ld 23:59", day, month, year] format:@"dd.MM.YYYY H:m"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startedAt" ascending:YES];
    if (indexPath.section == VAKZero) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == NO AND startedAt >= %@ AND startedAt <= %@", startDate, finishDate];
        NSArray *arrayNotCompletedTask = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:sortDescriptor predicate:predicate];
        currentTask = arrayNotCompletedTask[indexPath.row];
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"completed == YES"];
        NSArray *arrayCompletedTask = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:sortDescriptor predicate:predicate];
        currentTask = arrayCompletedTask[indexPath.row];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKDeleteTaskTitle, nil) message:VAKWarningDeleteMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:VAKDeleteTask, VAKDeleteTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDoneButton, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        

        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:currentTask, VAKCurrentTask, VAKDoneTask, VAKDoneTask, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];

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
