#import "VAKSelectDateController.h"
#import "Constants.h"

@interface VAKSelectDateController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation VAKSelectDateController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:VAKDoneTitle style:UIBarButtonItemStyleDone target:self action:@selector(setSelectDate)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:VAKCancelTitle style:UIBarButtonItemStyleDone target:self action:@selector(cancelSelectDate)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.datePicker.minimumDate = [NSDate date];
    [self.navigationItem setTitle:VAKDateTitle];
}

- (void)setSelectDate {
    [self.delegate setNewDateWithDate:[self.datePicker date]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelSelectDate {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
