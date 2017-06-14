#import "VAKTodayViewController.h"
#import "VAKAddTaskController.h"

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
    self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editTaskButtonPressed)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    self.addButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addTaskButtonPressed)];
    self.navigationItem.rightBarButtonItem = self.addButton;
}

- (void)addTaskButtonPressed {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc] init];
    [self.navigationController pushViewController:addTaskController animated:YES];
}

- (void)editTaskButtonPressed {
    if ([self.editButton.title isEqualToString:VAKEditButton]) {
        self.editButton.title = VAKDoneButton;
    }
    else {
        self.editButton.title = VAKEditButton;
    }
    [self.tableView setEditing:!self.tableView.editing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.taskService.groupNotCompletedTasks count];
    }
    return [self.taskService.groupCompletedTasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];
    
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete task" message:@"Are you sure you want remove this item?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (indexPath.section == 0)
        {
            [self.taskService.groupNotCompletedTasks removeObjectAtIndex:indexPath.row];
        }
        else {
            [self.taskService.groupCompletedTasks removeObjectAtIndex:indexPath.row];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    UITableViewRowAction *doneAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Done" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.section == 0) {
            [self.taskService.groupCompletedTasks addObject:self.taskService.groupNotCompletedTasks[indexPath.row]];
            [self.taskService.groupNotCompletedTasks removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }
    }];
    doneAction.backgroundColor = [UIColor blueColor];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction, doneAction];
}

@end
