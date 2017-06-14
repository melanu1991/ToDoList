#import <UIKit/UIKit.h>
#import "VAKTaskService.h"
#import "VAKTask.h"

@interface VAKSearchViewController : UIViewController<UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate>

@property (nonatomic, strong) VAKTaskService *taskService;

@end
