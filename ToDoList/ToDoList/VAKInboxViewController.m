#import "VAKInboxViewController.h"
#import "Constants.h"
#import "VAKCustumCell.h"

@interface VAKInboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseDateOrGroupSorted;
@property (nonatomic, strong) VAKTaskService *taskService;
@property (nonatomic, strong) VAKSearchViewController *searchViewController;
@property (nonatomic, strong) VAKTodayViewController *todayViewController;
@property (nonatomic, strong) VAKToDoListViewController *toDoListViewController;
@property (strong, nonatomic) NSMutableDictionary *dictionaryDate;
@property (strong, nonatomic) NSMutableDictionary *dictionaryGroup;
@property (strong, nonatomic) NSArray *arrayKeysDate;
@property (strong, nonatomic) NSArray *arrayKeysGroup;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (NSDictionary *)dictionaryDate {
    if (!_dictionaryDate) {
        _dictionaryDate = [NSMutableDictionary dictionary];
    }
    return _dictionaryDate;
}

- (NSDictionary *)dictionaryGroup {
    if (!_dictionaryGroup) {
        _dictionaryGroup = [NSMutableDictionary dictionary];
    }
    return _dictionaryGroup;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskService = [[VAKTaskService alloc]init];
    self.tabBarController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChanged) name:VAKTaskWasChanged object:nil];
    
//    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
//    NSDateComponents *dateComponents = [currentCalendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];

    self.taskService = [VAKTaskService initDefaultTaskService];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"dd.MM.YYYY";
    
    for (int i = 0; i < [self.taskService.tasks count]; i++) {
        VAKTask *currentTask = self.taskService.tasks[i];
        NSString *currentDate = [self.dateFormatter stringFromDate:currentTask.startedAt];
        NSString *currentGroup = currentTask.currentGroup;
        
        if (self.dictionaryDate[currentDate] == nil) {
            [self.dictionaryDate setObject:[[NSMutableArray alloc] init] forKey:currentDate];
        }
        
        if (self.dictionaryGroup[currentGroup] == nil) {
            [self.dictionaryGroup setObject:[[NSMutableArray alloc] init] forKey:currentGroup];
        }
        
    }
    
    NSArray *arrayKeysDate = [self.dictionaryDate allKeys];
    arrayKeysDate = [arrayKeysDate sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSArray *arrayKeysGroup = [self.dictionaryGroup allKeys];
    arrayKeysGroup = [arrayKeysGroup sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    self.arrayKeysDate = arrayKeysDate;
    self.arrayKeysGroup = arrayKeysGroup;
    
    for (VAKTask *task in self.taskService.tasks) {
        NSString *taskDate = [self.dateFormatter stringFromDate:task.startedAt];
        NSString *taskGroup = task.currentGroup;
        NSMutableArray *arrayDate = [self.dictionaryDate objectForKey:taskDate];
        [arrayDate addObject:task];
        NSMutableArray *arrayGroup = [self.dictionaryGroup objectForKey:taskGroup];
        [arrayGroup addObject:task];
    }
    
    
//    NSLog(@"%@",self.dictionaryDate);
    
    
    
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
        NSArray *arrayCurrentSection = [self.dictionaryDate objectForKey:self.arrayKeysDate[indexPath.section]];
        VAKTask *task = arrayCurrentSection[indexPath.row];
        cell.taskNameLabel.text = task.taskName;
        cell.taskNoteLabel.text = task.notes;
        cell.taskStartDateLabel.text = [self.dateFormatter stringFromDate:task.startedAt];
    }
    else {
        NSArray *arrayCurrentSection = [self.dictionaryGroup objectForKey:self.arrayKeysGroup[indexPath.section]];
        VAKTask *task = arrayCurrentSection[indexPath.row];
        cell.taskNameLabel.text = task.taskName;
        cell.taskNoteLabel.text = task.notes;
        cell.taskStartDateLabel.text = [self.dateFormatter stringFromDate:task.startedAt];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
        return self.arrayKeysDate[section];
    }
    else {
        return self.arrayKeysGroup[section];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
//        NSLog(@"%ld",[self.dictionaryDate[self.arrayKeys[section]] count]);
        return [self.dictionaryDate[self.arrayKeysDate[section]] count];
    }
    else {
        return [self.dictionaryGroup[self.arrayKeysGroup[section]] count];
    }
//    return [self.taskService.tasks count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.chooseDateOrGroupSorted selectedSegmentIndex] == 0) {
//        NSLog(@"%ld",[self.dictionaryDate count]);
        return [self.dictionaryDate count];
    }
    else {
        return [self.dictionaryGroup count];
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
