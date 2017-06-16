#import <Foundation/Foundation.h>
#import "VAKTask.h"

@interface VAKTaskService : NSObject

@property (strong, nonatomic) NSMutableArray *tasks;
@property (strong, nonatomic) NSMutableDictionary *dictionaryDate;
@property (strong, nonatomic) NSMutableDictionary *dictionaryGroup;
@property (strong, nonatomic) NSDictionary *dictionaryCompletedOrNotCompletedTasks;
@property (strong, nonatomic) NSArray *arrayKeysDate;
@property (strong, nonatomic) NSArray *arrayKeysGroup;

- (VAKTask *)taskById:(NSString *)taskId;
- (void)addTask:(VAKTask *)task;
- (void)addGroup:(NSString *)group;
- (void)removeTaskById:(NSString *)taskId;
- (void)updateTask:(VAKTask *)task lastDate:(NSString *)lastDate;
- (void)updateTaskForCompleted:(VAKTask *)task;

- (void)sortArrayKeysGroup:(BOOL)isReverseOrder;
- (void)sortArrayKeysDate:(BOOL)isReverseOrder;

+ (VAKTaskService *)sharedVAKTaskService;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end
