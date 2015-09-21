//
//  NSString+Util.m
//  SVNAnalysis
//
//  Created by 徐家翀 on 9/3/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import "NSString+Util.h"

@implementation NSString (Util)

- (NSString *)stringBeforeComponent:(NSString *)component {
    NSRange range = [self rangeOfString:component];
    return [self substringToIndex:range.location];
}

- (NSString *)stringAfterComponent:(NSString *)component {
    NSRange range = [self rangeOfString:component];
    return [self substringFromIndex:(range.location + range.length)];
}

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
