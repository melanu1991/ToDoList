#import <UIKit/UIKit.h>
#import "VAKDetailDelegate.h"
#import "VAKFinishedTaskDelegate.h"

@interface VAKDetailViewController : UIViewController<VAKDetailDelegate>

@property (nonatomic, weak) id<VAKFinishedTaskDelegate> delegate;

@end
