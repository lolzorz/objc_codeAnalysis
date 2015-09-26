//
//  main.m
//  SVNAnalysis
//
//  Created by 徐家翀 on 8/31/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeReader.h"
#import "FileReader.h"
#import "NSString+Util.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if(argc < 2) {
            printf("Invaild input");
            return -1;
        }
        char buf[800];
        getcwd(buf, sizeof(buf));
        NSString *path = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
        [FileReader readPath:path];
        const char *aArgCString = argv[1];
        NSString *aArg = [NSString stringWithCString:aArgCString encoding:NSUTF8StringEncoding];
        if([aArg hasPrefix:@"-l"]) {
            NSInteger num = [[aArg stringAfterComponent:@"-l"] longLongValue];
            [CodeReader readLogCount:num atPath:path];
        } else if([aArg hasPrefix:@"-r"]) {
            [CodeReader readLogReversion:aArg atPath:path];
        }
    }
    return 0;
}
