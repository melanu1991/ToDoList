//#import "VAKTask.h"
//
//@implementation VAKTask
//
//- (instancetype)initTaskWithId:(NSNumber *)taskId taskName:(NSString *)taskName {
//    self = [super init];
//    if (self) {
//        _taskId = taskId;
//        _taskName = taskName;
//        _startedAt = [NSDate date];
//        _notes = @"";
//        _priority = @"None";
//        _remindMeOnADay = NO;
//        _completed = NO;
//    }
//    return self;
//}
//
//#pragma mark - implemented protocol NSCoding
//
//- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:self.taskId forKey:@"taskId"];
//    [aCoder encodeObject:self.taskName forKey:@"taskName"];
//    [aCoder encodeObject:self.startedAt forKey:@"startedAt"];
//    [aCoder encodeObject:self.finishedAt forKey:@"finishedAt"];
//    [aCoder encodeObject:self.priority forKey:@"priority"];
//    [aCoder encodeObject:self.notes forKey:@"notes"];
//    [aCoder encodeObject:[NSNumber numberWithBool:self.completed] forKey:@"completed"];
//    [aCoder encodeObject:[NSNumber numberWithBool:self.remindMeOnADay] forKey:@"remindMeOnADay"];
//    [aCoder encodeObject:self.currentToDoList forKey:@"currentToDoList"];
//}
//
//- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super init];
//    if (self) {
//        _taskId = [aDecoder decodeObjectForKey:@"taskId"];
//        _taskName = [aDecoder decodeObjectForKey:@"taskName"];
//        _startedAt = [aDecoder decodeObjectForKey:@"startedAt"];
//        _finishedAt = [aDecoder decodeObjectForKey:@"finishedAt"];
//        _priority = [aDecoder decodeObjectForKey:@"priority"];
//        _notes = [aDecoder decodeObjectForKey:@"notes"];
//        _completed = [[aDecoder decodeObjectForKey:@"completed"] boolValue];
//        _remindMeOnADay = [[aDecoder decodeObjectForKey:@"remindMeOnADay"] boolValue];
//        _currentToDoList = [aDecoder decodeObjectForKey:@"currentToDoList"];
//    }
//    return self;
//}
//
//@end
