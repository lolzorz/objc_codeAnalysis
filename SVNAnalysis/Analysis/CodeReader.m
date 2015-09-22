//
//  CodeReader.m
//  SVNAnalysis
//
//  Created by 徐家翀 on 9/3/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import "CodeReader.h"
#import "NSString+Util.h"
#import "CodeClass.h"
#import "CodeMethod.h"
#import "CodeManager.h"
#import "CodeFile.h"

@implementation CodeReader

+ (void)testRead {
    NSString *testFile = [BASE_PATH stringByAppendingPathComponent:@"FMActionManager.m"];
    [self findOutModifyInPath:testFile atLine:500];
}

+ (void)findOutModifyInPath:(NSString *)file atLine:(NSInteger)line {
    NSString *fileContent = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    NSString *methodName = [self methodInLines:lines atLine:line];
    NSString *fileName = [file lastPathComponent];
    fileName = [fileName stringByDeletingPathExtension];
    CodeManager *codeManager = [CodeManager sharedInstance];
    NSMutableDictionary *allFiles = codeManager.allFiles;
    NSMutableArray *refs = [[NSMutableArray alloc] init];
    NSMutableArray *aRef = ((CodeFile *)allFiles[fileName]).refs;
    for(NSString *name in aRef) {
        CodeMethod *aMethod = [[CodeMethod alloc] init];
        aMethod.methodFile = allFiles[name];
        aMethod.methodName = methodName;
        [refs addObject:aMethod];
    }
    while(refs.count) {
        NSMutableArray *aArr = [refs mutableCopy];
        [refs removeAllObjects];
        for(CodeMethod *aMethod in aArr) {
            CodeFile *aCodeFile = aMethod.methodFile;
            if(aCodeFile.filePath.length) {
                NSString *aFileContent = [NSString stringWithContentsOfFile:aCodeFile.filePath encoding:NSUTF8StringEncoding error:nil];
                
                
                
            }
        }
    }
}

+ (void)analysisDefineWithPath:(NSString *)path {
    NSString *fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    BOOL isHeader = NO;
    NSString *extension = [path pathExtension];
    if([extension isEqualToString:@"m"]) {
        isHeader = NO;
    } else if([extension isEqualToString:@"h"]) {
        isHeader = YES;
    } else {
        return;
    }
    //    [self analysisDefine:fileContent isHeader:isHeader];
}

+ (void)analysisCodeWithPath:(NSString *)path {
    NSString *fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *extension = [path pathExtension];
    if(![extension isEqualToString:@"m"]) {
        return;
    }
    [self analysisCode:fileContent];
}

+ (NSString *)methodInLines:(NSArray *)lines atLine:(NSInteger)line {
    line--;
    NSInteger startLine = line;
    for(startLine = line; startLine >= 0; startLine--) {
        NSString *aLine = lines[startLine];
        aLine = [aLine trim];
        if([aLine hasPrefix:@"+"] || [aLine hasPrefix:@"-"]) {
            break;
        }
    }
    NSString *resultMethod = @"";
    while(YES) {
        NSString *aLine = lines[startLine];
        aLine = [aLine trim];
        BOOL shouldBreak = [aLine containsString:@"{"];
        if(shouldBreak) {
            aLine = [[aLine stringBeforeComponent:@"{"] trim];
        }
        NSArray *sections = [aLine componentsSeparatedByString:@":"];
        BOOL haveParameters = [aLine containsString:@":"];
        for(NSInteger i = 0; i < sections.count; i++) {
            NSString *aSection = sections[i];
            NSString *aBody = [[[aSection componentsSeparatedByString:@")"] lastObject] trim];
            if(![aBody containsString:@" "] && i != 0) {
                break;
            }
            aBody = [[[aBody componentsSeparatedByString:@" "] lastObject] trim];
            resultMethod = [resultMethod stringByAppendingString:aBody];
            if(haveParameters) {
                resultMethod = [resultMethod stringByAppendingString:@":"];
            }
        }
        
        if(shouldBreak) {
            break;
        }
        startLine++;
    }
    CodeMethod *cm = [[CodeMethod alloc] init];
//    cm.methodName = resultMethod;
//    cm.methodClass = [self classInLines:lines atLine:line];
    return resultMethod;
}

+ (CodeClass *)classInLines:(NSArray *)lines atLine:(NSInteger)line {
    line--;
    NSInteger startLine = line;
    for(startLine = line; startLine >= 0; startLine--) {
        NSString *aLine = lines[startLine];
        aLine = [aLine trim];
        if([aLine hasPrefix:@"@implementation"]) {
            break;
        }
    }
    NSString *aLine = lines[startLine];
    aLine = [aLine trim];
    NSString *className = [[aLine stringAfterComponent:@"@implementation"] trim];
    if([className containsString:@"<"]) {
        className = [[className stringBeforeComponent:@"<"] trim];
    }
    return [CodeClass codeClassNamed:className];
}

+ (void)analysisDefine:(NSString *)file
              isHeader:(BOOL)isHeader {
    NSArray *lines = [file componentsSeparatedByString:@"\n"];
    BOOL inMarking = NO;
    BOOL inDefine = NO;
    CodeClass *currentClass;
    for(NSInteger i = 0; i < lines.count; i++) {
        NSString *aLine = lines[i];
        aLine = [aLine trim];
        if(aLine.length < 1) {
            continue;
        }
        
        //进行注释的去除
        if(inMarking) {
            if([aLine containsString:@"*/"]) {
                aLine = [aLine stringAfterComponent:@"*/"];
                inMarking = NO;
            } else {
                continue;
            }
        }
        if([aLine containsString:@"/*"]) {
            aLine = [aLine stringBeforeComponent:@"/*"];
            inMarking = YES;
        }
        if([aLine containsString:@"//"]) {
            aLine = [aLine stringBeforeComponent:@"//"];
        }
        if(aLine.length < 1) {
            continue;
        }
        
        //按照正常的语法，aLine已经是有效代码了
        //这里要进行语句的分析
        //这里不用正则的原因是因为项目文件很多很大的话  每一行都用正则会导致效率降低
        //这里就不进行C/C++的面向过程函数的分析了
        
        //@interface
        if([aLine hasPrefix:@"@interface"]) {
            NSString *className = [[aLine stringAfterComponent:@"@interface"] trim];
            NSString *superName = nil;
            //@interface example : NSObject
            if(isHeader && [className containsString:@":"]) {
                superName = [[className stringAfterComponent:@":"] trim];
                className = [[className stringBeforeComponent:@":"] trim];
            }
            //@interface NSObject(example)
            //@interface example () {
            if([className containsString:@"("]) {
                className = [[className stringBeforeComponent:@"("] trim];
            }
            currentClass = [CodeClass codeClassNamed:className];
            if(superName) {
                //@interface example : NSObject {
                if([superName containsString:@"{"]) {
                    superName = [[superName stringBeforeComponent:@"{"] trim];
                }
                //@interface example : NSObject <NSCacheDelegate> {
                if([superName containsString:@"<"]) {
                    superName = [[superName stringBeforeComponent:@"<"] trim];
                }
                currentClass.superClass = [CodeClass codeClassNamed:superName];
            }
        }
    }
}

+ (void)analysisCode:(NSString *)file {
    NSArray *lines = [file componentsSeparatedByString:@"\n"];
    BOOL inMarking = NO;
    BOOL inDefine = NO;
    for(NSInteger i = 0; i < lines.count; i++) {
        NSString *aLine = lines[i];
        if(aLine.length < 1) {
            continue;
        }
        
        if(inMarking) {
            if([aLine containsString:@"*/"]) {
                aLine = [aLine stringAfterComponent:@"*/"];
                inMarking = NO;
            } else {
                continue;
            }
        }
        if([aLine containsString:@"/*"]) {
            aLine = [aLine stringBeforeComponent:@"/*"];
            inMarking = YES;
        }
        if([aLine containsString:@"//"]) {
            aLine = [aLine stringBeforeComponent:@"//"];
        }
        if(aLine.length < 1) {
            continue;
        }
        
        if([aLine containsString:@"@interface"]) {
            
        }
    }
}

@end
