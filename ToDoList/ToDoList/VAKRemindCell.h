#import <UIKit/UIKit.h>
#import "VAKRemindDelegate.h"

@interface VAKRemindCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;
@property (weak, nonatomic) id<VAKRemindDelegate> delegate;

@end
