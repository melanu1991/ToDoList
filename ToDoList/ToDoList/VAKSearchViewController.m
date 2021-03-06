#import "VAKSearchViewController.h"
#import "Constants.h"
#import "VAKCustumCell.h"

@interface VAKSearchViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *filteredArray;
@property (strong, nonatomic) NSPredicate * criteria;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    VAKTask *currentTask = notification.userInfo[VAKCurrentTask];
    
    if (notification.userInfo[VAKDoneTask] && [self.chooseActiveOrCompletedTasks selectedSegmentIndex] == VAKZero) {
        self.needToReloadData = YES;
    }
    else if (notification.userInfo[VAKDoneTask] && [self.chooseActiveOrCompletedTasks selectedSegmentIndex] == VAKOne) {
        self.needToReloadData = YES;
    }
    
    if ( (currentTask.isCompleted && [self.chooseActiveOrCompletedTasks selectedSegmentIndex] == VAKOne) || (!currentTask.isCompleted && [self.chooseActiveOrCompletedTasks selectedSegmentIndex] == VAKZero) ) {
        if (notification.userInfo[VAKDetailTaskWasChanged]) {
            NSString *newDate = notification.userInfo[VAKNewDate];
            NSString *newTaskName = notification.userInfo[VAKNewTaskName];
            NSString *newNotes = notification.userInfo[VAKNewNotes];
            if (![newDate isEqualToString:[NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithHourAndMinute]] || ![newNotes isEqualToString:currentTask.notes] || ![newTaskName isEqualToString:currentTask.taskName]) {
                self.needToReloadData = YES;
            }
        }
        else if (notification.userInfo[VAKAddNewTask] || notification.userInfo[VAKDeleteTask] || notification.userInfo[VAKWasEditNameGroup] || notification.userInfo[VAKDeleteGroupTask]) {
            self.needToReloadData = YES;
        }
    }
}

#pragma mark - implemented UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchBar.text length] > VAKZero && [self.filteredArray count] > VAKZero) {
        self.tableView.hidden = NO;
        return [self.filteredArray count];
    }
    self.tableView.hidden = YES;
    return VAKZero;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];
    VAKTask *temp = self.filteredArray[indexPath.row];
    cell.taskNameLabel.text = temp.taskName;
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
    
    self.criteria = [NSPredicate predicateWithFormat:@"taskName contains[cd] %@", searchText];

    if ([self.chooseActiveOrCompletedTasks selectedSegmentIndex] == VAKZero) {
        self.filteredArray = [[VAKTaskService sharedVAKTaskService].dictionaryCompletedOrNotCompletedTasks[VAKNotCompletedTask] mutableCopy];
    }
    else {
        self.filteredArray = [[VAKTaskService sharedVAKTaskService].dictionaryCompletedOrNotCompletedTasks[VAKCompletedTask] mutableCopy];
    }

    [self.filteredArray filterUsingPredicate:self.criteria];
    
    if ([self.filteredArray count] > VAKZero) {
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }
    else {
        self.tableView.hidden = YES;
    }
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
    
    VAKTask *currentTask = self.filteredArray[indexPath.row];
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
