#import "VAKSearchViewController.h"
#import "Constants.h"

@interface VAKSearchViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *filteredArray;
@property (strong, nonatomic) NSPredicate * criteria;
@property (strong, nonatomic) UISearchController *searchController;
@property (assign, nonatomic) NSUInteger lastCountCharacters;

@end

@implementation VAKSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSMutableArray *)filteredArray {
    if (!_filteredArray) {
        _filteredArray = [[NSMutableArray alloc] initWithArray:self.tasks];
    }
    return _filteredArray;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKSearchCell];
    VAKTask *temp = nil;
    temp = self.filteredArray[indexPath.row];
    cell.textLabel.text = temp.taskName;
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
        self.filteredArray = [self.tasks mutableCopy];
        self.lastCountCharacters = 0;
        [self.tableView reloadData];
        return;
    }
    //откат на один символ назад!
    if (self.lastCountCharacters > [searchText length]) {
        self.filteredArray = [self.tasks mutableCopy];
        [self.filteredArray filterUsingPredicate:self.criteria];
    }
    //идем вперед!
    else {
        [self.filteredArray filterUsingPredicate:self.criteria];
    }
    
    self.lastCountCharacters = [searchText length];
    [self.tableView reloadData];
}

@end
