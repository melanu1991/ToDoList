#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VAKTaskCD : NSManagedObject

@property (nonatomic) BOOL completed;
@property (nullable, nonatomic, copy) NSString *currentGroup;
@property (nullable, nonatomic, copy) NSDate *finishedAt;
@property (nullable, nonatomic, copy) NSString *notes;
@property (nullable, nonatomic, copy) NSString *priority;
@property (nonatomic) BOOL remindMeOnADay;
@property (nullable, nonatomic, copy) NSDate *startedAt;
@property (nullable, nonatomic, copy) NSString *taskId;
@property (nullable, nonatomic, copy) NSString *taskName;

@end
