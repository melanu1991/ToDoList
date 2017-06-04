#import "VAKAddTaskController.h"
#import "VAKSelectDateController.h"

@interface VAKAddTaskController ()
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@end

@implementation VAKAddTaskController

- (void)setNewDateWithDate:(NSDate *)date {
    [self.dateButton setTitle:@"AAA" forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"HH:mm dd.MMMM.yyyy";
    NSString *today = [formatter stringFromDate:[NSDate date]];
    [self.dateButton setTitle:today forState:UIControlStateNormal];
}

- (IBAction)selectDateButton:(UIButton *)sender {
    VAKSelectDateController *selectDate = [[VAKSelectDateController alloc]initWithNibName:@"VAKSelectDateController" bundle:nil];
    selectDate.delegate = self;
    [self showViewController:selectDate sender:nil];
}

@end
