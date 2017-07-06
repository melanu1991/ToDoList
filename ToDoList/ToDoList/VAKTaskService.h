#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VAKTask.h"
#import "VAKNSDate+Formatters.h"
#import "Constants.h"

@interface VAKTaskService : NSObject

@property (strong, nonatomic) NSArray *tasks;
@property (strong, nonatomic) NSDictionary *dictionaryDate;
@property (strong, nonatomic) NSDictionary *dictionaryCompletedOrNotCompletedTasks;
@property (strong, nonatomic) NSArray *arrayKeysDate;
@property (strong, nonatomic) NSArray *toDoListArray;

+ (VAKTaskService *)sharedVAKTaskService;

- (VAKTask *)taskById:(NSNumber *)taskId;
- (void)addTask:(VAKTask *)task;
- (void)addGroup:(NSString *)groupName;
- (void)removeTaskById:(NSNumber *)taskId;
- (void)updateTask:(VAKTask *)task lastDate:(NSString *)lastDate newDate:(NSString *)newDate;
- (void)updateTaskForCompleted:(VAKTask *)task;

- (void)sortArrayKeysDate:(BOOL)isReverseOrder;
- (void)sortArrayKeysGroup:(BOOL)isReverseOrder;

- (void)loadData;
- (void)saveData;

@end
