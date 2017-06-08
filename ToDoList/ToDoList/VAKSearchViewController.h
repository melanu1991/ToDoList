#import <UIKit/UIKit.h>
#import "VAKTaskService.h"
#import "VAKTask.h"

@interface VAKSearchViewController : UIViewController<UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *tasks;

@end
