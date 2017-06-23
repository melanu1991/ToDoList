#import <UIKit/UIKit.h>
#import "VAKAddTaskController.h"
#import "VAKTask.h"
#import "VAKFinishedTaskDelegate.h"

@interface VAKDetailViewController : UIViewController

@property (nonatomic, weak) id<VAKFinishedTaskDelegate> delegate;
@property (nonatomic, strong) VAKTask *task;

@end
