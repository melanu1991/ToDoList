#import "VAKToDoListViewController.h"
#import "VAKAddProjectViewController.h"
#import "VAKAddProject.h"

@interface VAKToDoListViewController () <VAKAddProject>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addProjectButton;

@end

@implementation VAKToDoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addProjectButton.target = self;
    self.addProjectButton.action = @selector(addProjectButtonPressed:);
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
    static NSString *identifier = @"myCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.textLabel.text = @"my cell";
    
    
    return cell;
}

@end
