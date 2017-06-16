#import "VAKSearchViewController.h"
#import "VAKDetailViewController.h"
#import "Constants.h"
#import "VAKCustumCell.h"

@interface VAKSearchViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *filteredArray;
@property (strong, nonatomic) NSPredicate * criteria;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseActiveOrCompletedTasks;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation VAKSearchViewController

#pragma mark - delegate finished task

- (void)finishedTaskById:(NSString *)taskId finishedDate:(NSDate *)date {
//    for (VAKTask *task in self.taskService.groupNotCompletedTasks) {
//        if ([task.taskId isEqualToString:taskId]) {
//            task.completed = YES;
//            task.finishedAt = date;
//            [self.taskService.groupCompletedTasks addObject:task];
//            [self.taskService.groupNotCompletedTasks removeObject:task];
//            [self searchBar:self.searchBar textDidChange:self.searchBar.text];
//            [self.tableView reloadData];
//            return;
//        }
//    }
}

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = VAKDateFormatWithHourAndMinute;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataInTable) name:VAKTaskWasChanged object:nil];
    
    self.taskService = [VAKTaskService sharedVAKTaskService];
}

#pragma mark - Notification

- (void)reloadDataInTable {
    [self.tableView reloadData];
}

#pragma mark - implemented UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchBar.text length] > 0 && [self.filteredArray count] > 0) {
        self.tableView.hidden = NO;
        return [self.filteredArray count];
    }
    self.tableView.hidden = YES;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKCustumCellIdentifier];
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKCustumCellIdentifier];
    VAKTask *temp = self.filteredArray[indexPath.row];
    
    cell.taskNameLabel.text = temp.taskName;
    cell.taskNoteLabel.text = temp.notes;
    cell.taskStartDateLabel.text = [self.dateFormatter stringFromDate:temp.startedAt];
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

    if ([self.chooseActiveOrCompletedTasks selectedSegmentIndex] == 0) {
        self.filteredArray = [self.taskService.dictionaryCompletedOrNotCompletedTasks[@"notCompletedTasks"] mutableCopy];
    }
    else {
        self.filteredArray = [self.taskService.dictionaryCompletedOrNotCompletedTasks[@"completedTasks"] mutableCopy];
    }

    [self.filteredArray filterUsingPredicate:self.criteria];
    
    if ([self.filteredArray count] > 0) {
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
