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
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@end

@implementation VAKToDoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addProjectButton.target = self;
    self.addProjectButton.action = @selector(addProjectButtonPressed:);
    
    self.taskService = [VAKTaskService initDefaultTaskService];
  
}

- (IBAction)addProjectButtonPressed:(id)sender {
    VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addProject"];
    addProjectViewController.delegate = self;
    [self.navigationController pushViewController:addProjectViewController animated:YES];
}

- (void)addNewProjectWithName:(NSString *)name {

    [self.tableView reloadData];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if ([self.editButton.title isEqualToString:@"Edit"]) {
        self.editButton.title = @"Done";
        self.tableView.editing = YES;
    }
    else {
        self.editButton.title = @"Edit";
        self.tableView.editing = NO;
    }
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}

@end
