#import <UIKit/UIKit.h>
#import "VAKAddNewTaskDelegate.h"
#import "VAKFinishedTaskDelegate.h"
#import "VAKAddTaskController.h"
#import "VAKDetailViewController.h"
#import "VAKTaskService.h"
#import "VAKTask.h"
#import "VAKSearchViewController.h"
#import "VAKTodayViewController.h"
#import "VAKToDoListViewController.h"

@interface VAKInboxViewController : UIViewController <UITableViewDataSource,VAKAddNewTaskDelegate,VAKFinishedTaskDelegate, UITabBarControllerDelegate>

@end
