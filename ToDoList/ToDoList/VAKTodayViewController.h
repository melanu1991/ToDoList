#import <UIKit/UIKit.h>
#import "VAKCustumCell.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "Constants.h"
#import "VAKAddTaskController.h"
#import "VAKNSDate+Formatters.h"
#import "VAKToDoList.h"

@interface VAKTodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) VAKToDoList *currentGroup;
@property (assign, nonatomic, getter=isSelectedGroup) BOOL selectedGroup;

@end
