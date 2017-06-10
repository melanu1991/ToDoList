#import <Foundation/Foundation.h>
#import "VAKTask.h"

@interface VAKTaskService : NSObject

@property (strong, nonatomic) NSMutableArray *tasks;
@property (strong, nonatomic) NSMutableArray *groupCompletedTasks;
@property (strong, nonatomic) NSMutableArray *groupNotCompletedTasks;

- (VAKTask *)taskById:(NSString *)taskId;
- (void)addTask:(VAKTask *)task;
- (void)removeTaskById:(NSString *)taskId;
- (void)updateTask:(VAKTask *)task;

+ (instancetype)initDefaultTaskService;

@end
