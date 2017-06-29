#import "VAKDateCell.h"
#import "VAKSelectDateController.h"
#import "Constants.h"
#import "VAKNSDate+Formatters.h"

@implementation VAKDateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textLabel.text = [NSDate dateStringFromDate:[NSDate date] format:VAKDateFormatWithHourAndMinute];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
