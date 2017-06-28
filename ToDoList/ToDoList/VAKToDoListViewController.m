#import "VAKToDoListViewController.h"
#import "VAKAddProjectViewController.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "VAKPriorityCell.h"
#import "Constants.h"
#import "VAKTodayViewController.h"
#import "VAKToDoList.h"

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewProject:) name:VAKAddProject object:nil];
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    if (notification.userInfo[VAKDeleteTask] || notification.userInfo[VAKAddNewTask]) {
        self.needToReloadData = YES;
    }
}

- (void)addNewProject:(NSNotification *)notification {
    NSString *nameNewProject = notification.userInfo[VAKNameNewProject];
    [self.taskService addGroup:nameNewProject];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:VAKAddProject forKey:VAKAddProject];
    [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
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
        return [self.taskService.toDoListArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKPriorityCellIdentifier bundle:nil] forCellReuseIdentifier:VAKPriorityCellIdentifier];
    
    VAKPriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKPriorityCellIdentifier];
    
    if (indexPath.section == 0) {
        for (VAKToDoList *item in self.taskService.toDoListArray) {
            if ([item.toDoListName isEqualToString:VAKInbox]) {
                NSUInteger countTasks = [item.toDoListArrayTasks count];
                cell.textLabel.text = VAKInbox;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
            }
        }
    }
    else {
        if (indexPath.row == 0) {
            cell.textLabel.text = VAKAddProjectLabel;
            cell.detailTextLabel.text = nil;
        }
        else {
            NSMutableArray *arrayGroups = [NSMutableArray array];
            for (VAKToDoList *item in self.taskService.toDoListArray) {
                if (![item.toDoListName isEqualToString:VAKInbox]) {
                    [arrayGroups addObject:item];
                }
            }
            VAKToDoList *currentToDoList = arrayGroups[indexPath.row - 1];
            cell.textLabel.text = currentToDoList.toDoListName;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",[currentToDoList.toDoListArrayTasks count]];
        }
    }

    return cell;
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKTodayViewController *todayViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKStoriboardIdentifierTodayViewController];
    NSDictionary *dictionaryTasksForSelectedGroup = [NSDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], VAKCompletedTask, [NSMutableArray array], VAKNotCompletedTask, nil];
    if (indexPath.section == 0) {
        for (VAKToDoList *item in self.taskService.toDoListArray) {
            if ([item.toDoListName isEqualToString:VAKInbox]) {
                for (VAKTask *task in item.toDoListArrayTasks) {
                    if (!task.isCompleted) {
                        [dictionaryTasksForSelectedGroup[VAKNotCompletedTask] addObject:task];
                    }
                    else {
                        [dictionaryTasksForSelectedGroup[VAKCompletedTask] addObject:task];
                    }
                }
                todayViewController.currentGroup = item;
                break;
            }
        }
        [self.navigationController pushViewController:todayViewController animated:YES];
    }
    else {
        if (indexPath.row == 0) {
            VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKAddProject];
            [self.navigationController pushViewController:addProjectViewController animated:YES];
        }
        else {
            NSMutableArray *arrayToDoList = [NSMutableArray array];
            for (VAKToDoList *item in self.taskService.toDoListArray) {
                if (![item.toDoListName isEqualToString:VAKInbox]) {
                    [arrayToDoList addObject:item];
                }
            }
            VAKToDoList *currentToDoList = arrayToDoList[indexPath.row - 1];
            for (VAKTask *task in currentToDoList.toDoListArrayTasks) {
                if (!task.isCompleted) {
                    [dictionaryTasksForSelectedGroup[VAKNotCompletedTask] addObject:task];
                }
                else {
                    [dictionaryTasksForSelectedGroup[VAKCompletedTask] addObject:task];
                }
            }
            todayViewController.currentGroup = currentToDoList;
            [self.navigationController pushViewController:todayViewController animated:YES];
        }
    }
    todayViewController.selectedGroup = YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:VAKDelete handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row != 0) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VAKDeleteTaskTitle message:VAKWarningDeleteMessage preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertActionOk= [UIAlertAction actionWithTitle:VAKOkButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSMutableArray *arrayGroupWithoutInbox = [NSMutableArray array];
                for (VAKToDoList *item in self.taskService.toDoListArray) {
                    if (![item.toDoListName isEqualToString:VAKInbox]) {
                        [arrayGroupWithoutInbox addObject:item];
                    }
                }
                VAKToDoList *currentToDoList = arrayGroupWithoutInbox[indexPath.row - 1];
                for (VAKTask *task in currentToDoList.toDoListArrayTasks) {
                    [self.taskService removeTaskById:task.taskId];
                }
                
                NSMutableArray *arrayToDoLists = (NSMutableArray *)self.taskService.toDoListArray;
                [arrayToDoLists removeObject:currentToDoList];
                
                [self.taskService sortArrayKeysDate:NO];
                [self.taskService sortArrayKeysGroup:NO];
                
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObject:VAKDeleteGroupTask forKey:VAKDeleteGroupTask];
                [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
            
            }];
            
            UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:VAKCancelButton style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:alertActionOk];
            [alertController addAction:alertActionCancel];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
    }];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:VAKEditButton handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row != 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:VAKEditTaskTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = VAKInputNewNameGroup;
            }];
            UIAlertAction *alertActionOk= [UIAlertAction actionWithTitle:VAKOkButton style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSMutableArray *arrayGroupWithoutInbox = [NSMutableArray array];
                for (VAKToDoList *item in self.taskService.toDoListArray) {
                    if (![item.toDoListName isEqualToString:VAKInbox]) {
                        [arrayGroupWithoutInbox addObject:item];
                    }
                }
                VAKToDoList *currentToDoList = arrayGroupWithoutInbox[indexPath.row - 1];
                currentToDoList.toDoListName = alertController.textFields[0].text;
                
                NSDictionary *dic = [NSDictionary dictionaryWithObject:VAKWasEditNameGroup forKey:VAKWasEditNameGroup];
                [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:VAKCancelButton style:UIAlertActionStyleCancel handler:nil];
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
