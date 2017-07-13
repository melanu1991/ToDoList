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
        _currentGroup = @"Inbox";
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
    [aCoder encodeObject:[NSNumber numberWithBool:self.remindMeOnADay] forKey:@"remindMeOnADay"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.completed] forKey:@"isCompleted"];
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
        _remindMeOnADay = [aDecoder decodeObjectForKey:@"remindMeOnADay"];
        _completed = [aDecoder decodeObjectForKey:@"completed"];
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
    [aCoder encodeObject:[NSNumber numberWithBool:self.remindMeOnADay] forKey:@"remindMeOnADay"];
    [aCoder encodeObject:[NSNumber numberWithBool:self.completed] forKey:@"isCompleted"];
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
        _remindMeOnADay = [aDecoder decodeObjectForKey:@"remindMeOnADay"];
        _completed = [aDecoder decodeObjectForKey:@"completed"];
    }
    return self;
}

@end
