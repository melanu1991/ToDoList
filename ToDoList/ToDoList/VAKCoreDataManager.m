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
//        [manager deleteAllObjects];
        [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSArray *arrayToDoList = [manager allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:nil];
        if (arrayToDoList.count == 0) {
            ToDoList *inbox = (ToDoList *)[manager createEntityWithName:@"ToDoList"];
            inbox.name = VAKInbox;
            [manager.managedObjectContext save:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(remindMeOnADay:) name:VAKRemindTask object:nil];
    });
    return manager;
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    Task *currentTask = notification.userInfo[VAKCurrentTask];
    if (notification.userInfo[VAKDetailTaskWasChanged]) {
        NSDate *newDate = notification.userInfo[VAKNewDate];
        NSDate *lastDate = currentTask.startedAt;
        [self updateTaskByName:notification.userInfo[VAKNewTaskName] notes:notification.userInfo[VAKNewNotes] newDate:newDate lastDate:lastDate priority:notification.userInfo[VAKNewPriority] taskId:currentTask.taskId];
    }
    else if (notification.userInfo[VAKDoneTask]) {
        [self completeTask:currentTask];
    }
    else if (notification.userInfo[VAKDeleteTask]) {
        [self deleteEntity:currentTask];
    }
    else if (notification.userInfo[VAKWasEditNameGroup]) {
        [self renameGroup:notification.userInfo[VAKCurrentGroup] newName:notification.userInfo[VAKInputNewNameGroup]];
    }
    else if (notification.userInfo[VAKDeleteGroupTask]) {
        [self deleteEntity:notification.userInfo[VAKCurrentGroup]];
    }
    [self.managedObjectContext save:nil];
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

- (void)renameGroup:(ToDoList *)toDoList newName:(NSString *)newName{
    toDoList.name = newName;
}

- (void)completeTask:(Task *)task {
    task.completed = YES;
    task.finishedAt = [NSDate date];
}

- (void)deleteEntity:(Parent *)entity {
    if ([entity isKindOfClass:[Task class]]) {
        Task *task = (Task *)entity;
        if (task.date.tasks.count == 1) {
            Date *currentDate = task.date;
            [self.managedObjectContext deleteObject:currentDate];
        }
        [self.managedObjectContext deleteObject:task];
    }
    else if ([entity isKindOfClass:[ToDoList class]]) {
        ToDoList *toDoList = (ToDoList *)entity;
        [self.managedObjectContext deleteObject:toDoList];
    }
}

- (NSInteger)countOfEntityWithName:(NSString *)name {
    NSArray *array = [self allEntityWithName:name sortDescriptor:nil predicate:nil];
    return [array count];
}

- (NSArray *)allEntityWithName:(NSString *)name sortDescriptor:(NSSortDescriptor *)sortDescriptor predicate:(NSPredicate *)predicate {
    NSFetchRequest *fetchRequests = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    [fetchRequests setEntity:entityDescription];
    if (sortDescriptor != nil) {
        [fetchRequests setSortDescriptors:@[sortDescriptor]];
    }
    if (predicate != nil) {
        [fetchRequests setPredicate:predicate];
    }
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequests error:nil];
    return array;
}

- (void)deleteAllObjects {
    NSArray *arrayToDoLists = [self allEntityWithName:@"ToDoList" sortDescriptor:nil predicate:nil];
    for (ToDoList *item in arrayToDoLists) {
        [self.managedObjectContext deleteObject:item];
    }
    NSArray *arrayDate = [self allEntityWithName:@"Date" sortDescriptor:nil predicate:nil];
    for (Date *date in arrayDate) {
        [self.managedObjectContext deleteObject:date];
    }
    NSArray *arrayTasks = [self allEntityWithName:@"Task" sortDescriptor:nil predicate:nil];
    for (Task *task in arrayTasks) {
        [self.managedObjectContext deleteObject:task];
    }
    [self.managedObjectContext save:nil];
}

- (Parent *)createEntityWithName:(NSString *)name {
    Parent *entity = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:self.managedObjectContext];
    return entity;
}

- (void)updateTaskByName:(NSString *)name notes:(NSString *)notes newDate:(NSDate *)newDate lastDate:(NSDate *)lastDate priority:(NSString *)priority taskId:(NSNumber *)taskId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"taskId == %@", taskId];
    NSArray *tasks = [self allEntityWithName:@"Task" sortDescriptor:nil predicate:predicate];
    if (tasks.count > 0) {
        Task *currentTask = tasks[0];
        NSString *newDateStr = [NSDate dateStringFromDate:newDate format:VAKDateFormatWithoutHourAndMinute];
        NSString *lastDateStr = [NSDate dateStringFromDate:lastDate format:VAKDateFormatWithoutHourAndMinute];
        currentTask.name = name;
        currentTask.notes = notes;
        currentTask.priority = priority;
        currentTask.startedAt = newDate;
        if (![newDateStr isEqualToString:lastDateStr]) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", lastDateStr];
            NSArray *lastDateArray = [self allEntityWithName:@"Date" sortDescriptor:nil predicate:predicate];
            Date *date = lastDateArray[0];
            [date removeTasksObject:currentTask];
            if (date.tasks.count == 0) {
                [self.managedObjectContext deleteObject:date];
            }
            predicate = [NSPredicate predicateWithFormat:@"date == %@", newDateStr];
            NSArray *newDateArray = [self allEntityWithName:@"Date" sortDescriptor:nil predicate:predicate];
            if (newDateArray.count > 0) {
                Date *date = newDateArray[0];
                [date addTasksObject:currentTask];
            }
            else {
                Date *date = (Date *)[self createEntityWithName:@"Date"];
                date.date = newDateStr;
                [date addTasksObject:currentTask];
            }
        }
    }
}

#pragma mark - Core Data Stack

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreDataModel.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Save Context

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@ %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Application Documents Directory

-(NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
