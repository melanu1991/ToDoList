#import "VAKTaskService.h"
#import "Constants.h"

@interface VAKTaskService ()

@property (assign, nonatomic, getter=isReverseOrdered) BOOL reverseOrdered;

@end

@implementation VAKTaskService

#pragma mark - initialize

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
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = VAKDateFormatWithHourAndMinute;
        self.tasks = [NSMutableArray array];
        VAKTask *task1 = [[VAKTask alloc] initTaskWithId:@"1" taskName:@"task1"];
        task1.startedAt = [self.dateFormatter dateFromString:@"Saturday, 08 June 2017 г., 12:57"];
        task1.notes = @"My new task!";
        task1.completed = YES;
        task1.currentGroup = @"Inbox";
        task1.priority = @"Low";
        task1.remindMeOnADay = YES;
        VAKTask *task2 = [[VAKTask alloc] initTaskWithId:@"2" taskName:@"task2"];
        task2.startedAt = [self.dateFormatter dateFromString:@"Thursday, 15 June 2017 г., 12:57"];
        task2.notes = @"My new task!";
        task2.currentGroup = @"Inbox";
        task2.completed = YES;
        VAKTask *task3 = [[VAKTask alloc] initTaskWithId:@"3" taskName:@"task3"];
        task3.startedAt = [self.dateFormatter dateFromString:@"Monday, 09 June 2017 г., 12:57"];
        task3.notes = @"My new task!";
        task3.completed = YES;
        task3.currentGroup = @"Work";
        VAKTask *task4 = [[VAKTask alloc] initTaskWithId:@"4" taskName:@"task4"];
        task4.startedAt = [self.dateFormatter dateFromString:@"Sunday, 08 June 2017 г., 12:57"];
        task4.notes = @"My new task!";
        task4.currentGroup = @"Building";
        VAKTask *task5 = [[VAKTask alloc] initTaskWithId:@"5" taskName:@"task5"];
        task5.startedAt = [self.dateFormatter dateFromString:@"Tuesday, 10 June 2017 г., 12:57"];
        task5.notes = @"My new task!";
        task5.currentGroup = @"Inbox";
        VAKTask *task6 = [[VAKTask alloc] initTaskWithId:@"6" taskName:@"task6"];
        task6.startedAt = [self.dateFormatter dateFromString:@"Tuesday, 11 June 2017 г., 12:57"];
        task6.notes = @"My new task!";
        task6.currentGroup = @"Building";
        task6.priority = @"None";
        VAKTask *task7 = [[VAKTask alloc] initTaskWithId:@"7" taskName:@"task7"];
        task7.startedAt = [self.dateFormatter dateFromString:@"Thursday, 15 June 2017 г., 12:57"];
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

#pragma mark - lazy getters

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

#pragma mark - work on tasks

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

    self.dateFormatter.dateFormat = VAKDateFormatWithoutHourAndMinute;
    
    NSString *currentDate = [self.dateFormatter stringFromDate:task.startedAt];
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
    self.dateFormatter.dateFormat = VAKDateFormatWithoutHourAndMinute;
    
    for (VAKTask *task in self.tasks) {
        if ([task.taskId isEqualToString:taskId]) {
            NSString *currentDate = [self.dateFormatter stringFromDate:task.startedAt];
            [self.tasks removeObject:task];
            NSMutableArray *arrayDate = self.dictionaryDate[currentDate];
            NSMutableArray *arrayGroup = self.dictionaryGroup[task.currentGroup];
            [arrayDate removeObject:task];
            [arrayGroup removeObject:task];
            if ([arrayGroup count] == 0) {
                [self.dictionaryGroup removeObjectForKey:task.currentGroup];
                [self sortArrayKeysGroup:self.isReverseOrdered];
            }
            if ([arrayDate count] == 0) {
                [self.dictionaryDate removeObjectForKey:currentDate];
                [self sortArrayKeysDate:self.isReverseOrdered];
            }
            return;
        }
    }
}

- (void)updateTask:(VAKTask *)task lastDate:(NSString *)lastDate {
    self.dateFormatter.dateFormat = VAKDateFormatWithoutHourAndMinute;
    NSMutableArray *arrayDate = self.dictionaryDate[lastDate];
    [arrayDate removeObject:task];
    if ([arrayDate count] == 0) {
        [self.dictionaryDate removeObjectForKey:lastDate];
    }
    arrayDate = self.dictionaryDate[[self.dateFormatter stringFromDate:task.startedAt]];
    if (arrayDate == nil) {
        arrayDate = [[NSMutableArray alloc] initWithObjects:task, nil];
    }
    else {
        [arrayDate addObject:task];
    }
    [self.dictionaryDate setObject:arrayDate forKey:[self.dateFormatter stringFromDate:task.startedAt]];
    [self sortArrayKeysDate:self.isReverseOrdered];

}

//Добавление новой группы ToDoList
- (void)addGroup:(NSString *)group {
    if (self.dictionaryGroup[group] == nil) {
        [self.dictionaryGroup setObject:[[NSMutableArray alloc] init] forKey:group];
    }
}

//сортировка ключей для отображения в нужном порядке по датам/группам
- (void)sortArrayKeysGroup:(BOOL)isReverseOrder {
    self.reverseOrdered = isReverseOrder;
    NSArray *arrayKeysGroup = [self.dictionaryGroup allKeys];
    arrayKeysGroup = [arrayKeysGroup sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (isReverseOrder) {
            return -[obj1 compare:obj2];
        }
        else {
            return [obj1 compare:obj2];
        }
    }];
    self.arrayKeysGroup = arrayKeysGroup;
}

//подумать как реализовать алгоритм с учетом еще времени, а не только даты!
- (void)sortArrayKeysDate:(BOOL)isReverseOrder {
    self.reverseOrdered = isReverseOrder;
    NSArray *arrayKeysDate = [self.dictionaryDate allKeys];
    arrayKeysDate = [arrayKeysDate sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        if (isReverseOrder) {
            return -[obj1 compare:obj2];
        }
        else {
            return [obj1 compare:obj2];
        }
    }];
    self.arrayKeysDate = arrayKeysDate;
}

@end
