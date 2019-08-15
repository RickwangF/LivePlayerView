//
//  NSTimer+ProjectTool.m
//  RNLive
//
//  Created by Rick on 2019/8/14.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "NSTimer+ProjectTool.h"

@implementation NSTimer (ProjectTool)

+ (NSTimer *)supportiOS_10EarlierVersionsScheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block{
    
    if (@available(iOS 10.0, *)) {
        return [self scheduledTimerWithTimeInterval:interval repeats:repeats block:block];
    } else {
        return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(timeAction:) userInfo:block repeats:repeats];
    }
}

+ (void)timeAction:(NSTimer *)timer {
    
    void (^block)(NSTimer *) = [timer userInfo];
    
    !block?:block(timer);
}

@end
