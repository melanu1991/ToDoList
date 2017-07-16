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
    [self.tableView reloadData];
}

#pragma mark - action

- (IBAction)addProjectButtonPressed:(id)sender {
    VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKAddProject];
    [self.navigationController pushViewController:addProjectViewController animated:YES];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if ([self.editButton.title isEqualToString:NSLocalizedString(VAKEditButton, nil)]) {
        self.editButton.title = NSLocalizedString(VAKDoneButton, nil);
        self.tableView.editing = YES;
    }
    else {
        self.editButton.title = NSLocalizedString(VAKEditButton, nil);
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
        return [[VAKTaskService sharedVAKTaskService].arrayKeysGroup count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKPriorityCellIdentifier bundle:nil] forCellReuseIdentifier:VAKPriorityCellIdentifier];
    
    VAKPriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKPriorityCellIdentifier];
    
    if (indexPath.section == VAKZero) {
        NSUInteger countTasks = [[VAKTaskService sharedVAKTaskService].dictionaryGroup[VAKInbox] count];
        cell.textLabel.text = NSLocalizedString(VAKInbox, nil);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
    }
    else {
        if (indexPath.row == VAKZero) {
            cell.textLabel.text = NSLocalizedString(VAKAddProjectLabel, nil);
            cell.detailTextLabel.text = nil;
        }
        else {
            NSMutableArray *arrayGroupWithoutInbox = [[VAKTaskService sharedVAKTaskService].arrayKeysGroup mutableCopy];
            [arrayGroupWithoutInbox removeObject:VAKInbox];
            NSUInteger countTasks = [[VAKTaskService sharedVAKTaskService].dictionaryGroup[arrayGroupWithoutInbox[indexPath.row-VAKOne]] count];
            cell.textLabel.text = NSLocalizedString(arrayGroupWithoutInbox[indexPath.row-VAKOne], nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
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
        for (VAKTask *task in [VAKTaskService sharedVAKTaskService].dictionaryGroup[VAKInbox]) {
            if (!task.isCompleted) {
                [dictionaryTasksForSelectedGroup[VAKNotCompletedTask] addObject:task];
            }
            else {
                [dictionaryTasksForSelectedGroup[VAKCompletedTask] addObject:task];
            }
        }
        todayViewController.dictionaryTasksForSelectedGroup = dictionaryTasksForSelectedGroup;
        todayViewController.currentGroup = VAKInbox;
        [self.navigationController pushViewController:todayViewController animated:YES];
    }
    else {
        if (indexPath.row == VAKZero) {
            VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKAddProject];
            [self.navigationController pushViewController:addProjectViewController animated:YES];
        }
        else {
            NSMutableArray *arrayWithoutInbox = [[VAKTaskService sharedVAKTaskService].arrayKeysGroup mutableCopy];
            [arrayWithoutInbox removeObject:VAKInbox];
            for (VAKTask *task in [VAKTaskService sharedVAKTaskService].dictionaryGroup[arrayWithoutInbox[indexPath.row-1]]) {
                if (!task.isCompleted) {
                    [dictionaryTasksForSelectedGroup[VAKNotCompletedTask] addObject:task];
                }
                else {
                    [dictionaryTasksForSelectedGroup[VAKCompletedTask] addObject:task];
                }
            }
            todayViewController.dictionaryTasksForSelectedGroup = dictionaryTasksForSelectedGroup;
            todayViewController.currentGroup = arrayWithoutInbox[indexPath.row-1];
            [self.navigationController pushViewController:todayViewController animated:YES];
        }
        
    }
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDelete, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row != VAKZero) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKDeleteTaskTitle, nil) message:NSLocalizedString(VAKWarningDeleteMessage, nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertActionOk= [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSMutableArray *arrayGroupWithoutInbox = [[VAKTaskService sharedVAKTaskService].arrayKeysGroup mutableCopy];
                [arrayGroupWithoutInbox removeObject:VAKInbox];
                NSMutableArray *arrayTasksDeleteGroup = [VAKTaskService sharedVAKTaskService].dictionaryGroup[arrayGroupWithoutInbox[indexPath.row - VAKOne]];
                for (VAKTask *task in arrayTasksDeleteGroup) {
                    [[VAKTaskService sharedVAKTaskService] removeTaskById:task.taskId];
                }
                [[VAKTaskService sharedVAKTaskService].dictionaryGroup removeObjectForKey:arrayGroupWithoutInbox[indexPath.row - VAKOne]];
                [[VAKTaskService sharedVAKTaskService] sortArrayKeysGroup:NO];
                [[VAKTaskService sharedVAKTaskService] sortArrayKeysDate:NO];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                NSDictionary *dic = [NSDictionary dictionaryWithObject:VAKDeleteGroupTask forKey:VAKDeleteGroupTask];
                [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
            }];
            UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:alertActionOk];
            [alertController addAction:alertActionCancel];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKEditButton, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row != VAKZero) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKEditTaskTitle, nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(VAKInputNewNameGroup, nil);
            }];
            UIAlertAction *alertActionOk= [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSMutableArray *arrayGroupWithoutInbox = [[VAKTaskService sharedVAKTaskService].arrayKeysGroup mutableCopy];
                [arrayGroupWithoutInbox removeObject:VAKInbox];
                NSString *selectedGroup = arrayGroupWithoutInbox[indexPath.row - VAKOne];
                NSMutableArray *arraySelectedGroup = [VAKTaskService sharedVAKTaskService].dictionaryGroup[selectedGroup];
                for (VAKTask *task in arraySelectedGroup) {
                    task.currentGroup = alertController.textFields[VAKZero].text;
                }
                [[VAKTaskService sharedVAKTaskService].dictionaryGroup removeObjectForKey:selectedGroup];
                [[VAKTaskService sharedVAKTaskService] addGroup:alertController.textFields[VAKZero].text];
                [VAKTaskService sharedVAKTaskService].dictionaryGroup[alertController.textFields[VAKZero].text] = [arraySelectedGroup mutableCopy];
                NSDictionary *dic = [NSDictionary dictionaryWithObject:VAKWasEditNameGroup forKey:VAKWasEditNameGroup];
                [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }];
            UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleCancel handler:nil];
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
