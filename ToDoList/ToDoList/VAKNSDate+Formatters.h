#import <Foundation/Foundation.h>

@interface NSDate (VAKDateFormatters)

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;
+ (NSString *)dateStringFromDate:(NSDate *)dateString format:(NSString *)format;

@end
