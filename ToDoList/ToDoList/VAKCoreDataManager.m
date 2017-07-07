#import "VAKCoreDataManager.h"
#import "Constants.h"
#import "Task+CoreDataClass.h"
#import "ToDoList+CoreDataClass.h"
#import "VAKTask.h"
#import "VAKToDoList.h"

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
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(workOnTaskOrToDoList:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
    });
    return manager;
}

#pragma mark - Notification

- (void)workOnTaskOrToDoList:(NSNotification *)notification {
    VAKTask *task = notification.userInfo[VAKCurrentTask];
    if (notification.userInfo[VAKAddNewTask]) {
        
    }
    else if (notification.userInfo[VAKDeleteTask]) {
        
    }
    else if (notification.userInfo[VAKWasEditNameGroup]) {
        
    }
    else if (notification.userInfo[VAKAddProject]) {
        
    }
    else if (notification.userInfo[VAKDetailTaskWasChanged]) {
        
    }
    else if (notification.userInfo[VAKDeleteGroupTask]) {
        
    }
}

#pragma mark - work with entities

- (NSArray *)allEntityWithName:(NSString *)name {
    NSFetchRequest *fetchRequests = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext];
    [fetchRequests setEntity:entityDescription];
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequests error:nil];
    return array;
}

- (void)deleteAllObjects {
    NSArray *arrayToDoLists = [self allEntityWithName:@"ToDoList"];
    for (ToDoList *item in arrayToDoLists) {
        [self.managedObjectContext deleteObject:item];
    }
}

- (void)deleteTaskByTask:(VAKTask *)task {
    NSArray *toDoLists = [self allEntityWithName:@"ToDoList"];
    for (ToDoList *toDoList in toDoLists) {
        if ([toDoList.toDoListId isEqualToNumber:task.currentToDoList.toDoListId]) {
            for (Task *taskCD in toDoList.arrayTasks) {
                if ([taskCD.taskId isEqualToNumber:task.taskId]) {
                    [toDoList removeArrayTasksObject:taskCD];
                }
            }
        }
    }
}

- (void)addTaskWithTask:(VAKTask *)task {
    Task *coreDataTask = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.managedObjectContext];
    coreDataTask.name = task.taskName;
    coreDataTask.taskId = task.taskId;
    coreDataTask.completed = task.completed;
    coreDataTask.remind = task.remindMeOnADay;
    coreDataTask.notes = task.notes;
    coreDataTask.startedAt = task.startedAt;
    coreDataTask.finishedAt = task.finishedAt;
    coreDataTask.priority = task.priority;
    coreDataTask.toDoList = [self backRightToDoListByToDoList:task.currentToDoList];
    [self.managedObjectContext save:nil];
}

- (ToDoList *)backRightToDoListByToDoList:(VAKToDoList *)toDoList {
    NSArray *arrayToDoLists = [self allEntityWithName:@"ToDoList"];
    if ([arrayToDoLists containsObject:toDoList]) {
        for (ToDoList *item in arrayToDoLists) {
            if ([item.toDoListId isEqualToNumber:toDoList.toDoListId]) {
                return item;
            }
        }
    }
    ToDoList *coreDataToDoList = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
    coreDataToDoList.name = toDoList.toDoListName;
    coreDataToDoList.toDoListId = toDoList.toDoListId;
    coreDataToDoList.arrayTasks = [NSSet setWithArray:toDoList.toDoListArrayTasks];
    return coreDataToDoList;
}

- (void)addToDoListWithName:(NSString *)name id:(NSNumber *)toDoListId {
    ToDoList *coreDataToDoList = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
    coreDataToDoList.name = name;
    coreDataToDoList.toDoListId = toDoListId;
    [self.managedObjectContext save:nil];
}

- (void)updateTaskByTask:(VAKTask *)task {
    NSArray *tasks = [self allEntityWithName:@"Task"];
    for (Task *item in tasks) {
        if ([item.taskId isEqualToNumber:task.taskId]) {
            item.name = task.taskName;
            item.startedAt = task.startedAt;
            item.finishedAt = task.finishedAt;
            item.completed = task.completed;
            item.remind = task.remindMeOnADay;
            item.priority = task.priority;
            item.notes = task.notes;
        }
    }
}

- (void)updateToDoListByToDoList:(VAKToDoList *)toDoList {
    NSArray *toDoLists = [self allEntityWithName:@"ToDoList"];
    for (ToDoList *item in toDoLists) {
        if ([item.toDoListId isEqualToNumber:toDoList.toDoListId]) {
            item.name = toDoList.toDoListName;
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

@end
