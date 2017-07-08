#import <Foundation/Foundation.h>
#import "Parent+CoreDataClass.h"

@class ToDoList;

@interface Task : Parent

@property (nonatomic) BOOL completed;
@property (nullable, nonatomic, copy) NSDate *finishedAt;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSString *priority;
@property (nonatomic) BOOL remind;
@property (nullable, nonatomic, copy) NSDate *startedAt;
@property (nullable, nonatomic, copy) NSNumber *taskId;
@property (nullable, nonatomic, retain) ToDoList *toDoList;

@end
