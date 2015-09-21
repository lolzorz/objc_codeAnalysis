//
//  CodeClass.m
//  SVNAnalysis
//
//  Created by 徐家翀 on 8/31/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import "CodeClass.h"
#import "CodeManager.h"

@implementation CodeClass

+ (CodeClass *)codeClassNamed:(NSString *)name {
    CodeClass *instance = [CodeManager sharedInstance].allClasses[name];
    if(!instance) {
        instance = [[CodeClass alloc] init];
        instance.className = name;
        [CodeManager sharedInstance].allClasses[name] = instance;
    }
    return instance;
}

@end
