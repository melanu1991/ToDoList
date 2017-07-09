#import "VAKSearchViewController.h"
#import "Constants.h"
#import "VAKCustumCell.h"

@interface VAKSearchViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseActiveOrCompletedTasks;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign, nonatomic) BOOL needToReloadData;

@end

@implementation VAKSearchViewController

#pragma mark - life cycle view controller

- (void)viewWillAppear:(BOOL)animated {
    if (self.needToReloadData) {
        [self searchBar:self.searchBar textDidChange:self.searchBar.text];
        self.needToReloadData = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    self.needToReloadData = YES;
}

#pragma mark - helpers

- (Task *)returnSelectedTaskByIndexPath:(NSIndexPath *)indexPath {
    if ([self.chooseActiveOrCompletedTasks selectedSegmentIndex] == VAKZero) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ AND completed == NO", self.searchBar.text];
        NSArray *arrayNotCompletedTask = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
        return arrayNotCompletedTask[indexPath.row];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ AND completed == YES", self.searchBar.text];
    NSArray *arrayCompletedTask = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
    return arrayCompletedTask[indexPath.row];
}

#pragma mark - implemented UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.chooseActiveOrCompletedTasks selectedSegmentIndex] == VAKZero) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ AND completed == NO", self.searchBar.text];
        NSArray *arrayActiveTasks = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
        if (arrayActiveTasks.count > 0) {
            self.tableView.hidden = NO;
            return arrayActiveTasks.count;
        }
        else {
            self.tableView.hidden = YES;
            return VAKZero;
        }
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@ AND completed == YES", self.searchBar.text];
        NSArray *arrayCompletedTasks = [[VAKCoreDataManager sharedManager] allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
        if (arrayCompletedTasks.count > 0) {
            self.tableView.hidden = NO;
            return arrayCompletedTasks.count;
        }
        else {
            self.tableView.hidden = YES;
            return VAKZero;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];
    
    Task *temp = [self returnSelectedTaskByIndexPath:indexPath];
    cell.taskNameLabel.text = temp.name;
    cell.taskNoteLabel.text = temp.notes;
    cell.taskStartDateLabel.text = [NSDate dateStringFromDate:temp.startedAt format:VAKDateFormatWithHourAndMinute];
    
    return cell;
}

#pragma mark - search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableView reloadData];
}

#pragma mark - action

- (IBAction)segmentedControlPressed:(UISegmentedControl *)sender {
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    [self.tableView reloadData];
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc] initWithNibName:VAKAddController bundle:nil];
    
    Task *currentTask = [self returnSelectedTaskByIndexPath:indexPath];
    editTaskController.task = currentTask;
    
    [self.navigationController pushViewController:editTaskController animated:YES];
}

#pragma mark - processing button search UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
