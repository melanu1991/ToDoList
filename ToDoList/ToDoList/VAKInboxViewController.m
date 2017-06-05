#import "VAKInboxViewController.h"
#import "VAKAddTaskController.h"
#import "VAKTaskService.h"
#import "VAKTask.h"

@interface VAKInboxViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableViewOutlet;
@property (nonatomic, strong) VAKTaskService *taskService;
@end

@implementation VAKInboxViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.tableViewOutlet deselectRowAtIndexPath:indexPath animated:YES];
    
    
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
