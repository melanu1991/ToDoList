#import "VAKTask.h"

@implementation VAKTask

- (instancetype)initTaskWithId:(NSNumber *)taskId taskName:(NSString *)taskName {
    self = [super init];
    if (self) {
        _taskId = taskId;
        _taskName = taskName;
        _startedAt = [NSDate date];
        _notes = @"";
        _priority = @"None";
    }
    return self;
}

@end
