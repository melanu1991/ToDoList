#import "VAKTask.h"

@implementation VAKTask

- (instancetype)initTaskWithId:(NSString *)taskId taskName:(NSString *)taskName {
    self = [super init];
    if (self) {
        _taskId = taskId;
        _taskName = taskName;
        _priority = @"None";
        _startedAt = [NSDate date];
        _notes = @"";
    }
    return self;
}

@end
