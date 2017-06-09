#import "VAKTodayViewController.h"

@interface VAKTodayViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation VAKTodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"dd.MMMM.yyyy";
    
    VAKTask *task1 = [[VAKTask alloc] initTaskWithId:@"19" taskName:@"task1"];
    VAKTask *task2 = [[VAKTask alloc] initTaskWithId:@"11" taskName:@"task2"];
    VAKTask *task3 = [[VAKTask alloc] initTaskWithId:@"33" taskName:@"task3"];
    task1.startedAt = [NSDate date];
    task1.notes = @"My new task!!!";
    self.taskService = [[VAKTaskService alloc] init];
    self.taskService.tasks = [[NSMutableArray alloc] initWithObjects:task1, task2, task3, nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskService.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKTodayCell];
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKTodayCell];
    
    VAKTask *temp = self.taskService.tasks[indexPath.row];
    
    cell.taskNameLabel.text = temp.taskName;
    cell.taskNoteLabel.text = temp.notes;
    cell.taskStartDateLabel.text = [self.formatter stringFromDate:temp.startedAt];
    return cell;
}

@end
