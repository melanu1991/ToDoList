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

- (IBAction)changeSegmentedControl:(UISegmentedControl *)sender {
    [self.tableView reloadData];
}

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//
//    UINavigationController *myNavController = (UINavigationController *)viewController;
//    
//    if ([self.tabBarController selectedIndex] == VAKIndexSearchView) {
//        self.searchViewController = [[myNavController childViewControllers] firstObject];
//        self.searchViewController.tasks = [self.taskService.tasks copy];
//        [[NSNotificationCenter defaultCenter] postNotificationName:VAKSwitchingBetweenTabs object:nil];
//    }
//    else if ([self.tabBarController selectedIndex] == VAKIndexTodayView) {
//        self.todayViewController = [[myNavController childViewControllers] firstObject];
//        
//    }
//    else if ([self.tabBarController selectedIndex] == VAKIndexToDoListView) {
//        self.toDoListViewController = [[myNavController childViewControllers] firstObject];
//    }
//
//    [self.tabBarController setSelectedIndex:[self.tabBarController selectedIndex]];
//}

- (void)finishedTaskById:(NSString *)taskId finishedDate:(NSDate *)date{
    for (int i = 0; i < self.taskService.tasks.count; i++) {
        VAKTask *task = self.taskService.tasks[i];
        if ([task.taskId isEqualToString:taskId]) {
            task.completed = YES;
            task.finishedAt = date;
        }
    }
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:VAKDetailSegue])
    {
        NSIndexPath *index = [self.tableView indexPathForCell:sender];
        VAKTask *task = (VAKTask *)self.taskService.tasks[index.row];
        VAKDetailViewController  *detailController = [segue destinationViewController];
        detailController.delegate = self;
        detailController.task = task;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskService = [[VAKTaskService alloc]init];
    self.tabBarController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChanged) name:VAKTaskWasChanged object:nil];

    self.taskService = [VAKTaskService initDefaultTaskService];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"dd.MM.YYYY";
    
//    for (int i = 0; i < [self.taskService.tasks count]; i++) {
//        VAKTask *currentTask = self.taskService.tasks[i];
//        NSString *currentDate = [self.dateFormatter stringFromDate:currentTask.startedAt];
//        NSString *currentGroup = currentTask.currentGroup;
//        
//        if (self.dictionaryDate[currentDate] == nil) {
//            [self.dictionaryDate setObject:[[NSMutableArray alloc] init] forKey:currentDate];
//        }
//        
//        if (self.dictionaryGroup[currentGroup] == nil) {
//            [self.dictionaryGroup setObject:[[NSMutableArray alloc] init] forKey:currentGroup];
//        }
//        
//
//        
//    }
    
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    
    [self.taskService sortArrayKeys];
    
//    NSArray *arrayKeysDate = [self.dictionaryDate allKeys];
//    arrayKeysDate = [arrayKeysDate sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
//        return [obj1 compare:obj2];
//    }];
//    
//    NSArray *arrayKeysGroup = [self.dictionaryGroup allKeys];
//    arrayKeysGroup = [arrayKeysGroup sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
//        return [obj1 compare:obj2];
//    }];
//    
//    self.arrayKeysDate = arrayKeysDate;
//    self.arrayKeysGroup = arrayKeysGroup;
    
//    for (VAKTask *task in self.taskService.tasks) {
//        NSString *taskDate = [self.dateFormatter stringFromDate:task.startedAt];
//        NSString *taskGroup = task.currentGroup;
//        NSMutableArray *arrayDate = [self.dictionaryDate objectForKey:taskDate];
//        [arrayDate addObject:task];
//        NSMutableArray *arrayGroup = [self.dictionaryGroup objectForKey:taskGroup];
//        [arrayGroup addObject:task];
//    }
    
    
//    NSLog(@"%@",self.dictionaryDate);
    
    
    
}

- (void)editButtonPressed {
    if ([self.editButton.title isEqualToString:@"Edit"]) {
        self.editButton.title = @"Done";
        self.tableView.editing = YES;
    }
    else {
        self.editButton.title = @"Edit";
        self.tableView.editing = NO;
    }
}

- (void)taskWasChanged {
    [self.tableView reloadData];
}

- (IBAction)addNewTask:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc]initWithNibName:VAKAddController bundle:nil];
    addTaskController.delegate = self;
    addTaskController.task = nil;
    [self.navigationController showViewController:addTaskController sender:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKTodayCell];
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKTodayCell];
    
//    VAKTask *temp = self.taskService.tasks[indexPath.row];
//    cell.textLabel.text = temp.taskName;
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    VAKDetailViewController *detailController = [self.storyboard instantiateViewControllerWithIdentifier:@"detailView"];
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
    
//    VAKDetailViewController  *detailController = [[VAKDetailViewController alloc] init];
//    detailController.delegate = self;
//    detailController.task = task;
//    [self.navigationController pushViewController:detailController animated:YES];
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
//        NSLog(@"%ld",[self.dictionaryDate[self.arrayKeys[section]] count]);
        return [self.taskService.dictionaryDate[self.taskService.arrayKeysDate[section]] count];
    }
    else {
        return [self.taskService.dictionaryGroup[self.taskService.arrayKeysGroup[section]] count];
    }
//    return [self.taskService.tasks count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
//        NSLog(@"%ld",[self.dictionaryDate count]);
        return [self.taskService.dictionaryDate count];
    }
    else {
        return [self.taskService.dictionaryGroup count];
    }
}

- (void)addNewTaskWithTask:(VAKTask *)task {
    [self.taskService addTask:task];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:VAKKeySort ascending:YES];
    [self.taskService.tasks sortUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
