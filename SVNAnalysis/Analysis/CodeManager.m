//
//  CodeManager.m
//  SVNAnalysis
//
//  Created by 徐家翀 on 9/3/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import "CodeManager.h"

@implementation CodeManager

+ (CodeManager *)sharedInstance {
    static CodeManager *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[CodeManager alloc] init];
    });
    return instance;
}

@end
