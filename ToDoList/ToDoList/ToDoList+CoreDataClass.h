#import <Foundation/Foundation.h>
#import "Parent+CoreDataClass.h"

@class Task;

@interface ToDoList : Parent

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *toDoListId;
@property (nullable, nonatomic, retain) NSSet<Task *> *arrayTasks;

@end

@interface ToDoList (CoreDataGeneratedAccessors)

- (void)addArrayTasksObject:(Task *_Nullable)value;
- (void)removeArrayTasksObject:(Task *_Nullable)value;
- (void)addArrayTasks:(NSSet<Task *> *_Nullable)values;
- (void)removeArrayTasks:(NSSet<Task *> *_Nullable)values;

@end
