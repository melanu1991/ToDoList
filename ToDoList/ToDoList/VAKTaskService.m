#import "VAKTaskService.h"

@interface VAKTaskService ()

@end

@implementation VAKTaskService

- (NSArray *)tasks {
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc]init];
    }
    return _tasks;
}

- (VAKTask *)taskById:(NSString *)taskId {
    for (int i = 0; i < self.tasks.count; i++) {
        VAKTask *task = self.tasks[i];
        if ([task.taskId isEqualToString:taskId]) {
            return task;
        }
    }
    return nil;
}

- (void)addTask:(VAKTask *)task {
    [self.tasks addObject:task];
}

- (void)removeTaskById:(NSString *)taskId {
    for (int i = 0; i < self.tasks.count; i++) {
        VAKTask *task = (VAKTask *)self.tasks[i];
        if ([task.taskId isEqualToString:taskId]) {
            [self.tasks removeObject:task];
        }
    }
}

- (void)updateTask:(VAKTask *)task {
    //не совсем понял что подразумевается под апдейтом таска
}

@end
