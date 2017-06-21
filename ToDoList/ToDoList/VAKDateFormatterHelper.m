#import "VAKDateFormatterHelper.h"

@implementation VAKDateFormatterHelper

+ (id)sharedDateFormatter {
    static VAKDateFormatterHelper *sharedDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDateFormatter = [[self alloc] init];
    });
    return sharedDateFormatter;
}

- (id)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return self;
}

@end
