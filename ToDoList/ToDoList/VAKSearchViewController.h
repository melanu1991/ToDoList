#import <UIKit/UIKit.h>
#import "VAKTaskService.h"
#import "VAKFinishedTaskDelegate.h"
#import "VAKTask.h"

@interface VAKSearchViewController : UIViewController<UITableViewDataSource, UISearchBarDelegate, UITableViewDelegate, VAKFinishedTaskDelegate>

@property (nonatomic, strong) VAKTaskService *taskService;

@end
