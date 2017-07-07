#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Constants.h"
#import "Task+CoreDataClass.h"
#import "ToDoList+CoreDataClass.h"
#import "VAKTask.h"
#import "VAKToDoList.h"

@interface VAKCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (VAKCoreDataManager *)sharedManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)deleteTaskByTask:(VAKTask *)task;
- (void)addTaskWithTask:(VAKTask *)task;
- (void)addToDoListWithName:(NSString *)name id:(NSNumber *)toDoListId;
- (void)updateTaskByTask:(VAKTask *)task;
- (void)updateToDoListByToDoList:(VAKToDoList *)toDoList;
- (void)deleteToDoListById:(NSNumber *)toDoListId;
- (NSArray *)allEntityWithName:(NSString *)name;

@end
