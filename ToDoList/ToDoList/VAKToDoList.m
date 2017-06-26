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

- (void)addTaskByToDoList:(VAKToDoList *)toDoList task:(VAKTask *)task {
    NSMutableArray *arrayCurrentToDoList = (NSMutableArray *)toDoList.toDoListArrayTasks;
    if (![arrayCurrentToDoList containsObject:task]) {
        [arrayCurrentToDoList addObject:task];
    }
}

- (void)removeTaskByToDoList:(VAKToDoList *)toDoList task:(VAKTask *)task {
    NSMutableArray *arrayCurrentToDoList = (NSMutableArray *)toDoList.toDoListArrayTasks;
    if ([arrayCurrentToDoList containsObject:task]) {
        [arrayCurrentToDoList removeObject:task];
    }
}

- (void)updateTaskByToDoList:(VAKToDoList *)toDoList task:(VAKTask *)task {
    
}

- (void)addNewProjectWithName:(NSString *)name {
    
}

- (void)removeProject {
    
}

@end
