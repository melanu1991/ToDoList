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

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.taskName forKey:@"taskName"];
    [aCoder encodeObject:self.notes forKey:@"notes"];
    [aCoder encodeObject:self.startedAt forKey:@"startedAt"];
    [aCoder encodeObject:self.finishedAt forKey:@"finishedAt"];
    [aCoder encodeObject:self.priority forKey:@"priority"];
    [aCoder encodeObject:self.taskId forKey:@"taskId"];
    [aCoder encodeObject:self.currentGroup forKey:@"currentGroup"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isRemindMeOnADay] forKey:@"isRemindMeOnADay"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.isCompleted] forKey:@"isCompleted"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _taskName = [aDecoder decodeObjectForKey:@"taskName"];
        _notes = [aDecoder decodeObjectForKey:@"notes"];
        _startedAt = [aDecoder decodeObjectForKey:@"startedAt"];
        _finishedAt = [aDecoder decodeObjectForKey:@"finishedAt"];
        _priority = [aDecoder decodeObjectForKey:@"priority"];
        _taskId = [aDecoder decodeObjectForKey:@"taskId"];
        _currentGroup = [aDecoder decodeObjectForKey:@"currentGroup"];
        _remindMeOnADay = [aDecoder decodeObjectForKey:@"isRemindMeOnADay"];
        _completed = [aDecoder decodeObjectForKey:@"isCompleted"];
    }
    return self;
}

@end
