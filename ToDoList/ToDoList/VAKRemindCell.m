#import "VAKRemindCell.h"

@implementation VAKRemindCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)changedRemind:(id)sender {
    [self.delegate setRemind:self.remindSwitch.isOn];
}

@end
