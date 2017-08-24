#import "VAKDateCell.h"
#import "VAKSelectDateController.h"
#import "Constants.h"

@implementation VAKDateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = VAKDateFormatWithHourAndMinute;
    self.textLabel.text = [formatter stringFromDate:[NSDate date]];
}

@end
