#import <UIKit/UIKit.h>
#import "VAKSelectDateController.h"
#import "VAKRemindCell.h"
#import "VAKDateCell.h"
#import "VAKTaskNameCell.h"
#import "VAKNotesCell.h"
#import "VAKPriorityCell.h"
#import "Constants.h"
#import "VAKNSDate+Formatters.h"
#import "VAKRemindDelegate.h"
#import "ToDoList+CoreDataClass.h"
#import "Task+CoreDataClass.h"
#import "VAKCoreDataManager.h"

@interface VAKAddTaskController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) Task *task;
@property (strong, nonatomic) ToDoList *currentGroup;

@end
