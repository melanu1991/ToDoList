#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ToDoList;

@interface Task : NSManagedObject

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSNumber *taskId;
@property (nullable, nonatomic, copy) NSDate *startedAt;
@property (nullable, nonatomic, copy) NSDate *finishedAt;
@property (nonatomic) BOOL completed;
@property (nullable, nonatomic, copy) NSString *priority;
@property (nonatomic) BOOL remind;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, retain) ToDoList *toDoList;

@end
