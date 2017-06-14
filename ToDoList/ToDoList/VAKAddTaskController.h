#import <UIKit/UIKit.h>
#import "VAKSelectDateController.h"
#import "VAKTask.h"
#import "VAKChangedDateDelegate.h"
#import "VAKAddNewTaskDelegate.h"

@interface VAKAddTaskController : UIViewController <VAKChangedDateDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) id<VAKAddNewTaskDelegate> delegate;
@property (nonatomic, strong) VAKTask *task;

@end
