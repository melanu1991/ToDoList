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

- (void)updateTaskByTask:(VAKTask *)task {
    
}

@end
