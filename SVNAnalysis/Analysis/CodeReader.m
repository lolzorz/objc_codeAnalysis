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

typedef void(^findRelatedCallback)(CodeMethod *relatedMethod);

@implementation CodeReader

+ (void)testRead {
    NSString *testFile = [BASE_PATH stringByAppendingPathComponent:@"GeneralClasses"];
    testFile = [testFile stringByAppendingPathComponent:@"Model"];
    testFile = [testFile stringByAppendingPathComponent:@"FMSplashManager.m"];
    [self findOutModifyInPath:testFile atLine:191];
}

+ (void)findOutModifyInPath:(NSString *)file atLine:(NSInteger)line {
    NSString *fileContent = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    NSString *methodName = [self methodInLines:lines atLine:line];
    NSString *fileName = [file lastPathComponent];
    fileName = [fileName stringByDeletingPathExtension];
    CodeManager *codeManager = [CodeManager sharedInstance];
    NSMutableDictionary *allFiles = codeManager.allFiles;
    __block NSMutableDictionary *refs = [[NSMutableDictionary alloc] init];
    CodeFile *aCodeFile = allFiles[fileName];
    NSMutableArray *aRef = aCodeFile.refs;
    CodeMethod *aMethod = [[CodeMethod alloc] init];
    aMethod.allFiles = aRef;
    aMethod.methodName = methodName;
    aMethod.baseFile = fileName;
    refs[methodName] = aMethod;
    while(refs.allKeys.count) {
        NSMutableDictionary *tRefs = [refs mutableCopy];
        [refs removeAllObjects];
        
        NSArray *allKeys = tRefs.allKeys;
        for(NSString *key in allKeys) {
            CodeMethod *tMethod = tRefs[key];
            
            __block NSInteger relatedCount = 0;
            NSMutableArray *methodRelatedFiles = tMethod.allFiles;
            for(NSString *tFileName in methodRelatedFiles) {
                CodeFile *tFile = [CodeFile codeFileNamed:tFileName];
                if(tFile.filePath.length) {
                    [self analysisFileAtPath:tFile.filePath methodName:tMethod.methodName callback:^(CodeMethod *relatedMethod) {
                        refs[relatedMethod.methodName] = relatedMethod;
                        relatedCount++;
                    }];
                }
            }
            if(relatedCount < 1) {
                NSLog(@"位于文件：%@，对方法：%@ 的改动，最终影响到文件：%@，方法名：%@", fileName, methodName, tMethod.baseFile, tMethod.methodName);
            }
        }
    }
}

+ (void)analysisFileAtPath:(NSString *)path methodName:(NSString *)name callback:(findRelatedCallback)cb {
    NSString *fileName = [path lastPathComponent];
    fileName = [fileName stringByDeletingPathExtension];
    NSString *fileContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
    BOOL inMarking = NO;
    
    NSArray *methodParts = [name componentsSeparatedByString:@":"];
    
    for(NSInteger lineIndex = 0; lineIndex < lines.count; lineIndex++) {
        NSString *aLine = lines[lineIndex];
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
        //这里要进行对应方法的寻找
        //这里不用正则的原因是因为。。语法太复杂..
        //这里就不进行C/C++的面向过程函数的分析了
        if([aLine containsString:methodParts[0]]) {
            if([aLine hasPrefix:@"+"] || [aLine hasPrefix:@"-"]) {
                continue;
            }
            NSString *prefex = [aLine stringBeforeComponent:methodParts[0]];
            if(![prefex containsString:@"["]) {
                continue;
            }
            //无参 直接找到
            if(methodParts.count < 2) {
                if(![[[aLine stringAfterComponent:methodParts[0]] trim] hasPrefix:@"]"]) {
                    continue;
                }
                CodeMethod *result = [[CodeMethod alloc] init];
                result.allFiles = [CodeFile codeFileNamed:fileName].refs;
                result.methodName = [self methodInLines:lines atLine:lineIndex];
                result.baseFile = fileName;
                cb(result);
            } else {
                //整合语句  直到这个方法结束(用空格代替换行，使它们都在同一行里)
                NSString *firstPart = [methodParts[0] stringByAppendingString:@":"];
                if(![aLine containsString:firstPart]) {
                    continue;
                }
                NSString *allCode = [aLine stringBeforeComponent:firstPart];
                allCode = [aLine stringAfterComponent:allCode];
                if(!allCode.length) {
                    continue;
                }
                NSInteger rightBrackets = 0;
                NSInteger leftBrackets = 0;
                NSInteger aLineIndex = lineIndex;
                NSInteger codeIndex = 0;
                while(rightBrackets + 1 != leftBrackets) {
                    BOOL shouldBreak = NO;
                    while(codeIndex < allCode.length) {
                        unichar c = [allCode characterAtIndex:codeIndex];
                        codeIndex++;
                        if(c == '[') {
                            rightBrackets++;
                            if(codeIndex >= allCode.length) {
                                allCode = [allCode stringByAppendingString:@" "];
                                aLineIndex++;
                                if(aLineIndex >= lines.count) {
                                    shouldBreak = YES;
                                    break;
                                }
                                allCode = [allCode stringByAppendingString:lines[aLineIndex]];
                            }
                            break;
                        }
                        if(c == ']') {
                            leftBrackets++;
                            if(codeIndex >= allCode.length) {
                                allCode = [allCode stringByAppendingString:@" "];
                                aLineIndex++;
                                if(aLineIndex >= lines.count) {
                                    shouldBreak = YES;
                                    break;
                                }
                                allCode = [allCode stringByAppendingString:lines[aLineIndex]];
                            }
                            break;
                        }
                        if(codeIndex >= allCode.length) {
                            allCode = [allCode stringByAppendingString:@" "];
                            aLineIndex++;
                            if(aLineIndex >= lines.count) {
                                shouldBreak = YES;
                                break;
                            }
                            allCode = [allCode stringByAppendingString:lines[aLineIndex]];
                        }
                    }
                    if(shouldBreak) {
                        break;
                    }
                }
                
                allCode = [allCode substringToIndex:codeIndex];
                BOOL match = YES;
                for(NSInteger partIndex = 0; partIndex < methodParts.count - 1; partIndex++) {
                    if(![allCode containsString:[methodParts[partIndex] stringByAppendingString:@":"]]) {
                        match = NO;
                        break;
                    }
                }
                if(match) {
                    CodeMethod *result = [[CodeMethod alloc] init];
                    result.allFiles = [CodeFile codeFileNamed:fileName].refs;
                    result.methodName = [self methodInLines:lines atLine:lineIndex];
                    result.baseFile = fileName;
                    cb(result);
                }
            }
        }
        if(lineIndex >= lines.count) {
            break;
        }
    }

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
