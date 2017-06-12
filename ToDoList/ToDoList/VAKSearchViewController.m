#import "VAKSearchViewController.h"
#import "Constants.h"
#import "VAKCustumCell.h"

@interface VAKSearchViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *filteredArray;
@property (strong, nonatomic) NSPredicate * criteria;
@property (assign, nonatomic) NSUInteger lastCountCharacters;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet UILabel *noResultLabel;

@end

@implementation VAKSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"EEEE, dd MMMM yyyy г., H:m";
    self.taskService = [VAKTaskService initDefaultTaskService];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:VAKSwitchingBetweenTabs object:nil];
    self.tableView.hidden = YES;
}

- (void)reloadTable {
    [self.tableView reloadData];
}

- (NSMutableArray *)filteredArray {
    if (!_filteredArray) {
        _filteredArray = [[NSMutableArray alloc] initWithArray:self.taskService.tasks];
    }
    return _filteredArray;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredArray.count;
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
    
    //если произвели очистку всей строки поиска
    if ([searchText length] == 0) {
        self.filteredArray = [self.taskService.tasks mutableCopy];
        self.lastCountCharacters = 0;
        [self.tableView reloadData];
        return;
    }
    //откат на один символ назад!
    if (self.lastCountCharacters > [searchText length]) {
        self.filteredArray = [self.taskService.tasks mutableCopy];
        [self.filteredArray filterUsingPredicate:self.criteria];
    }
    //идем вперед!
    else {
        [self.filteredArray filterUsingPredicate:self.criteria];
    }
    
    self.lastCountCharacters = [searchText length];
    [self.tableView reloadData];
}

- (IBAction)segmentedControlPressed:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        
    }
    else {
        
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
