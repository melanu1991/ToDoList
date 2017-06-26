#import <Foundation/Foundation.h>
#import "VAKTask.h"
#import "Constants.h"

@interface VAKToDoList : NSObject

@property (assign, nonatomic) NSNumber *toDoListId;
@property (strong, nonatomic) NSString *toDoListName;
@property (strong, nonatomic) NSArray *toDoListArrayTasks;

- (instancetype)initWithName:(NSString *)name;

@end

@interface VAKToDoList (Additional)

- (void)addTaskByToDoList:(VAKToDoList *)toDoList task:(VAKTask *)task;
- (void)removeTaskByToDoList:(VAKToDoList *)toDoList task:(VAKTask *)task;
- (void)updateTaskByToDoList:(VAKToDoList *)toDoList task:(VAKTask *)task;
- (void)addNewProjectWithName:(NSString *)name;
- (void)removeProject;

@end
