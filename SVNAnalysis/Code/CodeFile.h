//
//  CodeFile.h
//  SVNAnalysis
//
//  Created by lolzorz on 15/9/22.
//  Copyright © 2015年 lolzorz.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeFile : NSObject

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSMutableArray *refs;
@property (nonatomic, strong) NSMutableDictionary *histories;

+ (CodeFile *)codeFileNamed:(NSString *)name;

@end
