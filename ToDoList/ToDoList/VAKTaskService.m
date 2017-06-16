#import "VAKTaskService.h"

@interface VAKTaskService ()

@end

@implementation VAKTaskService

+ (VAKTaskService *)sharedVAKTaskService {
    static VAKTaskService *sharedVAKTaskService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedVAKTaskService = [[self alloc] init];
    });
    return sharedVAKTaskService;
}

- (instancetype)init {
    if (self = [super init]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEEE, dd MMMM yyyy г., HH:mm";
        self.tasks = [NSMutableArray array];
        VAKTask *task1 = [[VAKTask alloc] initTaskWithId:@"1" taskName:@"task1"];
        task1.startedAt = [formatter dateFromString:@"Saturday, 08 June 2017 г., 12:57"];
        task1.notes = @"My new task!";
        task1.completed = YES;
        task1.currentGroup = @"Inbox";
        task1.priority = @"Low";
        task1.remindMeOnADay = YES;
        VAKTask *task2 = [[VAKTask alloc] initTaskWithId:@"2" taskName:@"task2"];
        task2.startedAt = [formatter dateFromString:@"Thursday, 15 June 2017 г., 12:57"];
        task2.notes = @"My new task!";
        task2.currentGroup = @"Inbox";
        task2.completed = YES;
        VAKTask *task3 = [[VAKTask alloc] initTaskWithId:@"3" taskName:@"task3"];
        task3.startedAt = [formatter dateFromString:@"Monday, 09 June 2017 г., 12:57"];
        task3.notes = @"My new task!";
        task3.completed = YES;
        task3.currentGroup = @"Work";
        VAKTask *task4 = [[VAKTask alloc] initTaskWithId:@"4" taskName:@"task4"];
        task4.startedAt = [formatter dateFromString:@"Sunday, 08 June 2017 г., 12:57"];
        task4.notes = @"My new task!";
        task4.currentGroup = @"Building";
        VAKTask *task5 = [[VAKTask alloc] initTaskWithId:@"5" taskName:@"task5"];
        task5.startedAt = [formatter dateFromString:@"Tuesday, 10 June 2017 г., 12:57"];
        task5.notes = @"My new task!";
        task5.currentGroup = @"Inbox";
        VAKTask *task6 = [[VAKTask alloc] initTaskWithId:@"6" taskName:@"task6"];
        task6.startedAt = [formatter dateFromString:@"Tuesday, 11 June 2017 г., 12:57"];
        task6.notes = @"My new task!";
        task6.currentGroup = @"Building";
        task6.priority = @"None";
        VAKTask *task7 = [[VAKTask alloc] initTaskWithId:@"7" taskName:@"task7"];
        task7.startedAt = [formatter dateFromString:@"Thursday, 15 June 2017 г., 12:57"];
        task7.notes = @"My new task!";
        task7.currentGroup = @"My";
        task7.remindMeOnADay = YES;
        [self addTask:task1];
        [self addTask:task2];
        [self addTask:task3];
        [self addTask:task4];
        [self addTask:task5];
        [self addTask:task6];
        [self addTask:task7];
    }
    return self;
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

- (NSDictionary *)dictionaryDate {
    if (!_dictionaryDate) {
        _dictionaryDate = [NSMutableDictionary dictionary];
    }
    return _dictionaryDate;
}

- (NSDictionary *)dictionaryGroup {
    if (!_dictionaryGroup) {
        _dictionaryGroup = [NSMutableDictionary dictionary];
    }
    return _dictionaryGroup;
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

- (void)addTask:(VAKTask *)task {
    [self.tasks addObject:task];
    //выбор группы для таска complited/not complited
    if (task.isCompleted) {
        [self.groupCompletedTasks addObject:task];
    }
    else {
        [self.groupNotCompletedTasks addObject:task];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.YYYY";
    
    NSString *currentDate = [dateFormatter stringFromDate:task.startedAt];
    NSString *currentGroup = task.currentGroup;
    
    //если небыло массива с такой датой/группой то создаем и добавляем в него таск, если был то просто добавляем таск
    if (self.dictionaryDate[currentDate] == nil) {
        [self.dictionaryDate setObject:[[NSMutableArray alloc] init] forKey:currentDate];
        NSMutableArray *tempArrayDate = self.dictionaryDate[currentDate];
        [tempArrayDate addObject:task];
    }
    else {
        NSMutableArray *tempArrayDate = self.dictionaryDate[currentDate];
        [tempArrayDate addObject:task];
    }
    
    if (self.dictionaryGroup[currentGroup] == nil) {
        [self.dictionaryGroup setObject:[[NSMutableArray alloc] init] forKey:currentGroup];
        NSMutableArray *tempArrayGroup = self.dictionaryGroup[currentGroup];
        [tempArrayGroup addObject:task];
    }
    else {
        NSMutableArray *tempArrayGroup = self.dictionaryGroup[currentGroup];
        [tempArrayGroup addObject:task];
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

- (void)updateTask:(VAKTask *)task {
    //не совсем понятно что тут апдейтить и когда его вызывать!
    //выбор группы для таска complited/not complited

}

- (void)addGroup:(NSString *)group {
    if (self.dictionaryGroup[group] == nil) {
        [self.dictionaryGroup setObject:[[NSMutableArray alloc] init] forKey:group];
    }
}

//сортировка ключей для отображения в нужном порядке по датам/группам
- (void)sortArrayKeysGroup {
    NSArray *arrayKeysGroup = [self.dictionaryGroup allKeys];
    arrayKeysGroup = [arrayKeysGroup sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    self.arrayKeysGroup = arrayKeysGroup;
}

- (void)sortArrayKeysDate {
    NSArray *arrayKeysDate = [self.dictionaryDate allKeys];
    arrayKeysDate = [arrayKeysDate sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    self.arrayKeysDate = arrayKeysDate;
}

@end
