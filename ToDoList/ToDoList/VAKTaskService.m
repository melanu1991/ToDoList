#import "VAKTaskService.h"
#import "VAKToDoList.h"

@interface VAKTaskService ()

@property (assign, nonatomic, getter=isReverseOrdered) BOOL reverseOrdered;

@end

@implementation VAKTaskService
{
    NSMutableArray *_privateToDoListArray;
    NSMutableArray *_privateTasksArray;
    NSMutableDictionary *_privateDictionaryDate;
    NSMutableDictionary *_privateDictionaryGroup;
}

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
        [self loadData];
        if (!_tasks) {
            _tasks = [NSMutableArray array];
            [self addGroup:VAKInbox];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remindMeOnADay:) name:VAKRemindTask object:nil];
    return self;
}

#pragma mark - save and load data

- (void)saveData {
    NSData *tasks = [NSKeyedArchiver archivedDataWithRootObject:self.tasks];
    [[NSUserDefaults standardUserDefaults] setObject:tasks forKey:@"tasks"];
    NSData *toDoLists = [NSKeyedArchiver archivedDataWithRootObject:self.toDoListArray];
    [[NSUserDefaults standardUserDefaults] setObject:toDoLists forKey:@"toDoLists"];
}

- (void)loadData {
    NSData *tasks = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];
    NSArray *arrayTasks = [NSKeyedUnarchiver unarchiveObjectWithData:tasks];
    for (VAKTask *task in arrayTasks) {
        [self addTask:task];
    }
    NSData *toDoLists = [[NSUserDefaults standardUserDefaults] objectForKey:@"toDoLists"];
    NSArray *arrayToDoLists = [NSKeyedUnarchiver unarchiveObjectWithData:toDoLists];
    NSMutableArray *currentArrayToDoLists = (NSMutableArray *)self.toDoListArray;
    for (VAKToDoList *toDoList in arrayToDoLists) {
        [currentArrayToDoLists addObject:toDoList];
        
    }
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    VAKTask *currentTask = notification.userInfo[VAKCurrentTask];
    if (notification.userInfo[VAKDetailTaskWasChanged]) {
        NSString *lastDate = notification.userInfo[VAKLastDate];
        NSString *newDate = [NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
        if (![lastDate isEqualToString:newDate]) {
            [self updateTask:currentTask lastDate:lastDate newDate:newDate];
            [self saveData];
        }
    }
    else if (notification.userInfo[VAKAddNewTask]) {
        VAKTask *newTask = notification.userInfo[VAKCurrentTask];
        if (![self.tasks containsObject:currentTask]) {
            [self addTask:newTask];
            [self saveData];
        }
    }
    else if (notification.userInfo[VAKDoneTask]) {
        [self updateTaskForCompleted:currentTask];
        [self saveData];
    }
    else if (notification.userInfo[VAKDeleteTask]) {
        if ([self.tasks containsObject:currentTask]) {
            [self removeTaskById:currentTask.taskId];
            [self saveData];
        }
    }
}

#pragma mark - lazy getters

- (NSArray *)toDoListArray {
    if (!_privateToDoListArray) {
        _privateToDoListArray = [[NSMutableArray alloc] init];
    }
    return _privateToDoListArray;
}

- (void)setToDoListArray:(NSArray *)toDoListArray {
    _privateToDoListArray = (NSMutableArray *)toDoListArray;
}

- (NSArray *)tasks {
    if (!_privateTasksArray) {
        _privateTasksArray = [[NSMutableArray alloc]init];
    }
    return _privateTasksArray;
}

- (NSDictionary *)dictionaryDate {
    if (!_privateDictionaryDate) {
        _privateDictionaryDate = [NSMutableDictionary dictionary];
    }
    return _privateDictionaryDate;
}

- (NSDictionary *)dictionaryCompletedOrNotCompletedTasks {
    if (!_dictionaryCompletedOrNotCompletedTasks) {
        _dictionaryCompletedOrNotCompletedTasks = [NSDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], VAKCompletedTask, [NSMutableArray array], VAKNotCompletedTask, nil];
    }
    return _dictionaryCompletedOrNotCompletedTasks;
}

#pragma mark - work on tasks

- (VAKTask *)taskById:(NSNumber *)taskId {
    for (int i = 0; i < self.tasks.count; i++) {
        VAKTask *task = self.tasks[i];
        if ([task.taskId isEqualToNumber:taskId]) {
            return task;
        }
    }
    return nil;
}

- (void)addTask:(VAKTask *)task {
    NSMutableArray *arrayTasks = (NSMutableArray *)self.tasks;
    [arrayTasks addObject:task];
    if (task.remindMeOnADay) {
        [self remind:task];
    }

    NSString *currentDate = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
    
    if (task.isCompleted) {
        NSMutableArray *arrayCompletedTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKCompletedTask];
        [arrayCompletedTasks addObject:task];
    }
    else {
        NSMutableArray *arrayNotCompletedTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKNotCompletedTask];
        [arrayNotCompletedTasks addObject:task];
    }
    
    if (self.dictionaryDate[currentDate] == nil) {
        NSMutableDictionary *dictionaryDate = (NSMutableDictionary *)self.dictionaryDate;
        [dictionaryDate setObject:[[NSMutableArray alloc] init] forKey:currentDate];
        NSMutableArray *tempArrayDate = self.dictionaryDate[currentDate];
        [tempArrayDate addObject:task];
    }
    else {
        NSMutableArray *tempArrayDate = self.dictionaryDate[currentDate];
        [tempArrayDate addObject:task];
    }
    
    [self sortArrayKeysDate:self.isReverseOrdered];
    [self sortArrayKeysGroup:self.isReverseOrdered];
}

- (void)removeTaskById:(NSNumber *)taskId {

    for (VAKTask *task in self.tasks) {
        if ([task.taskId isEqualToNumber:taskId]) {
            if (task.remindMeOnADay) {
                [self deleteRemind:task];
            }
            NSString *currentDate = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
            NSMutableArray *arrayTasks = (NSMutableArray *)self.tasks;
            [arrayTasks removeObject:task];
            NSMutableArray *arrayDate = self.dictionaryDate[currentDate];
            if (task.isCompleted) {
                NSMutableArray *arrayCompletedTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKCompletedTask];
                [arrayCompletedTasks removeObject:task];
            }
            else {
                NSMutableArray *arrayNotCompletedTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKNotCompletedTask];
                [arrayNotCompletedTasks removeObject:task];
            }
            [arrayDate removeObject:task];
            if ([arrayDate count] == 0) {
                NSMutableDictionary *dictionaryDate = (NSMutableDictionary *)self.dictionaryDate;
                [dictionaryDate removeObjectForKey:currentDate];
                [self sortArrayKeysDate:self.isReverseOrdered];
            }
            return;
        }
    }
}

- (void)updateTask:(VAKTask *)task lastDate:(NSString *)lastDate newDate:(NSString *)newDate {
    
    NSMutableArray *arrayDate = self.dictionaryDate[lastDate];
    [arrayDate removeObject:task];
    if ([arrayDate count] == 0) {
        NSMutableDictionary *dictionaryDate = (NSMutableDictionary *)self.dictionaryDate;
        [dictionaryDate removeObjectForKey:lastDate];
    }
    arrayDate = self.dictionaryDate[newDate];
    if (arrayDate == nil) {
        arrayDate = [[NSMutableArray alloc] initWithObjects:task, nil];
    }
    else {
        [arrayDate addObject:task];
    }
    NSMutableDictionary *dictionaryDate = (NSMutableDictionary *)self.dictionaryDate;
    [dictionaryDate setObject:arrayDate forKey:newDate];
    [self sortArrayKeysDate:self.isReverseOrdered];
}

- (void)updateTaskForCompleted:(VAKTask *)task {
    NSMutableArray *arrayTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKNotCompletedTask];
    if ([arrayTasks containsObject:task]) {
        task.completed = YES;
        task.finishedAt = [NSDate date];
        [arrayTasks removeObject:task];
        arrayTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKCompletedTask];
        [arrayTasks addObject:task];
    }
}

//Добавление новой группы ToDoList
- (void)addGroup:(NSString *)groupName {
    //если группа найдена, значит выходим и ничего не добавляем
    for (VAKToDoList *item in self.toDoListArray) {
        if ([item.toDoListName isEqualToString:groupName]) {
            return;
        }
    }
    //если группа не найдена, создаем и добавляем в массив групп
    VAKToDoList *newGroup = [[VAKToDoList alloc] initWithName:groupName];
    NSMutableArray *arrayGroups = (NSMutableArray *)self.toDoListArray;
    [arrayGroups addObject:newGroup];
}

- (void)sortArrayKeysGroup:(BOOL)isReverseOrder {
    self.reverseOrdered = isReverseOrder;
    NSArray *sortedArray = [self.toDoListArray sortedArrayUsingComparator:^NSComparisonResult(VAKToDoList *obj1, VAKToDoList *obj2) {
        if (isReverseOrder) {
            return -[obj1.toDoListName compare:obj2.toDoListName];
        }
        else {
            return [obj1.toDoListName compare:obj2.toDoListName];
        }
    }];
    self.toDoListArray = [NSMutableArray arrayWithArray:sortedArray];
}

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
    for (int i = 0; i < [arrayKeysDate count]; i++) {
        NSMutableArray *arrayTasksCurrentDay = self.dictionaryDate[arrayKeysDate[i]];
        [arrayTasksCurrentDay sortUsingComparator:^NSComparisonResult(VAKTask *obj1, VAKTask *obj2) {
            if (self.isReverseOrdered) {
                return -[obj1.startedAt compare:obj2.startedAt];
            }
            else {
                return [obj1.startedAt compare:obj2.startedAt];
            }
        }];
    }
    self.arrayKeysDate = arrayKeysDate;
}

#pragma mark - remind task

- (void)remindMeOnADay:(NSNotification *)notification {
    if (notification.userInfo[@"remind"]) {
        [self remind:notification.userInfo[@"task"]];
    }
    else if (notification.userInfo[@"delete"]) {
        [self deleteRemind:notification.userInfo[@"task"]];
    }
    else {
        [self updateDateRemind:notification.userInfo[@"task"]];
    }
}

- (void)remind:(VAKTask *)task {
    NSString *eventInfo = [NSString stringWithFormat:@"Name: %@ and notes: %@", task.taskName, task.notes];
    NSString *eventDate = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithHourAndMinute];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:eventInfo, @"eventInfo", eventDate, @"eventDate", task.taskId, @"taskId", nil];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.userInfo = dic;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.fireDate = task.startedAt;
    notification.alertBody = eventInfo;
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)deleteRemind:(VAKTask *)task {
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        if ([notification.userInfo[@"taskId"] isEqualToNumber:task.taskId]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (void)updateDateRemind:(VAKTask *)task {
    [self deleteRemind:task];
    [self remind:task];
}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
