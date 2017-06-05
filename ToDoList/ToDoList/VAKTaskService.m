#import "VAKTaskService.h"

@interface VAKTaskService ()

@end

@implementation VAKTaskService

- (NSArray *)tasks {
    if (!_tasks) {
        _tasks = [[NSArray alloc]init];
    }
    return _tasks;
}

- (VAKTask *)taskById:(NSString *)taskId {
    return nil;
}
- (void)addTask:(VAKTask *)task {
    self.tasks = [self.tasks arrayByAddingObject:task];
    for (VAKTask *temp in self.tasks) {
        NSLog(@"task: %@",temp);
    }
}
- (void)removeTaskById:(NSString *)taskId {
    
}
- (void)updateTask:(VAKTask *)task {
    
}

@end
