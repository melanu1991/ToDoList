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
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(cfg:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
    });
    return manager;
}

#pragma mark - Notification

- (void)cfg:(NSNotification *)notification {
    
}

#pragma mark - work with entities

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
    coreDataTask.toDoList = [self addToDoListWithToDoList:task.currentToDoList];
}

- (ToDoList *)addToDoListWithToDoList:(VAKToDoList *)toDoList {
    ToDoList *coreDataToDoList = [NSEntityDescription insertNewObjectForEntityForName:@"ToDoList" inManagedObjectContext:self.managedObjectContext];
    coreDataToDoList.name = toDoList.toDoListName;
    coreDataToDoList.toDoListId = toDoList.toDoListId;
    coreDataToDoList.arrayTasks = [NSSet setWithArray:toDoList.toDoListArrayTasks];
    return coreDataToDoList;
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
