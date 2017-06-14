#import <UIKit/UIKit.h>
#import "VAKChangedDateDelegate.h"

@interface VAKSelectDateController : UIViewController

@property (nonatomic, weak) id<VAKChangedDateDelegate> delegate;

@end
