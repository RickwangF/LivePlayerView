//
//  JDLivePlayingInfoKit.m
//  JadeKing
//
//  Created by 张森 on 2018/11/27.
//  Copyright © 2018年 张森. All rights reserved.
//

#import "LivePlayingInfoKit.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LivePlayingInfoKit ()
@property (nonatomic, assign) BOOL played;  //  播放状态
@end

@implementation LivePlayingInfoKit

- (void)initConfig{
    //静音状态下播放
    [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    //处理电话打进时中断音乐播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruptionNotificationHandler:) name:AVAudioSessionInterruptionNotification object:nil];
    //后台播放
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 在App启动后开启远程控制事件, 接收来自锁屏界面和上拉菜单的控制
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // 处理远程控制事件
    [self remoteControlEventHandler];
}


// Mark - 来电中断处理
- (void)interruptionNotificationHandler:(NSNotification*)notification{
    NSDictionary *interuptionDict = notification.userInfo;
    NSString *type = [NSString stringWithFormat:@"%@", [interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey]];
    NSUInteger interuptionType = [type integerValue];
    
    if (interuptionType == AVAudioSessionInterruptionTypeBegan) {
        //获取中断前音乐是否在播放
        NSLog(@"AVAudioSessionInterruptionTypeBegan");
    }else if (interuptionType == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"AVAudioSessionInterruptionTypeEnded");
    }
    
    if(_played){
        //停止播放的事件
        _played=NO;
    }else {
        //继续播放的事件
        _played=YES;
    }
}

// Mark - 在需要处理远程控制事件的具体控制器或其它类中实现
- (void)remoteControlEventHandler{
    // 直接使用sharedCommandCenter来获取MPRemoteCommandCenter的shared实例
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
    commandCenter.playCommand.enabled = YES;
    
    __weak typeof (self) weak_self = self;
    // 为播放命令添加响应事件, 在点击后触发
    [commandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了播放
        [weak_self.delegate remotePlay];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
    [commandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了暂停
        [weak_self.delegate remotePasue];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了上一首

        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [commandCenter.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        //点击了下一首

        return MPRemoteCommandHandlerStatusSuccess;
    }];
    
    // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
    commandCenter.togglePlayPauseCommand.enabled = YES;
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        // 进行播放/暂停的相关操作 (耳机的播放/暂停按钮)
        [weak_self.delegate remoteTogglePlayPause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
}

/**
 *  设置锁屏信息
 */
- (void)configNowPlayingInfoCenter:(NSString *)name image:(UIImage *)image{
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    if (playingInfoCenter) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        if (name == nil || ![name isKindOfClass:NSString.class]) {
            name = @"";
        }
        // 歌曲名称
        [songInfo setObject:name forKey:MPMediaItemPropertyTitle];
        // 演唱者
        [songInfo setObject:@"翡翠王朝" forKey:MPMediaItemPropertyArtist];
        // 专辑名
        [songInfo setObject:@"直播间" forKey:MPMediaItemPropertyAlbumTitle];
        // 专辑缩略图
        if (image != nil && [image isKindOfClass:UIImage.class]) {
            MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
            [songInfo setObject:albumArt forKey:MPMediaItemPropertyArtwork];
        }
        // 设置锁屏状态下屏幕显示音乐信息
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
    }
}

- (void)destroy{
    // 在App要终止前结束接收远程控制事件, 也可以在需要终止时调用该方法终止
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

@end
