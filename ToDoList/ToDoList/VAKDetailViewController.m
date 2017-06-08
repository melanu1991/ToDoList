#import "VAKDetailViewController.h"
#import "Constants.h"

@interface VAKDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *taskName;
@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *finishDate;
@property (weak, nonatomic) IBOutlet UILabel *notes;

@end

@implementation VAKDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.taskName setText:self.task.taskName];
    self.startDate.text = [NSString stringWithFormat:@"%@",self.task.startedAt];
    if (self.task.finishedAt) {
        self.finishDate.text = [NSString stringWithFormat:@"%@",self.task.finishedAt];
    }
    self.notes.text = self.task.notes;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detailWasChanged) name:VAKTaskWasChanged object:nil];
}

- (void)detailWasChanged {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    self.taskName.text = self.task.taskName;
    self.startDate.text =  [formatter stringFromDate:self.task.startedAt];
    self.finishDate.text = [formatter stringFromDate:self.task.finishedAt];
    self.notes.text = self.task.notes;
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    VAKAddTaskController *editTaskController = [[VAKAddTaskController alloc]initWithNibName:VAKAddController bundle:nil];
    editTaskController.task = self.task;
    [self.navigationController pushViewController:editTaskController animated:YES];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    self.finishDate.text = [formatter stringFromDate:[NSDate date]];
    [self.delegate finishedTaskById:self.task.taskId finishedDate:[formatter dateFromString:self.finishDate.text]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
