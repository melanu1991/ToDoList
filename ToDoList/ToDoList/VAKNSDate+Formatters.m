#import "VAKNSDate+Formatters.h"

@implementation NSDate (VAKDateFormatters)

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    if (!dateString || !format) {
        return nil;
    }
    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateFormat = format;
    return [formatter dateFromString:dateString];
}

+ (NSString *)dateStringFromDate:(NSDate *)dateString format:(NSString *)format {
    if (!dateString || !format) {
        return nil;
    }
    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateFormat = format;
    return [formatter stringFromDate:dateString];
}

@end
