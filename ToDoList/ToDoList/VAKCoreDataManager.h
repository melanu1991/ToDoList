#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Task+CoreDataClass.h"
#import "ToDoList+CoreDataClass.h"
#import "Parent+CoreDataClass.h"
#import "VAKNSDate+Formatters.h"
#import "Date+CoreDataClass.h"

@interface VAKCoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (VAKCoreDataManager *)sharedManager;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)deleteTaskByTask:(Task *)task;
- (void)updateTaskByTask:(Task *)task;
- (void)updateToDoListByToDoList:(ToDoList *)toDoList;
- (void)deleteToDoListById:(NSNumber *)toDoListId;
- (NSArray *)allEntityWithName:(NSString *)name sortDescriptor:(NSSortDescriptor *)sortDescriptor;
- (NSInteger)countOfEntityWithName:(NSString *)name;
- (Parent *)createEntityWithName:(NSString *)name;

@end
