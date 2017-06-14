#import "VAKInboxViewController.h"
#import "Constants.h"
#import "VAKCustumCell.h"

@interface VAKInboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseDateOrGroupSorted;
@property (nonatomic, strong) VAKTaskService *taskService;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) UIBarButtonItem *editButton;

@end

@implementation VAKInboxViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.delegate = self;

    self.taskService = [VAKTaskService initDefaultTaskService];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = VAKDateFormatWithoutHourAndMinute;

    self.editButton = [[UIBarButtonItem alloc] initWithTitle:VAKEditButton style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    
    [self.taskService sortArrayKeysDate];
    [self.taskService sortArrayKeysGroup];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailWasChanged) name:VAKTaskWasChanged object:nil];
}

#pragma mark - Notification detailWasChanged

- (void)detailWasChanged {
    [self.tableView reloadData];
}

#pragma mark - action

- (IBAction)changeSegmentedControl:(UISegmentedControl *)sender {
    [self.tableView reloadData];
}

//переделать алгоритм!!!
- (void)finishedTaskById:(NSString *)taskId finishedDate:(NSDate *)date{
    for (int i = 0; i < self.taskService.tasks.count; i++) {
        VAKTask *task = self.taskService.tasks[i];
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

- (IBAction)addNewTask:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc]initWithNibName:VAKAddController bundle:nil];
    addTaskController.delegate = self;
    addTaskController.task = nil;
    [self.navigationController showViewController:addTaskController sender:nil];
}

- (void)addNewTaskWithTask:(VAKTask *)task {
    [self.taskService addTask:task];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:VAKKeySort ascending:YES];
    [self.taskService.tasks sortUsingDescriptors:@[sortDescriptor]];
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
    
    VAKDetailViewController *detailController = [self.storyboard instantiateViewControllerWithIdentifier:VAKStoriboardIdentifierDetailTask];
    detailController.delegate = self;
    
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        NSArray *temp = self.taskService.dictionaryDate[self.taskService.arrayKeysDate[indexPath.section]];
        VAKTask *task = temp[indexPath.row];
        detailController.task = task;
    }
    else {
        NSArray *temp = self.taskService.dictionaryGroup[self.taskService.arrayKeysGroup[indexPath.section]];
        VAKTask *task = temp[indexPath.row];
        detailController.task = task;
    }
    
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
            NSMutableArray *arrayObjectForDate = self.taskService.dictionaryDate[self.taskService.arrayKeysDate[indexPath.section]];
            [arrayObjectForDate removeObjectAtIndex:indexPath.row];
            if ([arrayObjectForDate count] == 0) {
                [self.taskService.dictionaryDate removeObjectForKey:self.taskService.arrayKeysDate[indexPath.section]];
                [self.taskService sortArrayKeysDate];
                [self.tableView reloadData];
                return;
            }
        }
        else {
            NSMutableArray *arrayObjectForGroup = self.taskService.dictionaryGroup[self.taskService.arrayKeysGroup[indexPath.section]];
            [arrayObjectForGroup removeObjectAtIndex:indexPath.row];
            if ([arrayObjectForGroup count] == 0) {
                [self.taskService.dictionaryGroup removeObjectForKey:self.taskService.arrayKeysGroup[indexPath.section]];
                [self.taskService sortArrayKeysGroup];
                [self.tableView reloadData];
                return;
            }
        }
    }
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - implemented deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
