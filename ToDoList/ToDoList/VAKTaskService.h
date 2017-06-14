#import <Foundation/Foundation.h>
#import "VAKTask.h"

@interface VAKTaskService : NSObject

@property (strong, nonatomic) NSMutableArray *tasks;
@property (strong, nonatomic) NSMutableArray *groupCompletedTasks;
@property (strong, nonatomic) NSMutableArray *groupNotCompletedTasks;
@property (strong, nonatomic) NSMutableDictionary *dictionaryDate;
@property (strong, nonatomic) NSMutableDictionary *dictionaryGroup;
@property (strong, nonatomic) NSArray *arrayKeysDate;
@property (strong, nonatomic) NSArray *arrayKeysGroup;

- (VAKTask *)taskById:(NSString *)taskId;
- (void)addTask:(VAKTask *)task;
- (void)addGroup:(NSString *)group;
- (void)removeTaskById:(NSString *)taskId;
- (void)updateTask:(VAKTask *)task;

- (void)sortArrayKeysGroup;
- (void)sortArrayKeysDate;

+ (instancetype)initDefaultTaskService;

@end
