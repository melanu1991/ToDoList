#import "VAKInboxViewController.h"
#import "Constants.h"

@interface VAKInboxViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) VAKTaskService *taskService;
@property (nonatomic, strong) VAKSearchViewController *searchViewController;

@end

@implementation VAKInboxViewController

//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
//
//    UINavigationController *myNavController = (UINavigationController *)viewController;
//    VAKSearchViewController *myController = [[myNavController childViewControllers] firstObject];
//    myController.tasks = [self.taskService.tasks copy];
//    [self.tabBarController setSelectedIndex:[self.tabBarController selectedIndex]];
//    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskService = [[VAKTaskService alloc]init];
    self.tabBarController.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChanged) name:VAKTaskWasChanged object:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKInboxCell];
    VAKTask *temp = self.taskService.tasks[indexPath.row];
    cell.textLabel.text = temp.taskName;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskService.tasks count];
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
