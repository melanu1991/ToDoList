#import <Foundation/Foundation.h>
#import "Parent+CoreDataClass.h"

@class Task;

@interface VAKManagedData : Parent

@property (nullable, nonatomic, copy) NSString *date;
@property (nullable, nonatomic, retain) NSSet<Task *> *tasks;

@end

@interface VAKManagedData (CoreDataGeneratedAccessors)

- (void)addTasksObject:(Task *_Nullable)value;
- (void)removeTasksObject:(Task *_Nullable)value;
- (void)addTasks:(NSSet<Task *> *_Nullable)values;
- (void)removeTasks:(NSSet<Task *> *_Nullable)values;

@end
