//
//  NSString+Util.h
//  SVNAnalysis
//
//  Created by 徐家翀 on 9/3/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

- (NSString *)stringBeforeComponent:(NSString *)component;
- (NSString *)stringAfterComponent:(NSString *)component;
- (NSString *)trim;

@end
