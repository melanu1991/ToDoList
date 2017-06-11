#import "VAKTaskService.h"

@interface VAKTaskService ()

@end

@implementation VAKTaskService

+ (instancetype)initDefaultTaskService {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE, dd MMMM yyyy г., HH:mm";
    VAKTaskService *taskService = [[VAKTaskService alloc] init];
    taskService.tasks = [NSMutableArray array];
    VAKTask *task1 = [[VAKTask alloc] initTaskWithId:@"1" taskName:@"task1"];
    task1.startedAt = [formatter dateFromString:@"Saturday, 08 June 2017 г., 12:57"];
    task1.notes = @"My new task!";
    task1.completed = YES;
    VAKTask *task2 = [[VAKTask alloc] initTaskWithId:@"2" taskName:@"task2"];
    task2.startedAt = [formatter dateFromString:@"Sunday, 07 June 2017 г., 12:57"];
    task2.notes = @"My new task!";
    VAKTask *task3 = [[VAKTask alloc] initTaskWithId:@"3" taskName:@"task3"];
    task3.startedAt = [formatter dateFromString:@"Monday, 09 June 2017 г., 12:57"];
    task3.notes = @"My new task!";
    task3.completed = YES;
    VAKTask *task4 = [[VAKTask alloc] initTaskWithId:@"4" taskName:@"task4"];
    task4.startedAt = [formatter dateFromString:@"Sunday, 08 June 2017 г., 12:57"];
    task4.notes = @"My new task!";
    VAKTask *task5 = [[VAKTask alloc] initTaskWithId:@"5" taskName:@"task5"];
    task5.startedAt = [formatter dateFromString:@"Tuesday, 10 June 2017 г., 12:57"];
    task5.notes = @"My new task!";
    VAKTask *task6 = [[VAKTask alloc] initTaskWithId:@"6" taskName:@"task6"];
    task6.startedAt = [formatter dateFromString:@"Tuesday, 11 June 2017 г., 12:57"];
    task6.notes = @"My new task!";
    VAKTask *task7 = [[VAKTask alloc] initTaskWithId:@"7" taskName:@"task7"];
    task7.startedAt = [formatter dateFromString:@"Wednesday, 07 June 2017 г., 12:57"];
    task7.notes = @"My new task!";
    [taskService addTask:task1];
    [taskService addTask:task2];
    [taskService addTask:task3];
    [taskService addTask:task4];
    [taskService addTask:task5];
    [taskService addTask:task6];
    [taskService addTask:task7];
    return taskService;
}

- (NSMutableArray *)groupCompletedTasks {
    if (!_groupCompletedTasks) {
        _groupCompletedTasks = [[NSMutableArray alloc] init];
    }
    return _groupCompletedTasks;
}

- (NSMutableArray *)groupNotCompletedTasks {
    if (!_groupNotCompletedTasks) {
        _groupNotCompletedTasks = [[NSMutableArray alloc] init];
    }
    return _groupNotCompletedTasks;
}

- (NSArray *)tasks {
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc]init];
    }
    return _tasks;
}

- (VAKTask *)taskById:(NSString *)taskId {
    for (int i = 0; i < self.tasks.count; i++) {
        VAKTask *task = self.tasks[i];
        if ([task.taskId isEqualToString:taskId]) {
            return task;
        }
    }
    return nil;
}

//при добавлении таска сразу выбирается его группа Completed/Not Completed
- (void)addTask:(VAKTask *)task {
    [self.tasks addObject:task];
    if (task.isCompleted) {
        [self.groupCompletedTasks addObject:task];
    }
    else {
        [self.groupNotCompletedTasks addObject:task];
    }
}

- (void)removeTaskById:(NSString *)taskId {
    for (int i = 0; i < self.tasks.count; i++) {
        VAKTask *task = (VAKTask *)self.tasks[i];
        if ([task.taskId isEqualToString:taskId]) {
            [self.tasks removeObject:task];
        }
    }
}

//При изменении таска также происходит обновление его полей и перевод в другую группу если она изменилась
- (void)updateTask:(VAKTask *)task {

}

@end
