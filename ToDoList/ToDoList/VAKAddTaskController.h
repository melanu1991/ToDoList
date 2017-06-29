#import <UIKit/UIKit.h>
#import "VAKSelectDateController.h"
#import "VAKTask.h"
#import "VAKRemindCell.h"
#import "VAKDateCell.h"
#import "VAKTaskNameCell.h"
#import "VAKNotesCell.h"
#import "VAKPriorityCell.h"
#import "Constants.h"
#import "VAKNSDate+Formatters.h"
#import "VAKToDoList.h"
#import "VAKRemindDelegate.h"

@interface VAKAddTaskController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) VAKTask *task;
@property (strong, nonatomic) VAKToDoList *currentGroup;

@end
