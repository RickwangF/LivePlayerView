//
//  NSTimer+ProjectTool.h
//  RNLive
//
//  Created by Rick on 2019/8/14.
//  Copyright © 2019 Rick. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (ProjectTool)

+ (NSTimer *)supportiOS_10EarlierVersionsScheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end

NS_ASSUME_NONNULL_END
