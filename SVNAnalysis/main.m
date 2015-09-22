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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [FileReader testRead];
        [CodeReader testRead];
    }
    return 0;
}
