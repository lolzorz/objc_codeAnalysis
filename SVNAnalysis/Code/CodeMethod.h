//
//  CodeMethod.h
//  SVNAnalysis
//
//  Created by 徐家翀 on 8/31/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

@class CodeFile;

#import <Foundation/Foundation.h>

@interface CodeMethod : NSObject

@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, strong) NSMutableArray *allFiles;
@property (nonatomic, strong) NSString *baseFile;
@property (nonatomic, assign) NSInteger line;
@property (nonatomic, strong) CodeMethod *lastLevel;

@end
