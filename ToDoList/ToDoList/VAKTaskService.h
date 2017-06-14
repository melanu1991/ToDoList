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
- (void)removeTaskById:(NSString *)taskId;
- (void)updateTask:(VAKTask *)task;
- (void)sortArrayKeys;

+ (instancetype)initDefaultTaskService;

@end
