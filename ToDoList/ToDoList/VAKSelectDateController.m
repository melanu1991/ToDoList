#import "VAKSelectDateController.h"
#import "Constants.h"

@interface VAKSelectDateController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;

@end

@implementation VAKSelectDateController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:VAKDoneButton style:UIBarButtonItemStyleDone target:self action:@selector(setSelectDate)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:VAKCancelButton style:UIBarButtonItemStyleDone target:self action:@selector(cancelSelectDate)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.datePicker.minimumDate = [NSDate date];
    [self.navigationItem setTitle:VAKDateTitle];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = VAKDateFormatWithHourAndMinute;
    self.currentDate.text = [formatter stringFromDate:[NSDate date]];
}

#pragma mark - action

- (void)setSelectDate {
    [self.delegate setNewDateWithDate:[self.datePicker date]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelSelectDate {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
