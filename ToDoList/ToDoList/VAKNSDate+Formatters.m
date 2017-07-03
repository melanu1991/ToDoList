#import "VAKNSDate+Formatters.h"

@implementation NSDate (VAKDateFormatters)

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    if (!dateString || !format) {
        return nil;
    }
    NSString *ft = [NSDateFormatter dateFormatFromTemplate:format options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateFormat = ft;
    NSDate *date = [formatter dateFromString:dateString];
    return date;
}

+ (NSString *)dateStringFromDate:(NSDate *)date format:(NSString *)format {
    if (!date || !format) {
        return nil;
    }
    NSString *ft = [NSDateFormatter dateFormatFromTemplate:format options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateFormat = ft;
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
