//
//  CodeManager.h
//  SVNAnalysis
//
//  Created by 徐家翀 on 9/3/15.
//  Copyright (c) 2015 lolzorz.me. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CodeManager : NSObject

+ (CodeManager *)sharedInstance;

@property (nonatomic, strong) NSMutableDictionary *allClasses;

@end
