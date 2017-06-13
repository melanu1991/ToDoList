#import <Foundation/Foundation.h>

@interface VAKTask : NSObject

@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *taskName;
@property (nonatomic, strong) NSDate *startedAt;
@property (nonatomic, strong) NSDate *finishedAt;
@property (nonatomic, copy) NSString *notes;
@property (copy, nonatomic) NSString *priority;
@property (assign, nonatomic, getter=isRemindMeOnADay) BOOL remindMeOnADay;
@property (nonatomic, assign, getter=isCompleted) BOOL completed;
@property (copy, nonatomic) NSString *currentGroup;

- (instancetype)initTaskWithId:(NSString *)taskId taskName:(NSString *)taskName;

@end
