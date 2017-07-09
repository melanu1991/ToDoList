#import <UIKit/UIKit.h>
#import "VAKCustumCell.h"
#import "Constants.h"
#import "VAKAddTaskController.h"
#import "VAKNSDate+Formatters.h"
#import "ToDoList+CoreDataClass.h"
#import "Task+CoreDataClass.h"
#import "VAKCoreDataManager.h"

@interface VAKTodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) ToDoList *currentGroup;
@property (assign, nonatomic, getter=isSelectedGroup) BOOL selectedGroup;

@end
