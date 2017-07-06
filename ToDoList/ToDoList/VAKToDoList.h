#import <Foundation/Foundation.h>
#import "VAKTask.h"
#import "Constants.h"

@interface VAKToDoList : NSObject <NSCoding>

@property (assign, nonatomic) NSNumber *toDoListId;
@property (strong, nonatomic) NSString *toDoListName;
@property (strong, nonatomic) NSArray *toDoListArrayTasks;

- (instancetype)initWithName:(NSString *)name;

@end

@interface VAKToDoList (Additional)

- (void)addTaskByTask:(VAKTask *)task;
- (void)removeTaskByTask:(VAKTask *)task;

@end
