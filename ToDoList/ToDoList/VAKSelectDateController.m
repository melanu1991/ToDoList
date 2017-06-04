#import "VAKSelectDateController.h"

@interface VAKSelectDateController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation VAKSelectDateController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(setSelectDate)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.datePicker.minimumDate = [NSDate date];
    
}

- (void)setSelectDate {
    [self.delegate setNewDateWithDate:[self.datePicker date]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
