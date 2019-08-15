//
//  LivePlayerView.h
//  RNLive
//
//  Created by Rick on 2019/8/14.
//  Copyright © 2019 Rick. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KSYMediaPlayer/KSYMediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

/// 播放器的网络状态枚举
typedef NS_ENUM(NSInteger, PlayerNetworkStatus) {
    PlayerNetworkStatusUnReachable = 0,
    PlayerNetworkStatusReachableViaWWAN = 1,
    PlayerNetworkStatusReachableViaWiFi = 2
};

/// 播放器的代理协议，所有的方法都是可选实现的
@protocol PlayerViewDelegate <NSObject>

/**
 播放器已经初始化完成准备开始播放的代理方法
 
 */
@optional
- (void)playerDidFinishPreparing;

/**
 播放器加载状态变化的代理方法
 
 @param loadState 加载状态
 */
@optional
- (void)playerLoadStateDidChange:(MPMovieLoadState)loadState;

/**
 播放器加载失败的代理方法
 
 */
@optional
- (void)playerDidLoadError;

/**
 播放器播放状态变化的代理方法
 
 @param playState 播放状态
 */
@optional
- (void)playerPlayStateDidChange:(MPMoviePlaybackState)playState;

/**
 播放器的网络状态变化的代理方法
 
 @param currentStatus 当前的网络状态
 @param lastStatus 之前的网络状态
 */
@optional
- (void)playerNetworkStatusDidChange:(PlayerNetworkStatus)currentStatus LastStatus:(PlayerNetworkStatus)lastStatus;

/**
 播放器因错误停止播放的代理方法
 
 */
@optional
- (void)playerDidStopCauseError;

/**
 播放器播放完成的代理方法
 
 */
@optional
- (void)playerDidEndPlaying;

/**
 播放器将要进入后台的代理方法
 
 */
@optional
- (void)playerDidEnterBackground;

/**
 播放器将要进入前台的代理方法
 
 */
@optional
- (void)playerWillEnterForeground;

/**
 播放器已经完成跳转到指定时间的代理方法
 
 @param time 指定时间
 */
@optional
- (void)playerDidSeekToTime:(NSTimeInterval)time;

@end

/// 通用的播放器视图
@interface PlayerView : UIView

/// 代理对象
@property (nonatomic, weak) id<PlayerViewDelegate> delegate;

/**
 初始化方法
 
 @param string 播放地址或拉流地址
 @param mode 画面的缩放模式
 @return 播放器的实例
 */
- (instancetype)initWithURLString:(NSString*)string ScalingMode:(MPMovieScalingMode)mode;

/**
 设置是否循环播放，需要在play方法之前调用
 
 @param loop 循环播放的标志
 */
- (void)setAutoLoop:(BOOL)loop;

/**
 播放方法
 
 */
- (void)play;

/**
 暂停方法
 
 */
- (void)pause;

/**
 停止播放方法
 
 */
- (void)stop;

/**
 手动重新加载方法，加载成功会自动播放
 
 */
- (void)reloadManual;

/**
 自动重新加载方法, 加载成功会自动播放
 
 */
- (void)reload;

/**
 跳转到指定时间的方法
 
 @param time 指定时间
 */
- (void)seekTo:(NSTimeInterval)time;

/**
 销毁方法，销毁播放器后需要调用removeFromSuperview方法并将播放器赋值为nil
 
 */
- (void)destroy;

@end

/// 直播使用的播放器视图
@interface LivePlayerView : PlayerView

/// 在锁屏界面显示当前媒体的标题
@property (nonatomic, copy) NSString *mediaTitle;

/// 在锁屏界面显示当前媒体的图片
@property (nonatomic, copy) NSString *mediaImage;

@end

NS_ASSUME_NONNULL_END
