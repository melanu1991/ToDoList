#import <Foundation/Foundation.h>

@protocol VAKFinishedTaskDelegate <NSObject>

- (void)finishedTaskById:(NSString *)taskId finishedDate:(NSDate *)date;

@end
