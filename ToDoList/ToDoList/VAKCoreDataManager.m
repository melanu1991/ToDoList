#import "VAKCoreDataManager.h"

@implementation VAKCoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton

+ (VAKCoreDataManager *)sharedManager {
    static VAKCoreDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[VAKCoreDataManager alloc] init];
    });
    return manager;
}

#pragma mark - helpers methods

- (NSArray *)allTasks {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *descriptor = [NSEntityDescription entityForName:@"VAKTaskCD" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:descriptor];
    NSError *error = nil;
    NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    return resultArray;
}

- (NSArray *)loadTasks {
    NSArray *arrayTasksCD = [self allTasks];
    NSMutableArray *arrayTasks = [NSMutableArray array];
    for (VAKTaskCD *item in arrayTasksCD) {
        VAKTask *task = [[VAKTask alloc] initTaskWithId:item.taskId taskName:item.taskName];
        [arrayTasks addObject:task];
    }
    return arrayTasks;
}

- (void)addTaskToCoreData:(VAKTask *)task {
    VAKTaskCD *taskCD = [NSEntityDescription insertNewObjectForEntityForName:@"VAKTaskCD" inManagedObjectContext:self.managedObjectContext];
    taskCD.taskName = task.taskName;
    taskCD.taskId = task.taskId;
    taskCD.notes = task.notes;
    taskCD.startedAt = task.startedAt;
    taskCD.finishedAt = task.finishedAt;
    taskCD.completed = task.completed;
    taskCD.remindMeOnADay = task.remindMeOnADay;
    taskCD.priority = task.priority;
    taskCD.currentGroup = task.currentGroup;
    [taskCD.managedObjectContext save:nil];
}

- (void)removeTaskById:(NSString *)taskId {
    NSArray *allObjects = [self allTasks];
    for (VAKTaskCD *currentTask in allObjects) {
        if ([currentTask.taskId isEqualToString:taskId]) {
            [self.managedObjectContext deleteObject:currentTask];
            [self.managedObjectContext save:nil];
            break;
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


@end
