#import "VAKRemindCell.h"

@implementation VAKRemindCell

- (IBAction)changedRemind:(id)sender {
    [self.delegate setRemind:self.remindSwitch.isOn];
}

@end
