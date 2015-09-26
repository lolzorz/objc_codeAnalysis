//
//  FileReader.m
//  SVNAnalysis
//
//  Created by lolzorz on 15/9/22.
//  Copyright © 2015年 lolzorz.me. All rights reserved.
//

#import "FileReader.h"
#import "CodeFile.h"
#import "NSString+Util.h"
#import "CodeManager.h"

@implementation FileReader

+ (void)testRead {
//    [self readPath:BASE_PATH];
}

+ (void)readPath:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:path error:nil];
    for(NSString *name in files) {
        NSString *aPath = [path stringByAppendingPathComponent:name];
        BOOL isDirectory = YES;
        [fileManager fileExistsAtPath:aPath isDirectory:&isDirectory];
        if(isDirectory) {
            [self readPath:aPath];
        } else {
            NSString *ext = [[aPath lastPathComponent] pathExtension];
            if([ext isEqualToString:@"m"] || [ext isEqualToString:@"h"]) {
                [self readFileAtPath:aPath];
            }
        }
    }
}

+ (void)readFileAtPath:(NSString *)path {
    NSString *name = [path lastPathComponent];
    name = [name stringByDeletingPathExtension];
    CodeFile *codeFile = [CodeFile codeFileNamed:name];
    codeFile.filePath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"m"];
    
    NSString *fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    for(NSInteger i = 0; i < lines.count; i++) {
        NSString *aLine = [lines[i] trim];
        if([aLine hasPrefix:@"#import"]) {
            aLine = [[aLine stringAfterComponent:@"#import"] trim];
            if([aLine hasPrefix:@"\""]) {
                aLine = [aLine stringAfterComponent:@"\""];
                if([aLine hasSuffix:@"\""]) {
                    aLine = [aLine stringBeforeComponent:@"\""];
                    aLine = [aLine stringByDeletingPathExtension];
                    CodeFile *aCodeFile = [CodeFile codeFileNamed:aLine];
                    [aCodeFile.refs addObject:name];
                }
            }
        }
    }
}

@end
