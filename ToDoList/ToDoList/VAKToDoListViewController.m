#import "VAKToDoListViewController.h"
#import "VAKAddProjectViewController.h"
#import "VAKPriorityCell.h"
#import "Constants.h"
#import "VAKTodayViewController.h"
#import "ToDoList+CoreDataClass.h"
#import "Task+CoreDataClass.h"
#import "VAKCoreDataManager.h"

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
    self.needToReloadData = YES;
}

- (void)addNewProject:(NSNotification *)notification {
    ToDoList *toDoList = (ToDoList *)[[VAKCoreDataManager sharedManager] createEntityWithName:@"ToDoList"];
    toDoList.name = notification.userInfo[VAKNameNewProject];
    toDoList.toDoListId = [NSNumber numberWithInteger:arc4random_uniform(1000)];
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
    return VAKTwo;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == VAKZero) {
        return VAKOne;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@", VAKInbox];
    return [[[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:predicate] count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VAKPriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKPriorityCellIdentifier];
    
    if (indexPath.section == VAKZero) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", VAKInbox];
        NSArray *arr = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:predicate];
        ToDoList *inbox = arr[0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", inbox.arrayTasks.count];
        cell.textLabel.text = inbox.name;
    }
    else {
        if (indexPath.row == VAKZero) {
            cell.textLabel.text = VAKAddProjectLabel;
            cell.detailTextLabel.text = nil;
        }
        else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@", VAKInbox];
            NSArray *arr = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:predicate];
            ToDoList *toDoList = arr[indexPath.row - 1];
            cell.textLabel.text = toDoList.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", toDoList.arrayTasks.count];
        }
    }

    return cell;
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKTodayViewController *todayViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKStoriboardIdentifierTodayViewController];

    if (indexPath.section == VAKZero) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", VAKInbox];
        NSArray *arr = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:predicate];
        ToDoList *toDoList = arr[indexPath.row];
        todayViewController.currentGroup = toDoList;
        todayViewController.selectedGroup = YES;
        [self.navigationController pushViewController:todayViewController animated:YES];
    }
    else {
        if (indexPath.row == VAKZero) {
            VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKAddProject];
            [self.navigationController pushViewController:addProjectViewController animated:YES];
        }
        else {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@", VAKInbox];
            NSArray *arr = [[VAKCoreDataManager sharedManager] allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:predicate];
            ToDoList *toDoList = arr[indexPath.row - 1];
            todayViewController.currentGroup = toDoList;
            todayViewController.selectedGroup = YES;
            [self.navigationController pushViewController:todayViewController animated:YES];
        }
    }
    todayViewController.selectedGroup = YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKDelete, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row != 0) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKDeleteTaskTitle, nil) message:NSLocalizedString(VAKWarningDeleteMessage, nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertActionOk= [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:VAKDeleteGroupTask, VAKDeleteGroupTask, indexPath, VAKIndex, nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:VAKTaskWasChangedOrAddOrDelete object:nil userInfo:dic];
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
            }];
            
            UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:alertActionOk];
            [alertController addAction:alertActionCancel];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
        
    }];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(VAKEditButton, nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row != 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(VAKEditTaskTitle, nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = NSLocalizedString(VAKInputNewNameGroup, nil);
            }];
            UIAlertAction *alertActionOk= [UIAlertAction actionWithTitle:NSLocalizedString(VAKOkButton, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:VAKWasEditNameGroup, VAKWasEditNameGroup, alertController.textFields[VAKZero].text, VAKInputNewNameGroup, indexPath.row, VAKIndex, nil];
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
