#import "VAKTodayViewController.h"

@interface VAKTodayViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;

@end

@implementation VAKTodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateFormat = @"EEEE, dd MMMM yyyy г., H:m";
    self.taskService = [VAKTaskService initDefaultTaskService];
    self.navigationItem.title = @"Today";
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    self.addButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.addButton;
}

- (void)addButtonPressed {
   
}

- (void)editButtonPressed {
    if ([self.editButton.title isEqualToString:@"Edit"]) {
        self.editButton.title = @"Done";
    }
    else {
        self.editButton.title = @"Edit";
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSLog(@"section %ld",section);
    if (section == 1) {
        NSInteger countCompletedTask = 0;
        for (int i = 0; i < [self.taskService.tasks count]; i++) {
            VAKTask *completedTask = self.taskService.tasks[i];
            if (completedTask.isCompleted) {
                countCompletedTask++;
                [self.taskService.groupCompletedTasks addObject:completedTask];
            }
        }
//        NSLog(@"countCompleted: %ld",countCompletedTask);
        return countCompletedTask;
    }
    else {
        NSInteger countNotCompletedTask = 0;
        for (VAKTask *notCompletedtask in self.taskService.tasks) {
            if (!notCompletedtask.isCompleted) {
                countNotCompletedTask++;
                [self.taskService.groupNotCompletedTasks addObject:notCompletedtask];
            }
        }
//        NSLog(@"countCompleted: %ld",countNotCompletedTask);
        return countNotCompletedTask;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"section %ld and row %ld", indexPath.section, indexPath.row);
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKTodayCell];
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKTodayCell];
    
    if (indexPath.section == 0) {
        VAKTask *notCompletedTask = self.taskService.groupNotCompletedTasks[indexPath.row];
        cell.taskNameLabel.text = notCompletedTask.taskName;
        cell.taskNoteLabel.text = notCompletedTask.notes;
        cell.taskStartDateLabel.text = [self.formatter stringFromDate:notCompletedTask.startedAt];
    }
    else {
        VAKTask *completedTask = self.taskService.groupCompletedTasks[indexPath.row];
        cell.taskNameLabel.text = completedTask.taskName;
        cell.taskNoteLabel.text = completedTask.notes;
        cell.taskStartDateLabel.text = [self.formatter stringFromDate:completedTask.startedAt];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return VAKTitleForHeaderCompleted;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.taskService.tasks removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

@end
