//
//  CodeClass.h
//  SVNAnalysis
//
//  Created by 徐家翀 on 8/31/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeClass : NSObject

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) CodeClass *superClass;
@property (nonatomic, strong) NSMutableDictionary *classProperties;
@property (nonatomic, strong) NSMutableDictionary *classMethods;

+ (CodeClass *)codeClassNamed:(NSString *)name;

@end
