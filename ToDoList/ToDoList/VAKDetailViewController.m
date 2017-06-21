#import "VAKDetailViewController.h"
#import "VAKDateFormatterHelper.h"
#import "Constants.h"

@interface VAKDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (strong, nonatomic) VAKDateFormatterHelper *dateFormatter;

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
    NSDateFormatter *formatter = [VAKDateFormatterHelper sharedDateFormatter];
    formatter.dateFormat = VAKDateFormat;
    self.taskNameLabel.text = self.task.taskName;
    self.startDateLabel.text =  [formatter stringFromDate:self.task.startedAt];
    self.finishDateLabel.text = [formatter stringFromDate:self.task.finishedAt];
    self.notesLabel.text = self.task.notes;
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc]initWithNibName:VAKAddController bundle:nil];
    editTaskController.task = self.task;
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    NSDateFormatter *formatter = [VAKDateFormatterHelper sharedDateFormatter];
    formatter.dateFormat = VAKDateFormat;
    self.finishDateLabel.text = [formatter stringFromDate:[NSDate date]];
    [self.delegate finishedTaskById:self.task.taskId finishedDate:[formatter dateFromString:self.finishDateLabel.text]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
