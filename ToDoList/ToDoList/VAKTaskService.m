#import "VAKTaskService.h"
#import "VAKAddTaskController.h"
#import "Constants.h"
#import "VAKCoreDataManager.h"

@interface VAKTaskService ()

@property (assign, nonatomic, getter=isReverseOrdered) BOOL reverseOrdered;
@property (strong, nonatomic) VAKAddTaskController *addTaskController;

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
//        [self loadArrayTasks];
        NSArray *arrayTasks = [[VAKCoreDataManager sharedManager] loadTasks];
        if (!self.tasks) {
            self.tasks = [NSMutableArray array];
        }
        else {
            for (VAKTask *task in arrayTasks) {
                [self addTask:task];
            }
        }
        self.addTaskController = [[VAKAddTaskController alloc] init];
    }
    
    [self sortArrayKeysGroup:self.isReverseOrdered];
    [self sortArrayKeysDate:self.isReverseOrdered];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskWasChangedOrAddOrDelete:) name:VAKTaskWasChangedOrAddOrDelete object:nil];
    
    return self;
}

#pragma mark - Notification

- (void)taskWasChangedOrAddOrDelete:(NSNotification *)notification {
    VAKTask *currentTask = notification.userInfo[VAKCurrentTask];
    if (notification.userInfo[VAKDetailTaskWasChanged]) {
        NSString *lastDate = notification.userInfo[VAKLastDate];
        NSString *newDate = [NSDate dateStringFromDate:currentTask.startedAt format:VAKDateFormatWithoutHourAndMinute];
        if (![lastDate isEqualToString:newDate]) {
            [self updateTask:currentTask lastDate:lastDate newDate:newDate];
        }
    }
    else if (notification.userInfo[VAKAddNewTask]) {
        if (![self.tasks containsObject:currentTask]) {
            [self addTask:currentTask];
        }
    }
    else if (notification.userInfo[VAKDoneTask]) {
        [self updateTaskForCompleted:currentTask];
    }
    else if (notification.userInfo[VAKDeleteTask]) {
        if ([self.tasks containsObject:currentTask]) {
            [self removeTaskById:currentTask.taskId];
        }
    }
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

- (NSDictionary *)dictionaryCompletedOrNotCompletedTasks {
    if (!_dictionaryCompletedOrNotCompletedTasks) {
        _dictionaryCompletedOrNotCompletedTasks = [NSDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], VAKCompletedTask, [NSMutableArray array], VAKNotCompletedTask, nil];
    }
    return _dictionaryCompletedOrNotCompletedTasks;
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
//    [[VAKCoreDataManager sharedManager] addTaskToCoreData:task];
    if (task.remindMeOnADay) {
        [self.addTaskController remind:task];
    }

    NSString *currentDate = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
    NSString *currentGroup = task.currentGroup;
    
    if (task.isCompleted) {
        NSMutableArray *arrayCompletedTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKCompletedTask];
        [arrayCompletedTasks addObject:task];
    }
    else {
        NSMutableArray *arrayNotCompletedTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKNotCompletedTask];
        [arrayNotCompletedTasks addObject:task];
    }
    
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
    
    [self sortArrayKeysDate:NO];
    [self sortArrayKeysGroup:NO];
    
//    [self saveArrayTasks];
}

- (void)removeTaskById:(NSString *)taskId {

    for (VAKTask *task in self.tasks) {
//        [[VAKCoreDataManager sharedManager] removeTaskById:taskId];
        if ([task.taskId isEqualToString:taskId]) {
            if (task.remindMeOnADay) {
                [self.addTaskController deleteRemind:task];
            }
            NSString *currentDate = [NSDate dateStringFromDate:task.startedAt format:VAKDateFormatWithoutHourAndMinute];
            [self.tasks removeObject:task];
            NSMutableArray *arrayDate = self.dictionaryDate[currentDate];
            NSMutableArray *arrayGroup = self.dictionaryGroup[task.currentGroup];
            if (task.isCompleted) {
                NSMutableArray *arrayCompletedTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKCompletedTask];
                [arrayCompletedTasks removeObject:task];
            }
            else {
                NSMutableArray *arrayNotCompletedTasks = self.dictionaryCompletedOrNotCompletedTasks[VAKNotCompletedTask];
                [arrayNotCompletedTasks removeObject:task];
            }
            [arrayDate removeObject:task];
            [arrayGroup removeObject:task];
            if ([arrayDate count] == 0) {
                [self.dictionaryDate removeObjectForKey:currentDate];
                [self sortArrayKeysDate:self.isReverseOrdered];
            }
//            [self saveArrayTasks];
            return;
        }
    }
}

- (void)updateTask:(VAKTask *)task lastDate:(NSString *)lastDate newDate:(NSString *)newDate {
    
    NSMutableArray *arrayDate = self.dictionaryDate[lastDate];
    [arrayDate removeObject:task];
    if ([arrayDate count] == 0) {
        [self.dictionaryDate removeObjectForKey:lastDate];
    }
    arrayDate = self.dictionaryDate[newDate];
    if (arrayDate == nil) {
        arrayDate = [[NSMutableArray alloc] initWithObjects:task, nil];
    }
    else {
        [arrayDate addObject:task];
    }
    [self.dictionaryDate setObject:arrayDate forKey:newDate];
    [self sortArrayKeysDate:self.isReverseOrdered];

//    [self saveArrayTasks];
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
//    [self saveArrayTasks];
}

- (void)addGroup:(NSString *)group {
    if (self.dictionaryGroup[group] == nil) {
        [self.dictionaryGroup setObject:[[NSMutableArray alloc] init] forKey:group];
        [self sortArrayKeysGroup:NO];
    }
}

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

//#pragma mark - save and load array tasks
//
//- (void)saveArrayTasks {
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.tasks];
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"tasks"];
//}
//
//- (void)loadArrayTasks {
//    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"tasks"];
//    NSMutableArray *arrayTasks = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    for (VAKTask *task in arrayTasks) {
//        [self addTask:task];
//    }
//}

#pragma mark - deallocate

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
