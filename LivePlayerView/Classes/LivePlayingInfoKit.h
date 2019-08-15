//
//  JDLivePlayingInfoKit.h
//  JadeKing
//
//  Created by 张森 on 2018/11/27.
//  Copyright © 2018年 张森. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LivePlayingInfoKitDelegate <NSObject>

- (void)remotePasue;
- (void)remotePlay;
- (void)remoteTogglePlayPause;

@end

@interface LivePlayingInfoKit : NSObject
@property (nonatomic, weak) id<LivePlayingInfoKitDelegate> delegate;  // 代理
- (void)configNowPlayingInfoCenter:(NSString *)name image:(UIImage *)image;
- (void)initConfig;
- (void)destroy;
@end

