#import "VAKSelectDateController.h"
#import "Constants.h"

@interface VAKSelectDateController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;

@end

@implementation VAKSelectDateController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:VAKDoneButton style:UIBarButtonItemStyleDone target:self action:@selector(setSelectDate)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:VAKCancelTitle style:UIBarButtonItemStyleDone target:self action:@selector(cancelSelectDate)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.datePicker.minimumDate = [NSDate date];
    [self.navigationItem setTitle:VAKDateTitle];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"EEEE, dd MMMM yyyy г., H:m";
    self.currentDate.text = [formatter stringFromDate:[NSDate date]];
}

- (void)setSelectDate {
    [self.delegate setNewDateWithDate:[self.datePicker date]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelSelectDate {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
