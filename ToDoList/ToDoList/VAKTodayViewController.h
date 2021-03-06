#import <UIKit/UIKit.h>
#import "VAKCustumCell.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "Constants.h"
#import "VAKAddTaskController.h"
#import "VAKNSDate+Formatters.h"

@interface VAKTodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary *dictionaryTasksForSelectedGroup;
@property (strong, nonatomic) NSString *currentGroup;

@end
