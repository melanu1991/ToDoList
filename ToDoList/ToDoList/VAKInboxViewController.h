#import <UIKit/UIKit.h>
#import "VAKAddNewTaskDelegate.h"
#import "VAKFinishedTaskDelegate.h"
#import "VAKAddTaskController.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "Constants.h"
#import "VAKCustumCell.h"

@interface VAKInboxViewController : UIViewController <UITableViewDataSource,VAKAddNewTaskDelegate,VAKFinishedTaskDelegate, UITabBarControllerDelegate, UITableViewDelegate>

@end
