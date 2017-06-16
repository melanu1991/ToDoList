#import <UIKit/UIKit.h>
#import "VAKSelectDateController.h"
#import "VAKTask.h"
#import "VAKChangedDateDelegate.h"
#import "VAKAddNewTaskDelegate.h"
#import "VAKRemindCell.h"
#import "VAKDateCell.h"
#import "VAKTaskNameCell.h"
#import "VAKNotesCell.h"
#import "VAKPriorityCell.h"
#import "Constants.h"

@interface VAKAddTaskController : UIViewController <VAKChangedDateDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) id<VAKAddNewTaskDelegate> delegate;
@property (nonatomic, strong) VAKTask *task;
@property (strong, nonatomic) NSString *currentGroup;

@end
