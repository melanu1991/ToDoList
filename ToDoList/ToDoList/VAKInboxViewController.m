#import "VAKInboxViewController.h"
#import "VAKAddTaskController.h"
#import "VAKDetailViewController.h"
#import "VAKTaskService.h"
#import "VAKTask.h"

@interface VAKInboxViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (nonatomic, strong) VAKTaskService *taskService;
@end

@implementation VAKInboxViewController

- (void)finishedTaskById:(NSString *)taskId finishedDate:(NSDate *)date{
    for (int i = 0; i < self.taskService.tasks.count; i++) {
        VAKTask *task = self.taskService.tasks[i];
        if ([task.taskId isEqualToString:taskId]) {
            task.completed = YES;
            task.finishedAt = date;
        }
    }
    [self.tableViewOutlet reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableViewOutlet deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailSegue"])
    {
        NSIndexPath *index = [self.tableViewOutlet indexPathForCell:sender];
        VAKTask *task = (VAKTask *)self.taskService.tasks[index.row];
        VAKDetailViewController  *detailController = [segue destinationViewController];
        detailController.delegate = self;
        [detailController detailTaskWithTask:task];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskService = [[VAKTaskService alloc]init];
}

- (IBAction)addNewTask:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc]initWithNibName:@"VAKAddTaskController" bundle:nil];
    addTaskController.delegate = self;
    [self.navigationController showViewController:addTaskController sender:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inboxCell"];
    VAKTask *temp = self.taskService.tasks[indexPath.row];
    cell.textLabel.text = temp.taskName;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskService.tasks count];
}

- (void)addNewTaskWithTask:(VAKTask *)task {
    [self.taskService addTask:task];
    [self.tableViewOutlet reloadData];
}

@end
