#import "VAKDetailViewController.h"
#import "VAKAddTaskController.h"
#import "VAKTask.h"

@interface VAKDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *taskName;
@property (weak, nonatomic) IBOutlet UILabel *startDate;
@property (weak, nonatomic) IBOutlet UILabel *finishDate;
@property (weak, nonatomic) IBOutlet UILabel *notes;
@property (nonatomic, strong) VAKTask *task;
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
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    VAKAddTaskController *addTaskController = [[VAKAddTaskController alloc]initWithNibName:@"VAKAddTaskController" bundle:nil];
    [self.navigationController pushViewController:addTaskController animated:YES];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    self.finishDate.text = [formatter stringFromDate:[NSDate date]];
    [self.delegate finishedTaskById:self.task.taskId finishedDate:[formatter dateFromString:self.finishDate.text]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)detailTaskWithTask:(VAKTask *)task {
    self.task = task;
}




@end
