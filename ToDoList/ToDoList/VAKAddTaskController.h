#import <UIKit/UIKit.h>
#import "VAKChangedDateDelegate.h"
#import "VAKAddNewTaskDelegate.h"

@interface VAKAddTaskController : UIViewController <VAKChangedDateDelegate>
@property (nonatomic, weak) id<VAKAddNewTaskDelegate> delegate;
@end
