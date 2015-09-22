//
//  CodeMethod.h
//  SVNAnalysis
//
//  Created by 徐家翀 on 8/31/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

@class CodeClass;

#import <Foundation/Foundation.h>

@interface CodeMethod : NSObject

@property (nonatomic, strong) CodeClass *methodClass;
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, assign) NSInteger startLine;
@property (nonatomic, strong) NSMutableArray *allLine;

@end
