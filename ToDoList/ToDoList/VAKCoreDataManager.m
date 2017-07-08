#import "VAKCoreDataManager.h"

@interface VAKCoreDataManager ()

@end

@implementation VAKCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton Manager

+ (VAKCoreDataManager *)sharedManager {
    static VAKCoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VAKCoreDataManager alloc] init];
        NSArray *arrayToDoList = [manager allEntityWithName:@"ToDoList" sortDescriptor:nil];
        if (arrayToDoList.count == 0) {
            ToDoList *inbox = (ToDoList *)[manager createEntityWithName:@"ToDoList"];
            inbox.name = VAKInbox;
            [inbox.managedObjectContext save:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(remindMeOnADay:) name:VAKRemindTask object:nil];
    });
    return manager;
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
//    VAKTask *currentTask = notification.userInfo[VAKCurrentTask];
//    if (notification.userInfo[VAKDetailTaskWasChanged]) {
//        NSString *newDate = notification.userInfo[VAKNewDate];
//        NSString *lastDate = [NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
//        if (![lastDate isEqualToString:newDate] || ![currentTask.notes isEqualToString:notification.userInfo[VAKNewNotes]] || ![currentTask.priority isEqualToString:notification.userInfo[VAKNewPriority]] || ![currentTask.taskName isEqualToString:notification.userInfo[VAKNewTaskName]]) {
//            [self updateTask:currentTask lastDate:lastDate newDate:newDate];
//            currentTask.taskName = notification.userInfo[VAKNewTaskName];
//            currentTask.notes = notification.userInfo[VAKNewNotes];
//            currentTask.priority = notification.userInfo[VAKNewPriority];
//            [[VAKCoreDataManager sharedManager] updateTaskByTask:currentTask];
//        }
//        //        [self saveData];
//    }
//    else if (notification.userInfo[VAKAddNewTask]) {
//        VAKTask *newTask = notification.userInfo[VAKCurrentTask];
//        if (![self.tasks containsObject:currentTask]) {
//            [self addTask:newTask];
//            [[VAKCoreDataManager sharedManager] addTaskWithTask:currentTask];
//            //            [self saveData];
//        }
//    }
//    else if (notification.userInfo[VAKDoneTask]) {
//        [self updateTaskForCompleted:currentTask];
//        //        [self saveData];
//    }
//    else if (notification.userInfo[VAKDeleteTask]) {
//        if ([self.tasks containsObject:currentTask]) {
//            [self removeTaskById:currentTask.taskId];
//            [[VAKCoreDataManager sharedManager] deleteTaskByTask:currentTask];
//            //            [self saveData];
//        }
//    }
//    else if (notification.userInfo[VAKWasEditNameGroup]) {
//        [self editNameGroupWithName:notification.userInfo[VAKInputNewNameGroup] index:notification.userInfo[VAKIndex]];
//        //        [self saveData];
//    }
//    else if (notification.userInfo[VAKDeleteGroupTask]) {
//        [self deleteGroupWithIndex:notification.userInfo[VAKIndex]];
//    }
}

#pragma mark - remind task

- (void)remindMeOnADay:(NSNotification *)notification {
    if (notification.userInfo[@"remind"]) {
        [self remind:notification.userInfo[@"task"]];
    }
    else if (notification.userInfo[@"delete"]) {
        [self deleteRemind:notification.userInfo[@"task"]];
    }
    else {
        [self updateDateRemind:notification.userInfo[@"task"]];
    }
}

- (void)remind:(Task *)task {
    NSString *eventInfo = [NSString stringWithFormat:@"Name: %@ and notes: %@", task.name, task.notes];
    NSString *eventDate = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithHourAndMinute];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:eventInfo, @"eventInfo", eventDate, @"eventDate", task.taskId, @"taskId", nil];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.userInfo = dic;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.fireDate = task.startedAt;
    notification.alertBody = eventInfo;
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)deleteRemind:(Task *)task {
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([notification.userInfo[@"taskId"] isEqualToNumber:task.taskId]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)updateDateRemind:(Task *)task {
    [self deleteRemind:task];
    [self remind:task];
}

#pragma mark - work with entities

- (NSInteger)countOfEntityWithName:(NSString *)name {
    NSArray *array = [self allEntityWithName:name sortDescriptor:nil];
    return [array count];
}

- (NSArray *)allEntityWithName:(NSString *)name sortDescriptor:(NSSortDescriptor *)sortDescriptor {
    NSFetchRequest *fetchRequests = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    [fetchRequests setEntity:entityDescription];
    if (sortDescriptor != nil) {
        [fetchRequests setSortDescriptors:@[sortDescriptor]];
    }
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequests error:nil];
    return array;
}

- (void)deleteAllObjects {
    NSArray *arrayToDoLists = [self allEntityWithName:@"ToDoList" sortDescriptor:nil];
    for (ToDoList *item in arrayToDoLists) {
        [self.managedObjectContext deleteObject:item];
    }
    NSArray *arrayDate = [self allEntityWithName:@"Date" sortDescriptor:nil];
    for (Date *date in arrayDate) {
        [self.managedObjectContext deleteObject:date];
    }
}

- (void)deleteTaskByTask:(Task *)task {
    NSArray *toDoLists = [self allEntityWithName:@"ToDoList" sortDescriptor:nil];
//    for (ToDoList *toDoList in toDoLists) {
//        if ([toDoList.toDoListId isEqualToNumber:task.currentToDoList.toDoListId]) {
//            for (Task *taskCD in toDoList.arrayTasks) {
//                if ([taskCD.taskId isEqualToNumber:task.taskId]) {
//                    [toDoList removeArrayTasksObject:taskCD];
//                }
//            }
//        }
//    }
}

- (void)deleteToDoListById:(NSNumber *)toDoListId {
    NSArray *arrayToDoLists = [self allEntityWithName:@"ToDoList" sortDescriptor:nil];
    for (ToDoList *item in arrayToDoLists) {
        if ([item.toDoListId isEqualToNumber:toDoListId]) {
            [self.managedObjectContext deleteObject:item];
            break;
        }
    }
}

- (Parent *)createEntityWithName:(NSString *)name {
    Parent *entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.managedObjectContext];
    return entity;
}

- (void)addEntityWithEntity:(Parent *)entity {
//    if ([entity isKindOfClass:[Task class]]) {
//        Task *task = (Task *)entity;
//        NSString *dateTask = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
//    }
//    [self.managedObjectContext save:nil];
}



- (ToDoList *)backRightToDoListByToDoList:(ToDoList *)toDoList {
    NSArray *arrayToDoLists = [self allEntityWithName:@"ToDoList" sortDescriptor:nil];
    if ([arrayToDoLists containsObject:toDoList]) {
        for (ToDoList *item in arrayToDoLists) {
            if ([item.toDoListId isEqualToNumber:toDoList.toDoListId]) {
                return item;
            }
        }
    }
    ToDoList *coreDataToDoList = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
//    coreDataToDoList.name = toDoList.toDoListName;
//    coreDataToDoList.toDoListId = toDoList.toDoListId;
//    [coreDataToDoList addArrayTasks:[NSSet setWithArray:toDoList.toDoListArrayTasks]];
    return coreDataToDoList;
}

- (void)updateTaskByTask:(Task *)task {
    NSArray *tasks = [self allEntityWithName:@"Task" sortDescriptor:nil];
    for (Task *item in tasks) {
        if ([item.taskId isEqualToNumber:task.taskId]) {
            item.name = task.name;
            item.startedAt = task.startedAt;
            item.finishedAt = task.finishedAt;
            item.completed = task.completed;
            item.remind = task.remind;
            item.priority = task.priority;
            item.notes = task.notes;
        }
    }
}

- (void)updateToDoListByToDoList:(ToDoList *)toDoList {
    NSArray *toDoLists = [self allEntityWithName:@"ToDoList" sortDescriptor:nil];
    for (ToDoList *item in toDoLists) {
        if ([item.toDoListId isEqualToNumber:toDoList.toDoListId]) {
            item.name = toDoList.name;
        }
    }
}

#pragma mark - save context

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"error %@ %@", error, [error localizedDescription]);
        }
    }
}

#pragma mark - get document directory

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data Stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"CoreDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataModel.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if ([_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    }
    return _persistentStoreCoordinator;
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
