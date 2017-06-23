#import <Foundation/Foundation.h>

@interface VAKTask : NSObject

@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *taskName;
@property (nonatomic, strong) NSDate *startedAt;
@property (nonatomic, strong) NSDate *finishedAt;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, assign, getter=isCompleted) BOOL completed;

- (instancetype)initTaskWithId:(NSString *)taskId taskName:(NSString *)taskName;

@end
