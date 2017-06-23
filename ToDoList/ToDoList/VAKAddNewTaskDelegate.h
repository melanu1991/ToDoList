#import <Foundation/Foundation.h>

@class VAKTask;
@protocol VAKAddNewTaskDelegate <NSObject>

- (void)addNewTaskWithTask:(VAKTask *)task;

@end
