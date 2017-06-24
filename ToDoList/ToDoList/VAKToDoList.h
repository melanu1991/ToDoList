#import <Foundation/Foundation.h>
#import "VAKTask.h"
#import "VAKTaskService.h"
#import "Constants.h"

@interface VAKToDoList : NSObject

@property (assign, nonatomic) NSNumber *toDoListId;
@property (strong, nonatomic) NSString *toDoListName;
@property (strong, nonatomic) NSArray *toDoListArrayTasks;
@property (strong, nonatomic) VAKTaskService *taskService;

- (instancetype)initWithName:(NSString *)name;

@end

@interface VAKToDoList (Additional)

- (void)addTaskById:(NSNumber *)toDoListId task:(VAKTask *)task;
- (void)removeTaskById:(NSNumber *)toDoListId task:(VAKTask *)task;
- (void)updateTaskById:(NSNumber *)toDoListId task:(VAKTask *)task;
- (void)addNewProjectWithName:(NSString *)name;
- (void)removeProjectWithName:(NSString *)name;

@end
