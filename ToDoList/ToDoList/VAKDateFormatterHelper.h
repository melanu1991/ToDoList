#import <Foundation/Foundation.h>

@interface VAKDateFormatterHelper : NSDateFormatter

+ (id)sharedDateFormatter;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end
