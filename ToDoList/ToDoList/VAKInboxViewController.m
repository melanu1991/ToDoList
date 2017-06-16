#import "VAKInboxViewController.h"

@interface VAKInboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseDateOrGroupSorted;
@property (nonatomic, strong) VAKTaskService *taskService;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (assign, nonatomic, getter=isReverseOrder) BOOL reverseOrder;

@end

@implementation VAKInboxViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;

    self.taskService = [VAKTaskService sharedVAKTaskService];
    [self.taskService sortArrayKeysDate:self.isReverseOrder];
    [self.taskService sortArrayKeysGroup:self.isReverseOrder];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = VAKDateFormatWithoutHourAndMinute;

    self.editButton = [[UIBarButtonItem alloc] initWithTitle:VAKEditButton style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailWasChanged:) name:VAKTaskWasChanged object:nil];
}

#pragma mark - Notification detailWasChanged

- (void)detailWasChanged:(NSNotification *)notification {
    VAKTask *currentTask = [notification.userInfo objectForKey:@"currentObject"];
    NSString *lastDate = [notification.userInfo objectForKey:@"lastDate"];
    [self.taskService updateTask:currentTask lastDate:lastDate];
    [self.tableView reloadData];
}

#pragma mark - action

- (IBAction)changeSegmentedControl:(UISegmentedControl *)sender {
    [self.tableView reloadData];
}

- (void)finishedTaskById:(NSString *)taskId finishedDate:(NSDate *)date{
    for (VAKTask *task in self.taskService.tasks) {
        if ([task.taskId isEqualToString:taskId]) {
            task.completed = YES;
            task.finishedAt = date;
        }
    }
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
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc]initWithNibName:VAKAddController bundle:nil];
    addTaskController.delegate = self;
    addTaskController.task = nil;
    [self.navigationController showViewController:addTaskController sender:nil];
}

- (void)addNewTaskWithTask:(VAKTask *)task {
    [self.taskService addTask:task];
    [self.taskService sortArrayKeysGroup:self.isReverseOrder];
    [self.taskService sortArrayKeysDate:self.isReverseOrder];
    [self.tableView reloadData];
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
        cell.taskStartDateLabel.text = [self.dateFormatter stringFromDate:task.startedAt];
    }
    else {
        NSArray *arrayCurrentSection = [self.taskService.dictionaryGroup objectForKey:self.taskService.arrayKeysGroup[indexPath.section]];
        VAKTask *task = arrayCurrentSection[indexPath.row];
        cell.taskNameLabel.text = task.taskName;
        cell.taskNoteLabel.text = task.notes;
        cell.taskStartDateLabel.text = [self.dateFormatter stringFromDate:task.startedAt];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        return self.taskService.arrayKeysDate[section];
    }
    else {
        return self.taskService.arrayKeysGroup[section];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        return [self.taskService.dictionaryDate[self.taskService.arrayKeysDate[section]] count];
    }
    else {
        return [self.taskService.dictionaryGroup[self.taskService.arrayKeysGroup[section]] count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        return [self.taskService.dictionaryDate count];
    }
    else {
        return [self.taskService.dictionaryGroup count];
    }
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    editTaskController.delegate = self;
    
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        NSArray *temp = self.taskService.dictionaryDate[self.taskService.arrayKeysDate[indexPath.section]];
        VAKTask *task = temp[indexPath.row];
        editTaskController.task = task;
    }
    else {
        NSArray *temp = self.taskService.dictionaryGroup[self.taskService.arrayKeysGroup[indexPath.section]];
        VAKTask *task = temp[indexPath.row];
        editTaskController.task = task;
    }
    
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKTask *currentTask = [self currentTaskWithIndexPath:indexPath];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VAKDeleteTaskTitle message:VAKWarningDeleteMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:VAKOkButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.taskService removeTaskById:currentTask.taskId];
        [self.tableView reloadData];
        //такой вариант имеет право на жизнь только в случае, когда в группе/дате есть хотя бы 1 таск, а иначе краш приложения
        //можно конечно возвращать булевское значение и если оно YES тогда перегружать только строчку, иначе таблицу
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:VAKCancelButton style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:VAKDoneButton handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        VAKTask *currentTask = [self currentTaskWithIndexPath:indexPath];
        if (!currentTask.isCompleted) {
            currentTask.completed = YES;
            currentTask.finishedAt = [NSDate date];
            [self.taskService updateTaskForCompleted:currentTask];
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

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
//            NSMutableArray *arrayObjectForDate = self.taskService.dictionaryDate[self.taskService.arrayKeysDate[indexPath.section]];
//            VAKTask *task = arrayObjectForDate[indexPath.row];
//            NSMutableArray *arrayObjectForGroup = self.taskService.dictionaryGroup[task.currentGroup];
//            [arrayObjectForGroup removeObject:task];
//            [arrayObjectForDate removeObject:task];
//            [self.taskService removeTaskById:task.taskId];
//            
//            if ([arrayObjectForDate count] == 0) {
//                [self.taskService.dictionaryDate removeObjectForKey:self.taskService.arrayKeysDate[indexPath.section]];
//                [self.taskService sortArrayKeysDate:self.isReverseOrder];
//                [self.tableView reloadData];
//                return;
//            }
//        }
//        else {
//            NSMutableArray *arrayObjectForGroup = self.taskService.dictionaryGroup[self.taskService.arrayKeysGroup[indexPath.section]];
//            VAKTask *task = arrayObjectForGroup[indexPath.row];
//            
//            NSMutableArray *arrayObjectForDate = self.taskService.dictionaryDate[[self.dateFormatter stringFromDate:task.startedAt]];
//            
//            [arrayObjectForGroup removeObject:task];
//            [arrayObjectForDate removeObject:task];
//            [self.taskService removeTaskById:task.taskId];
//
//            if ([arrayObjectForGroup count] == 0) {
//                [self.taskService.dictionaryGroup removeObjectForKey:self.taskService.arrayKeysGroup[indexPath.section]];
//                [self.taskService sortArrayKeysGroup:self.isReverseOrder];
//                [self.tableView reloadData];
//                return;
//            }
//        }
//    }
//    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//}

#pragma mark - helper methods

- (VAKTask *)currentTaskWithIndexPath:(NSIndexPath *)indexPath {
    VAKTask *currentTask = nil;
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        NSMutableArray *arrayDate = self.taskService.dictionaryDate[self.taskService.arrayKeysDate[indexPath.section]];
        currentTask = arrayDate[indexPath.row];
    }
    else {
        NSMutableArray *arrayGroup = self.taskService.dictionaryGroup[self.taskService.arrayKeysGroup[indexPath.section]];
        currentTask = arrayGroup[indexPath.row];
    }
    return currentTask;
}

#pragma mark - implemented deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
