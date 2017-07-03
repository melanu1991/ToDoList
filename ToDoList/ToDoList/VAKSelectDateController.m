#import "VAKSelectDateController.h"
#import "Constants.h"
#import "VAKNSDate+Formatters.h"

@interface VAKSelectDateController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;

@end

@implementation VAKSelectDateController

#pragma mark - life cycle view controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(VAKDoneButton, nil) style:UIBarButtonItemStyleDone target:self action:@selector(setSelectDate)];
    self.navigationItem.rightBarButtonItem = doneButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(VAKCancelButton, nil) style:UIBarButtonItemStyleDone target:self action:@selector(cancelSelectDate)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.datePicker.minimumDate = [NSDate date];
    [self.navigationItem setTitle:NSLocalizedString(VAKDateTitle, nil)];
    self.currentDate.text = [NSDate dateStringFromDate:[NSDate date] format:VAKDateFormatWithHourAndMinute];
}

#pragma mark - action

- (void)setSelectDate {
    NSDictionary *selectedDate = [NSDictionary dictionaryWithObject:[self.datePicker date] forKey:VAKSelectedDate];
    [[NSNotificationCenter defaultCenter] postNotificationName:VAKSelectedDate object:nil userInfo:selectedDate];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelSelectDate {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
