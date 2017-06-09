#import <UIKit/UIKit.h>
#import "VAKCustumCell.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "Constants.h"

@interface VAKTodayViewController : UIViewController <UITableViewDataSource>

@property (strong, nonatomic) VAKTaskService *taskService;

@end
