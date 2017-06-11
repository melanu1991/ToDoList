#import "VAKAddTaskController.h"
#import "VAKRemindCell.h"
#import "VAKDateCell.h"
#import "VAKTaskNameCell.h"
#import "VAKNotesCell.h"
#import "VAKPriorityCell.h"
#import "Constants.h"

@interface VAKAddTaskController ()

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSDate *selectDate;
@property (strong, nonatomic) NSString *selectPriority;

@end

@implementation VAKAddTaskController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return 2;
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSString *identifier = nil;
    
    if (indexPath.section == 0) {
        identifier = VAKTaskNameCellIdentifier;
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            identifier = VAKRemindCellIdentifier;
        }
        else {
            identifier = VAKDateCellIdentifier;
            if (self.selectDate) {
                [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
                cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                cell.textLabel.text = [self.formatter stringFromDate:self.selectDate];
                return cell;
            }
        }
    }
    else if (indexPath.section == 2) {
        identifier = VAKPriorityCellIdentifier;
        if (self.selectPriority) {
            [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            cell.detailTextLabel.text = self.selectPriority;
            return cell;
        }
    }
    else {
        identifier = VAKNotesCellIdentifier;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 3) {
        return 200.f;
    }
    return 44.f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return VAKTaskTitle;
    }
    else if (section == 1) {
        return VAKRemindTitle;
    }
    else if (section == 2) {
        return VAKPriorityTitle;
    }
    else {
        return VAKNotesTitle;
    }
}

- (void)setNewDateWithDate:(NSDate *)date {
    self.selectDate = date;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc]init];
    self.formatter.dateFormat = @"EEEE, dd MMMM yyyy г., H:m";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:VAKDoneTitle style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:VAKCancelTitle style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonPressed)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    NSString *title = nil;
    if (!self.task) {
        title = VAKAddTaskTitle;
    }
    else {
        title = VAKEditTaskTitle;
    }

    [self.navigationItem setTitle:title];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1) {
        VAKSelectDateController *selectDateController = [[VAKSelectDateController alloc] init];
        selectDateController.delegate = self;
        [self.navigationController pushViewController:selectDateController animated:YES];
    }
    else if (indexPath.section == 2) {
        UIAlertController *priorityAlertController = [UIAlertController alertControllerWithTitle:@"Select Priority" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noneAction = [UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = @"None";
            [self.tableView reloadData];
        }];
        UIAlertAction *lowAction = [UIAlertAction actionWithTitle:@"Low" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = @"Low";
            [self.tableView reloadData];
        }];
        UIAlertAction *mediumAction = [UIAlertAction actionWithTitle:@"Medium" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = @"Medium";
            [self.tableView reloadData];
        }];
        UIAlertAction *highAction = [UIAlertAction actionWithTitle:@"High" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.selectPriority = @"High";
            [self.tableView reloadData];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            return;
        }];
        [priorityAlertController addAction:noneAction];
        [priorityAlertController addAction:lowAction];
        [priorityAlertController addAction:mediumAction];
        [priorityAlertController addAction:highAction];
        [priorityAlertController addAction:cancelAction];
        [self presentViewController:priorityAlertController animated:YES completion:nil];
    }
}

- (void)cancelButtonPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)doneButtonPressed {
//    if (!self.task) {
//        NSString *taskId = [NSString stringWithFormat:@"%u",arc4random()%1000];
//        VAKTask *newTask = [[VAKTask alloc]initTaskWithId:taskId taskName:self.taskNameField.text];
//
//        [self.delegate addNewTaskWithTask:newTask];
//    }
//    else {
//        self.task.taskName = self.taskNameField.text;
//        self.task.notes = self.taskNotesTextView.text;
//        [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChanged object:nil];
//    }
//    [self.navigationController popViewControllerAnimated:YES];
//}

@end
