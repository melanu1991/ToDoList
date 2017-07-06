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
    [self.tableView registerNib:[UINib nibWithNibName:VAKPriorityCellIdentifier bundle:nil] forCellReuseIdentifier:VAKPriorityCellIdentifier];
    
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
    [[VAKTaskService sharedVAKTaskService] addGroup:nameNewProject];
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
    return VAKTwo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == VAKZero) {
        return VAKOne;
    }
    return [[VAKTaskService sharedVAKTaskService].toDoListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKPriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKPriorityCellIdentifier];
    
    if (indexPath.section == VAKZero) {
        for (VAKToDoList *item in [VAKTaskService sharedVAKTaskService].toDoListArray) {
            if ([item.toDoListName isEqualToString:VAKInbox]) {
                NSUInteger countTasks = [item.toDoListArrayTasks count];
                cell.textLabel.text = VAKInbox;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
            }
        }
    }
    else {
        if (indexPath.row == VAKZero) {
            cell.textLabel.text = VAKAddProjectLabel;
            cell.detailTextLabel.text = nil;
        }
        else {
            NSMutableArray *arrayGroups = [NSMutableArray array];
            for (VAKToDoList *item in [VAKTaskService sharedVAKTaskService].toDoListArray) {
                if (![item.toDoListName isEqualToString:VAKInbox]) {
                    [arrayGroups addObject:item];
                }
            }
            VAKToDoList *currentToDoList = arrayGroups[indexPath.row - VAKOne];
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
    if (indexPath.section == VAKZero) {
        for (VAKToDoList *item in [VAKTaskService sharedVAKTaskService].toDoListArray) {
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
        if (indexPath.row == VAKZero) {
            VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKAddProject];
            [self.navigationController pushViewController:addProjectViewController animated:YES];
        }
        else {
            NSMutableArray *arrayToDoList = [NSMutableArray array];
            for (VAKToDoList *item in [VAKTaskService sharedVAKTaskService].toDoListArray) {
                if (![item.toDoListName isEqualToString:VAKInbox]) {
                    [arrayToDoList addObject:item];
                }
            }
            VAKToDoList *currentToDoList = arrayToDoList[indexPath.row - VAKOne];
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
                for (VAKToDoList *item in [VAKTaskService sharedVAKTaskService].toDoListArray) {
                    if (![item.toDoListName isEqualToString:VAKInbox]) {
                        [arrayGroupWithoutInbox addObject:item];
                    }
                }
                VAKToDoList *currentToDoList = arrayGroupWithoutInbox[indexPath.row - 1];
                for (VAKTask *task in currentToDoList.toDoListArrayTasks) {
                    [[VAKTaskService sharedVAKTaskService] removeTaskById:task.taskId];
                }
                
                NSMutableArray *arrayToDoLists = (NSMutableArray *)[VAKTaskService sharedVAKTaskService].toDoListArray;
                [arrayToDoLists removeObject:currentToDoList];
                
                [[VAKTaskService sharedVAKTaskService] sortArrayKeysDate:NO];
                [[VAKTaskService sharedVAKTaskService] sortArrayKeysGroup:NO];
                
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
                for (VAKToDoList *item in [VAKTaskService sharedVAKTaskService].toDoListArray) {
                    if (![item.toDoListName isEqualToString:VAKInbox]) {
                        [arrayGroupWithoutInbox addObject:item];
                    }
                }
                VAKToDoList *currentToDoList = arrayGroupWithoutInbox[indexPath.row - VAKOne];
                currentToDoList.toDoListName = alertController.textFields[VAKZero].text;
                
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
