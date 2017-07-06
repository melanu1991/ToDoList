#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Task;

@interface ToDoList : NSManagedObject

@property (nullable, nonatomic, copy) NSNumber *id;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Task *> *arrayTasks;

@end

@interface ToDoList (CoreDataGeneratedAccessors)

- (void)addArrayTasksObject:(Task *_Nullable)value;
- (void)removeArrayTasksObject:(Task *_Nullable)value;
- (void)addArrayTasks:(NSSet<Task *> *_Nullable)values;
- (void)removeArrayTasks:(NSSet<Task *> *_Nullable)values;

@end
