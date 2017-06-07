#import <UIKit/UIKit.h>
#import "VAKSelectDateController.h"
#import "VAKTask.h"
#import "VAKChangedDateDelegate.h"
#import "VAKAddNewTaskDelegate.h"

@interface VAKAddTaskController : UIViewController <VAKChangedDateDelegate>

@property (nonatomic, weak) id<VAKAddNewTaskDelegate> delegate;
@property (nonatomic, retain) VAKTask *task;

@end
