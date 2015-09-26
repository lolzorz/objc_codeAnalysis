//
//  CodeMethod.m
//  SVNAnalysis
//
//  Created by 徐家翀 on 8/31/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import "CodeMethod.h"

@implementation CodeMethod

- (instancetype)init {
    if(self = [super init]) {
        self.allFiles = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
