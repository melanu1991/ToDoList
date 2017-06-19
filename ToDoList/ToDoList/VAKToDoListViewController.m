#import "VAKToDoListViewController.h"
#import "VAKAddProjectViewController.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "VAKPriorityCell.h"
#import "Constants.h"
#import "VAKTodayViewController.h"

@interface VAKToDoListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addProjectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) VAKTaskService *taskService;
@property (assign, nonatomic) BOOL needToReloadData;

@end

@implementation VAKToDoListViewController

#pragma mark - life cycle view controller

- (void)viewWillAppear:(BOOL)animated {
    if (self.needToReloadData) {
        self.needToReloadData = NO;
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addProjectButton.target = self;
    self.addProjectButton.action = @selector(addProjectButtonPressed:);
    
    self.taskService = [VAKTaskService sharedVAKTaskService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewProject:) name:@"VAKAddProject" object:nil];
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    if (notification.userInfo[@"VAKDeleteTask"] || notification.userInfo[@"VAKAddNewTask"]) {
        self.needToReloadData = YES;
    }
}

- (void)addNewProject:(NSNotification *)notification {
    NSString *nameNewProject = notification.userInfo[@"VAKNameNewProject"];
    [self.taskService addGroup:nameNewProject];
    [self.tableView reloadData];
}

#pragma mark - action

- (IBAction)addProjectButtonPressed:(id)sender {
    VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKAddProject];
    [self.navigationController pushViewController:addProjectViewController animated:YES];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if ([self.editButton.title isEqualToString:VAKEditButton]) {
        self.editButton.title = VAKDoneButton;
        self.tableView.editing = YES;
    }
    else {
        self.editButton.title = VAKEditButton;
        self.tableView.editing = NO;
    }
}

#pragma mark - implemented UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else {
        return [self.taskService.arrayKeysGroup count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKPriorityCellIdentifier bundle:nil] forCellReuseIdentifier:VAKPriorityCellIdentifier];
    
    VAKPriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKPriorityCellIdentifier];
    
    if (indexPath.section == 0) {
        NSUInteger countTasks = [self.taskService.dictionaryGroup[VAKInbox] count];
        cell.textLabel.text = VAKInbox;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
    }
    else {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Add project";
            cell.detailTextLabel.text = nil;
        }
        else {
            NSMutableArray *arrayGroupWithoutInbox = [self.taskService.arrayKeysGroup mutableCopy];
            [arrayGroupWithoutInbox removeObject:VAKInbox];
            NSUInteger countTasks = [self.taskService.dictionaryGroup[arrayGroupWithoutInbox[indexPath.row-1]] count];
            cell.textLabel.text = arrayGroupWithoutInbox[indexPath.row-1];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
        }
    }

    return cell;
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKTodayViewController *todayViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKStoriboardIdentifierTodayViewController];
    NSDictionary *dictionaryTasksForSelectedGroup = [NSDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], @"completedTasks", [NSMutableArray array], @"notCompletedTasks", nil];
    if (indexPath.section == 0) {
        for (VAKTask *task in self.taskService.dictionaryGroup[VAKInbox]) {
            if (!task.isCompleted) {
                [dictionaryTasksForSelectedGroup[@"notCompletedTasks"] addObject:task];
            }
            else {
                [dictionaryTasksForSelectedGroup[@"completedTasks"] addObject:task];
            }
        }
        todayViewController.dictionaryTasksForSelectedGroup = dictionaryTasksForSelectedGroup;
        todayViewController.currentGroup = VAKInbox;
        [self.navigationController pushViewController:todayViewController animated:YES];
    }
    else {
        if (indexPath.row == 0) {
            VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKAddProject];
            [self.navigationController pushViewController:addProjectViewController animated:YES];
        }
        else {
            NSMutableArray *arrayWithoutInbox = [self.taskService.arrayKeysGroup mutableCopy];
            [arrayWithoutInbox removeObject:VAKInbox];
            for (VAKTask *task in self.taskService.dictionaryGroup[arrayWithoutInbox[indexPath.row-1]]) {
                if (!task.isCompleted) {
                    [dictionaryTasksForSelectedGroup[@"notCompletedTasks"] addObject:task];
                }
                else {
                    [dictionaryTasksForSelectedGroup[@"completedTasks"] addObject:task];
                }
            }
            todayViewController.dictionaryTasksForSelectedGroup = dictionaryTasksForSelectedGroup;
            todayViewController.currentGroup = arrayWithoutInbox[indexPath.row-1];
            [self.navigationController pushViewController:todayViewController animated:YES];
        }
        
    }
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row != 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VAKDeleteTaskTitle message:VAKWarningDeleteMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertActionOk= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSMutableArray *arrayGroupWithoutInbox = [self.taskService.arrayKeysGroup mutableCopy];
                [arrayGroupWithoutInbox removeObject:VAKInbox];
                [self.taskService.dictionaryGroup removeObjectForKey:arrayGroupWithoutInbox[indexPath.row - 1]];
                [self.taskService sortArrayKeysGroup:NO];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                NSDictionary *dic = [NSDictionary dictionaryWithObject:@"VAKDeleteGroupTasks" forKey:@"VAKDeleteGroupTasks"];
                [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
            }];
            UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:alertActionOk];
            [alertController addAction:alertActionCancel];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row != 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Edit task" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = @"Input new name group";
            }];
            UIAlertAction *alertActionOk= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSMutableArray *arrayGroupWithoutInbox = [self.taskService.arrayKeysGroup mutableCopy];
                [arrayGroupWithoutInbox removeObject:VAKInbox];
                NSString *selectedGroup = arrayGroupWithoutInbox[indexPath.row - 1];
                NSMutableArray *arraySelectedGroup = self.taskService.dictionaryGroup[selectedGroup];
                for (VAKTask *task in arraySelectedGroup) {
                    task.currentGroup = alertController.textFields[0].text;
                }
                [self.taskService.dictionaryGroup removeObjectForKey:selectedGroup];
                [self.taskService addGroup:alertController.textFields[0].text];
                self.taskService.dictionaryGroup[alertController.textFields[0].text] = [arraySelectedGroup mutableCopy];
                NSDictionary *dic = [NSDictionary dictionaryWithObject:@"VAKWasEditNameGroup" forKey:@"VAKWasEditNameGroup"];
                [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:alertActionOk];
            [alertController addAction:alertActionCancel];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    editAction.backgroundColor = [UIColor blueColor];
    return @[deleteAction, editAction];
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
