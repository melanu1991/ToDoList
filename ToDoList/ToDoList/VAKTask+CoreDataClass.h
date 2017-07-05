#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VAKTask : NSManagedObject

@property (nullable, nonatomic, copy) NSString *taskName;
@property (nullable, nonatomic, copy) NSString *taskId;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSDate *startedAt;
@property (nullable, nonatomic, copy) NSDate *finishedAt;
@property (nullable, nonatomic, copy) NSString *priority;
@property (nonatomic) BOOL remindMeOnADay;
@property (nonatomic) BOOL completed;
@property (nullable, nonatomic, copy) NSString *currentGroup;

@end
