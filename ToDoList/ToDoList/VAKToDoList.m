#import "VAKToDoList.h"

@implementation VAKToDoList
{
    NSMutableArray *_privateArrayTasks;
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _toDoListName = name;
        _toDoListId = [NSNumber numberWithUnsignedLong:arc4random()%1000];
    }
    return self;
}

- (NSArray *)toDoListArrayTasks {
    if (!_privateArrayTasks) {
        _privateArrayTasks = [NSMutableArray array];
    }
    return _privateArrayTasks;
}

#pragma mark - implemented protocol NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.toDoListId forKey:@"toDoListId"];
    [aCoder encodeObject:self.toDoListName forKey:@"toDoListName"];
    [aCoder encodeObject:self.toDoListArrayTasks forKey:@"toDoListArrayTasks"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _toDoListId = [aDecoder decodeObjectForKey:@"toDoListId"];
        _toDoListName = [aDecoder decodeObjectForKey:@"toDoListName"];
        _privateArrayTasks = [aDecoder decodeObjectForKey:@"toDoListArrayTasks"];
    }
    return self;
}

@end

@implementation VAKToDoList (Additional)

- (void)addTaskByTask:(VAKTask *)task {
    NSMutableArray *arrayCurrentToDoList = (NSMutableArray *)self.toDoListArrayTasks;
    if (![arrayCurrentToDoList containsObject:task]) {
        [arrayCurrentToDoList addObject:task];
    }
}

- (void)removeTaskByTask:(VAKTask *)task {
    NSMutableArray *arrayCurrentToDoList = (NSMutableArray *)self.toDoListArrayTasks;
    if ([arrayCurrentToDoList containsObject:task]) {
        [arrayCurrentToDoList removeObject:task];
    }
}

@end
