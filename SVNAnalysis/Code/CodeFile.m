//
//  CodeFile.m
//  SVNAnalysis
//
//  Created by lolzorz on 15/9/22.
//  Copyright © 2015年 lolzorz.me. All rights reserved.
//

#import "CodeFile.h"
#import "CodeManager.h"

@implementation CodeFile

- (instancetype)init {
    if(self = [super init]) {
        self.refs = [[NSMutableArray alloc] init];
        self.histories = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (CodeFile *)codeFileNamed:(NSString *)name {
    CodeFile *result = [CodeManager sharedInstance].allFiles[name];
    if(!result) {
        result = [[CodeFile alloc] init];
        result.fileName = name;
        [CodeManager sharedInstance].allFiles[name] = result;
    }
    return result;
}

@end
