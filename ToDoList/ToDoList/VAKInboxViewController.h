#import <UIKit/UIKit.h>
#import "VAKAddNewTaskDelegate.h"
#import "VAKDetailDelegate.h"
#import "VAKFinishedTaskDelegate.h"

@interface VAKInboxViewController : UIViewController <UITableViewDataSource,VAKAddNewTaskDelegate,VAKFinishedTaskDelegate>
@property (nonatomic, weak) id<VAKDetailDelegate> delegate;
@end
