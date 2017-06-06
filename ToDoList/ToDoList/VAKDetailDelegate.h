#import <Foundation/Foundation.h>

@class VAKTask;
@protocol VAKDetailDelegate <NSObject>

- (void)detailTaskWithTask:(VAKTask *)task;

@end
