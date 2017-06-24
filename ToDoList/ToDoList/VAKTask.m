#import "VAKTask.h"

@implementation VAKTask

- (instancetype)initTaskWithId:(NSNumber *)taskId taskName:(NSString *)taskName {
    self = [super init];
    if (self) {
        _taskId = taskId;
        _taskName = taskName;
    }
    return self;
}

@end
