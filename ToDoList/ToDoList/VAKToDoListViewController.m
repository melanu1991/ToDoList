#import "VAKToDoListViewController.h"
#import "VAKAddProjectViewController.h"
#import "VAKAddProject.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "VAKPriorityCell.h"
#import "Constants.h"

@interface VAKToDoListViewController () <VAKAddProject>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addProjectButton;
@property (strong, nonatomic) VAKTaskService *taskService;

@end

@implementation VAKToDoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addProjectButton.target = self;
    self.addProjectButton.action = @selector(addProjectButtonPressed:);
    
    self.taskService = [VAKTaskService initDefaultTaskService];
    
    
//    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(addProjectButtonPressed)];
//    self.navigationItem.rightBarButtonItem = addItem;
    
}

- (IBAction)addProjectButtonPressed:(id)sender {
    VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addProject"];
    addProjectViewController.delegate = self;
    [self.navigationController pushViewController:addProjectViewController animated:YES];
}

- (void)addNewProjectWithName:(NSString *)name {

    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKPriorityCellIdentifier bundle:nil] forCellReuseIdentifier:VAKPriorityCellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKPriorityCellIdentifier];
    cell.textLabel.text = @"myGroup";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",1+indexPath.row];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
