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

- (void)updateTaskByName:(NSString *)name notes:(NSString *)notes newDate:(NSDate *)newDate lastDate:(NSDate *)lastDate priority:(NSString *)priority taskId:(NSNumber *)taskId;
- (void)deleteEntity:(Parent *)entity;
- (void)completeTask:(Task *)task;
- (NSArray *)allEntityWithName:(NSString *)name sortDescriptor:(NSSortDescriptor *)sortDescriptor predicate:(NSPredicate *)predicate;
- (NSInteger)countOfEntityWithName:(NSString *)name;
- (Parent *)createEntityWithName:(NSString *)name;

@end
