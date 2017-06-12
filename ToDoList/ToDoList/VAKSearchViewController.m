#import "VAKSearchViewController.h"
#import "Constants.h"
#import "VAKCustumCell.h"

@interface VAKSearchViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *filteredArray;
@property (strong, nonatomic) NSPredicate * criteria;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseActiveOrCompletedTasks;
@property (strong, nonatomic) NSMutableArray *completedTasks;
@property (strong, nonatomic) NSMutableArray *activeTasks;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation VAKSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"EEEE, dd MMMM yyyy г., H:m";
    self.taskService = [VAKTaskService initDefaultTaskService];
    for (VAKTask *task in self.taskService.tasks) {
        if (task.isCompleted) {
            [self.completedTasks addObject:task];
        }
        else {
            [self.activeTasks addObject:task];
        }
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:VAKSwitchingBetweenTabs object:nil];
}

- (NSArray *)completedTasks {
    if (!_completedTasks) {
        _completedTasks = [[NSMutableArray alloc] init];
    }
    return _completedTasks;
}

- (NSArray *)activeTasks {
    if (!_activeTasks) {
        _activeTasks = [[NSMutableArray alloc] init];
    }
    return _activeTasks;
}

//- (void)reloadTable {
//    [self.tableView reloadData];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchBar.text length] > 0 && [self.filteredArray count] > 0) {
        self.tableView.hidden = NO;
        return [self.filteredArray count];
    }
    self.tableView.hidden = YES;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView registerNib:[UINib nibWithNibName:VAKCustumCellNib bundle:nil] forCellReuseIdentifier:VAKTodayCell];
    VAKCustumCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKTodayCell];
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
        self.filteredArray = [self.activeTasks mutableCopy];
    }
    else {
        self.filteredArray = [self.completedTasks mutableCopy];
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

- (IBAction)segmentedControlPressed:(UISegmentedControl *)sender {
    [self searchBar:self.searchBar textDidChange:self.searchBar.text];
    [self.tableView reloadData];
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

@end
