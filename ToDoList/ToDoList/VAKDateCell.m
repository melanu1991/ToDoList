#import "VAKDateCell.h"
#import "VAKSelectDateController.h"

@implementation VAKDateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE, dd MMMM yyyy г., H:m";
    self.textLabel.text = [formatter stringFromDate:[NSDate date]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
