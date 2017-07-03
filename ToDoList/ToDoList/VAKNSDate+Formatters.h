#import <Foundation/Foundation.h>

@interface NSDate (VAKDateFormatters)

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;
+ (NSString *)dateStringFromDate:(NSDate *)date format:(NSString *)format;

@end
