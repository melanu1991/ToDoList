#import "VAKNSDate+Formatters.h"

@implementation NSDate (VAKDateFormatters)

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    if (!dateString || !format) {
        return nil;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setLocale:[NSLocale currentLocale]];
    [dateFormat setDateFormat:format];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDate *date = [dateFormat dateFromString:dateString];
    return date;
}

+ (NSString *)dateStringFromDate:(NSDate *)dateString format:(NSString *)format {
    if (!dateString || !format) {
        return nil;
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setLocale:[NSLocale currentLocale]];
    [dateFormat setDateFormat:format];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSString *date = [dateFormat stringFromDate:dateString];
    return date;
//    NSDateFormatter *formatter = NSDateFormatter.new;
//    formatter.dateFormat = format;
//    return [formatter stringFromDate:dateString];
}

@end
