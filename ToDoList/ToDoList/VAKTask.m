#import "VAKTask.h"

@implementation VAKTask

- (instancetype)initTaskWithId:(NSString *)taskId taskName:(NSString *)taskName {
    self = [super init];
    if (self) {
        _taskId = taskId;
        _taskName = taskName;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@",self.taskName, self.taskId];
}

@end
