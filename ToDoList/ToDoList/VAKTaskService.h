#import <Foundation/Foundation.h>

@class VAKTask;
@interface VAKTaskService : NSObject

@property (nonatomic, strong) NSMutableArray *tasks;

- (VAKTask *)taskById:(NSString *)taskId;
- (void)addTask:(VAKTask *)task;
- (void)removeTaskById:(NSString *)taskId;
- (void)updateTask:(VAKTask *)task;

@end
