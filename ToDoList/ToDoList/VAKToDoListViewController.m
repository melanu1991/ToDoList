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
    
    [self.taskService sortArrayKeys];
  
}

- (IBAction)addProjectButtonPressed:(id)sender {
    VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"addProject"];
    addProjectViewController.delegate = self;
    [self.navigationController pushViewController:addProjectViewController animated:YES];
}

- (void)addNewProjectWithName:(NSString *)name {
    [self.taskService addGroup:name];
    [self.taskService sortArrayKeys];
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
    if (section == 0) {
        return 1;
    }
    else {
        return [self.taskService.arrayKeysGroup count] - 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView registerNib:[UINib nibWithNibName:VAKPriorityCellIdentifier bundle:nil] forCellReuseIdentifier:VAKPriorityCellIdentifier];
    
    VAKPriorityCell *cell = [tableView dequeueReusableCellWithIdentifier:VAKPriorityCellIdentifier];
    
    if (indexPath.section == 0) {
        NSUInteger countTasks = [self.taskService.dictionaryGroup[@"Inbox"] count];
        cell.textLabel.text = @"Inbox";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
    }
    else {
        NSMutableArray *arrayGroupWithoutInbox = [self.taskService.arrayKeysGroup mutableCopy];
        [arrayGroupWithoutInbox removeObject:@"Inbox"];
        NSUInteger countTasks = [self.taskService.dictionaryGroup[arrayGroupWithoutInbox[indexPath.row]] count];
        cell.textLabel.text = arrayGroupWithoutInbox[indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

@end
