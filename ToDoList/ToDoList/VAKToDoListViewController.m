#import "VAKToDoListViewController.h"
#import "VAKAddProjectViewController.h"
#import "VAKAddProject.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "VAKPriorityCell.h"
#import "Constants.h"
#import "VAKTodayViewController.h"

@interface VAKToDoListViewController () <VAKAddProject>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addProjectButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) VAKTaskService *taskService;

@end

@implementation VAKToDoListViewController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addProjectButton.target = self;
    self.addProjectButton.action = @selector(addProjectButtonPressed:);
    
    self.taskService = [VAKTaskService sharedVAKTaskService];
    [self.taskService sortArrayKeysGroup:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:VAKAddTaskForGroup object:nil];
}

#pragma mark - reload table

- (void)reloadTable {
    [self.tableView reloadData];
}

#pragma mark - action

- (IBAction)addProjectButtonPressed:(id)sender {
    VAKAddProjectViewController *addProjectViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKAddProject];
    addProjectViewController.delegate = self;
    [self.navigationController pushViewController:addProjectViewController animated:YES];
}

- (void)addNewProjectWithName:(NSString *)name {
    [self.taskService addGroup:name];
    [self.taskService sortArrayKeysGroup:NO];
    [self.tableView reloadData];
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    if ([self.editButton.title isEqualToString:VAKEditButton]) {
        self.editButton.title = VAKDoneButton;
        self.tableView.editing = YES;
    }
    else {
        self.editButton.title = VAKEditButton;
        self.tableView.editing = NO;
    }
}

#pragma mark - implemented UITableViewDataSource

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
        NSUInteger countTasks = [self.taskService.dictionaryGroup[VAKInbox] count];
        cell.textLabel.text = VAKInbox;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
    }
    else {
        NSMutableArray *arrayGroupWithoutInbox = [self.taskService.arrayKeysGroup mutableCopy];
        [arrayGroupWithoutInbox removeObject:VAKInbox];
        NSUInteger countTasks = [self.taskService.dictionaryGroup[arrayGroupWithoutInbox[indexPath.row]] count];
        cell.textLabel.text = arrayGroupWithoutInbox[indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)",countTasks];
    }

    return cell;
}

#pragma mark - implemented UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VAKTodayViewController *todayViewController = [self.storyboard instantiateViewControllerWithIdentifier:VAKStoriboardIdentifierTodayViewController];
    if (indexPath.section == 0) {
        NSMutableArray *arrayInbox = self.taskService.dictionaryGroup[VAKInbox];
        todayViewController.arrayOfTasksForSelectedGroup = [arrayInbox copy];
        todayViewController.currentGroup = VAKInbox;
    }
    else {
        NSMutableArray *arrayWithoutInbox = [self.taskService.arrayKeysGroup mutableCopy];
        [arrayWithoutInbox removeObject:VAKInbox];
        todayViewController.arrayOfTasksForSelectedGroup = self.taskService.dictionaryGroup[arrayWithoutInbox[indexPath.row]];
        todayViewController.currentGroup = arrayWithoutInbox[indexPath.row];
    }
    [self.navigationController pushViewController:todayViewController animated:YES];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.section != 0) {
            NSMutableArray *arrayGroupWithoutInbox = [self.taskService.arrayKeysGroup mutableCopy];
            [arrayGroupWithoutInbox removeObject:VAKInbox];
            [self.taskService.dictionaryGroup removeObjectForKey:arrayGroupWithoutInbox[indexPath.row]];
            [self.taskService sortArrayKeysGroup:NO];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
