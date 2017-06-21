#import "VAKDetailViewController.h"
#import "VAKNSDate+Formatters.h"
#import "Constants.h"

@interface VAKDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;

@end

@implementation VAKDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.taskNameLabel setText:self.task.taskName];
    self.startDateLabel.text = [NSString stringWithFormat:@"%@",self.task.startedAt];
    if (self.task.finishedAt) {
        self.finishDateLabel.text = [NSString stringWithFormat:@"%@",self.task.finishedAt];
    }
    self.notesLabel.text = self.task.notes;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailWasChanged) name:VAKTaskWasChanged object:nil];
}

- (void)detailWasChanged {
    self.taskNameLabel.text = self.task.taskName;
    self.startDateLabel.text =  [NSDate dateStringFromDate:self.task.startedAt format:VAKDateFormat];
    self.finishDateLabel.text = [NSDate dateStringFromDate:self.task.finishedAt format:VAKDateFormat];
    self.notesLabel.text = self.task.notes;
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc]initWithNibName:VAKAddController bundle:nil];
    editTaskController.task = self.task;
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    self.finishDateLabel.text = [NSDate dateStringFromDate:[NSDate date] format:VAKDateFormat];
    [self.delegate finishedTaskById:self.task.taskId finishedDate:[NSDate dateFromString:self.finishDateLabel.text format:VAKDateFormat]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
