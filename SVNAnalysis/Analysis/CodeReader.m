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
#import <objc/runtime.h>

@implementation CodeReader

+ (void)testRead {
    [self analysisDefineWithPath:@"/Users/xujiachong/Documents/VerifyPhoneView.h"];
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
    [self analysisDefine:fileContent isHeader:isHeader];
}

+ (void)analysisCodeWithPath:(NSString *)path {
    NSString *fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *extension = [path pathExtension];
    if(![extension isEqualToString:@"m"]) {
        return;
    }
    [self analysisCode:fileContent];
}


+ (void)analysisDefine:(NSString *)file isHeader:(BOOL)isHeader {
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
