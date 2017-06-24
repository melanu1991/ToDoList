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

- (void)addTaskById:(NSNumber *)toDoListId task:(VAKTask *)task {
    for (VAKToDoList *item in self.taskService.toDoListArray) {
        if ([item.toDoListId isEqualToNumber:toDoListId]) {
            NSMutableArray *arrayTasksCurrentToDoList = (NSMutableArray *)item.toDoListArrayTasks;
            [arrayTasksCurrentToDoList addObject:task];
            return;
        }
    }
}

- (void)removeTaskById:(NSNumber *)toDoListId task:(VAKTask *)task {
    for (VAKToDoList *item in self.taskService.toDoListArray) {
        if ([item.toDoListId isEqualToNumber:toDoListId]) {
            NSMutableArray *arrayTasksCurrentToDoList = (NSMutableArray *)item.toDoListArrayTasks;
            [arrayTasksCurrentToDoList removeObject:task];
            return;
        }
    }
}

- (void)updateTaskById:(NSNumber *)toDoListId task:(VAKTask *)task {
    for (VAKToDoList *item in self.taskService.toDoListArray) {
        if ([item.toDoListId isEqualToNumber:toDoListId]) {
            NSMutableArray *arrayTasksCurrentToDoList = (NSMutableArray *)item.toDoListArrayTasks;
            for (VAKTask *currentTask in arrayTasksCurrentToDoList) {
                if ([currentTask.taskId isEqualToString:task.taskId]) {
                    currentTask.taskId = task.taskId;
                    currentTask.taskName = task.taskName;
                    currentTask.notes = task.notes;
                    currentTask.startedAt = task.startedAt;
                    currentTask.finishedAt = task.finishedAt;
                    currentTask.completed = task.completed;
                    currentTask.remindMeOnADay = task.remindMeOnADay;
                    currentTask.priority = task.priority;
                    break;
                }
            }
            return;
        }
    }
}

- (void)addNewProjectWithName:(NSString *)name {
    for (VAKToDoList *item in self.taskService.toDoListArray) {
        if ([item.toDoListName isEqualToString:name]) {
            return;
        }
    }
    VAKToDoList *newToDoList = [[VAKToDoList alloc] initWithName:name];
    NSMutableArray *arrayToDoLists = (NSMutableArray *)self.taskService.toDoListArray;
    [arrayToDoLists addObject:newToDoList];
}

- (void)removeProjectWithName:(NSString *)name {
    NSMutableArray *arrayToDoLists = (NSMutableArray *)self.taskService.toDoListArray;
    for (VAKToDoList *item in arrayToDoLists) {
        if ([item.toDoListName isEqualToString:name] && ![name isEqualToString:VAKInbox]) {
            item.toDoListName = nil;
            item.toDoListId = nil;
            item.toDoListArrayTasks = nil;
            [arrayToDoLists removeObject:item];
            return;
        }
    }
    
}

@end
