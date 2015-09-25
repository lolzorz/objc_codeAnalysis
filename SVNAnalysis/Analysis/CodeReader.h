//
//  CodeReader.h
//  SVNAnalysis
//
//  Created by 徐家翀 on 9/3/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeReader : NSObject

+ (void)testRead;
+ (void)readLogCount:(NSInteger)count atPath:(NSString *)basePath;
+ (void)readLogReversion:(NSString *)reversion atPath:(NSString *)basePath;

@end
