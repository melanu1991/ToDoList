#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VAKTaskCD+CoreDataClass.h"
#import "VAKTask.h"

@interface VAKCoreDataManager : NSObject

+ (VAKCoreDataManager *)sharedManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)addTaskToCoreData:(VAKTask *)task;
- (void)removeTaskById:(NSString *)taskId;
- (void)updateTaskWithTask:(VAKTask *)task;
- (void)removeAllObjects;
- (NSArray *)loadTasks;

@end
