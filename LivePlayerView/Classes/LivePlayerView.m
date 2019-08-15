//
//  LivePlayerView.m
//  RNLive
//
//  Created by Rick on 2019/8/14.
//  Copyright © 2019 Rick. All rights reserved.
//

#import "LivePlayerView.h"
#import "NSTimer+ProjectTool.h"
#import "LivePlayingInfoKit.h"

static NSInteger const MaxReloadCount = 5;

@interface PlayerView ()<LivePlayingInfoKitDelegate>

@property (nonatomic, strong) KSYMoviePlayerController *player;

@property (nonatomic, copy) NSString* urlString;

@property (nonatomic, assign) MPMovieScalingMode scalingMode;

@property (nonatomic, strong) UIView* backgroundView;

@property (nonatomic, strong) NSTimer* timer;

@property (nonatomic, strong) LivePlayingInfoKit *infoKit;

@property (nonatomic, assign) NSInteger reloadCount;

@end

@implementation PlayerView

#pragma mark - Init

- (instancetype)init{
    self = [super init];
    if (self) {
        _urlString = @"";
        _scalingMode = MPMovieScalingModeAspectFill;
        _reloadCount = 0;
    }
    return self;
}

- (instancetype)initWithURLString:(NSString*)string ScalingMode:(MPMovieScalingMode)mode{
    self = [super init];
    if (self) {
        _urlString = string;
        _scalingMode = mode;
        _reloadCount = 0;
    }
    return self;
}

#pragma mark - Lazy Init

- (UIView *)backgroundView{
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = UIColor.blackColor;
        _backgroundView.autoresizesSubviews = YES;
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}

- (KSYMoviePlayerController *)player{
    if (_player == nil) {
        _player = [[KSYMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:_urlString]];
        _player.controlStyle = MPMovieControlStyleNone;
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _player.shouldAutoplay = YES;
        _player.bufferTimeMax = 1;
        _player.scalingMode = _scalingMode;
        [self addObervation];
        [self.backgroundView addSubview:_player.view];
    }
    return _player;
}

- (LivePlayingInfoKit *)infoKit{
    if (_infoKit == nil) {
        _infoKit = [[LivePlayingInfoKit alloc] init];
        _infoKit.delegate = self;
    }
    return _infoKit;
}

#pragma mark - Life Circle

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.player.view.frame = self.backgroundView.bounds;
}

#pragma mark - Public Method

- (void)play {
    if (!self.player.isPlaying) {
        [_player prepareToPlay];
    }
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self.player stop];
}

- (void)reload{
    [self.player reload:[NSURL URLWithString:_urlString] flush:NO mode: MPMovieReloadMode_Accurate];
    [self play];
}

- (void)seekTo:(NSTimeInterval)time{
    [self.player seekTo:time accurate:YES];
}

- (void)setAutoLoop:(BOOL)loop{
    self.player.shouldLoop = loop;
}

- (void)destroy {
    [_player reset:NO];
    [_player stop];
    [self clearTimer];
    [_infoKit destroy];
    [_player.view removeFromSuperview];
    [_backgroundView removeFromSuperview];
    _player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method

- (NSArray *)observerNames{
    return @[
             MPMediaPlaybackIsPreparedToPlayDidChangeNotification,  // 播放器完成对视频文件的初始化时发送此通知
             MPMoviePlayerPlaybackStateDidChangeNotification,  // 播放状态发生改变时发送此通知
             MPMoviePlayerPlaybackDidFinishNotification,  // 正常播放结束或者因为错误播放失败时发送此通知
             MPMoviePlayerLoadStateDidChangeNotification,  // 数据加载状态发生改变时发送此通知
             MPMoviePlayerFirstVideoFrameRenderedNotification,  // 渲染第一帧视频时发送此通知
             MPMoviePlayerFirstAudioFrameRenderedNotification,  // 渲染第一帧音频时发送此通知
             MPMoviePlayerSuggestReloadNotification,  // 当用户监听到此通知时，请采用MPMovieReloadMode_Accurate进行reload
             MPMoviePlayerPlaybackStatusNotification,  // 当播放过程中发生需要上层注意的事件时发送此通知
             MPMoviePlayerNetworkStatusChangeNotification,  // networkDetectURL不为nil的情况下，网络状态发生变化时会发送此通知
             MPMoviePlayerSeekCompleteNotification,  // seekTo动作完成后发送此通知
             UIApplicationDidEnterBackgroundNotification,  // 进入后台
             UIApplicationWillEnterForegroundNotification  // 进去前台
             ];
}

- (void)addObervation{
    __weak typeof (self) weak_self = self;
    [[self observerNames] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[NSNotificationCenter defaultCenter] addObserver:weak_self selector:@selector(playerDidSendNotification:) name:obj object:nil];
    }];
}

- (void)loadStateChanged:(MPMovieLoadState)loadState{
    if (loadState == MPMovieLoadStatePlayable) {
        [self play];
    }
}

- (void)reloadPlay {
    if (_reloadCount < MaxReloadCount) {
        // 重新尝试播放
        [self play];
        _reloadCount++;
        NSLog(@"手动尝试重新播放");
    }
    else {
        _reloadCount = 0;
        if (!_player.isPlaying) {
            if (_delegate && [_delegate respondsToSelector:@selector(playerDidStopCauseError)]) {
                [_delegate playerDidStopCauseError];
            }
        }
        [self clearTimer];
    }
}

- (void)startTimer{
    if (_timer == nil) {
        __weak typeof (self) weak_self = self;
        _timer = [NSTimer supportiOS_10EarlierVersionsScheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weak_self reloadPlay];
        }];
        [NSRunLoop.currentRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)clearTimer{
    [_timer invalidate];
    _timer = nil;
}

- (void)reloadManual{
    [self startTimer];
}

- (void)handleEnterBackground{
    [self.infoKit initConfig];
    if (_delegate && [_delegate respondsToSelector:@selector(playerDidEnterBackground)]) {
        [_delegate playerDidEnterBackground];
    }
}

- (void)handleEnterForeground{
    [self play];
    if (_delegate && [_delegate respondsToSelector:@selector(playerWillEnterForeground)]) {
        [_delegate playerWillEnterForeground];
    }
}

#pragma mark - JDLivePlayingInfoKitDelegate

- (void)remotePlay{
    [self play];
}

- (void)remotePasue{
    [self pause];
}

- (void)remoteTogglePlayPause{
    if (self.player.isPlaying) {
        [self pause];
    }
    else {
        [self play];
    }
}

#pragma mark - Action

- (void)playerDidSendNotification:(NSNotification*)notification {
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification == notification.name) {
        if (_delegate && [_delegate respondsToSelector:@selector(playerDidFinishPreparing)]) {
            [_delegate playerDidFinishPreparing];
        }
    } else if (MPMoviePlayerLoadStateDidChangeNotification == notification.name){
        MPMovieLoadState loadState = _player.loadState;
        [self loadStateChanged:loadState];
        if (_delegate && [_delegate respondsToSelector:@selector(playerLoadStateDidChange:)]) {
            [_delegate playerLoadStateDidChange:loadState];
        }
    } else if (MPMoviePlayerPlaybackStateDidChangeNotification == notification.name) {
        if (_delegate && [_delegate respondsToSelector:@selector(playerPlayStateDidChange:)]) {
            MPMoviePlaybackState playState = _player.playbackState;
            [_delegate playerPlayStateDidChange:playState];
        }
    } else if (MPMoviePlayerNetworkStatusChangeNotification == notification.name) {
        int currentStatus = [[[notification userInfo] valueForKey:MPMoviePlayerCurrNetworkStatusUserInfoKey] intValue];
        int lastStatus = [[[notification userInfo] valueForKey:MPMoviePlayerLastNetworkStatusUserInfoKey] intValue];
        
        if (_delegate && [_delegate respondsToSelector:@selector(playerNetworkStatusDidChange:LastStatus:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate playerNetworkStatusDidChange:currentStatus LastStatus:lastStatus];
            });
        }
    } else if (MPMoviePlayerSeekCompleteNotification == notification.name) {
        if (_delegate && [_delegate respondsToSelector:@selector(playerDidSeekToTime:)]) {
            NSTimeInterval playTime = _player.currentPlaybackTime;
            [_delegate playerDidSeekToTime:playTime];
        }
    } else if (MPMoviePlayerPlaybackDidFinishNotification ==  notification.name) {
        int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
        if (reason == MPMovieFinishReasonPlaybackError){
            // 播放错误重新加载
            [self reloadManual];
        }
        else {
            if (_delegate && [_delegate respondsToSelector:@selector(playerDidEndPlaying)]) {
                [_delegate playerDidEndPlaying];
            }
        }
    } else if (MPMoviePlayerSuggestReloadNotification == notification.name){
        // 重新加载
        [self reloadManual];
        if (_delegate && [_delegate respondsToSelector:@selector(playerDidLoadError)]) {
            [_delegate playerDidLoadError];
        }
    } else if (UIApplicationDidEnterBackgroundNotification == notification.name){
        [self handleEnterBackground];
    } else if (UIApplicationWillEnterForegroundNotification == notification.name){
        [self handleEnterForeground];
    }
}

@end

@implementation LivePlayerView

#pragma mark - Public Method

- (void)play{
    [super play];
}

#pragma mark - Private Method

- (void)loadStateChanged:(MPMovieLoadState)loadState{
    [super loadStateChanged:loadState];
    if (self.player.bufferEmptyCount) {
        CGFloat cacheCount = self.player.bufferEmptyDuration / self.player.bufferEmptyCount;
        if (cacheCount > 10) {
            self.player.bufferTimeMax = 2;
            NSLog(@"动态调整缓存时间为2秒");
        }else if (cacheCount > 6){
            self.player.bufferTimeMax = 5;
            NSLog(@"动态调整缓存时间为5秒");
        }else if (cacheCount > 3){
            self.player.bufferTimeMax = 6;
            NSLog(@"动态调整缓存时间为6秒");
        }else{
            self.player.bufferTimeMax = 0;
            NSLog(@"动态调整缓存时间为0秒");
        }
    }
}

- (void)handleEnterBackground {
    [super handleEnterBackground];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:_mediaImage];

    __weak typeof (self) weak_self = self;
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        if (error) {
            return;
        }

        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
        [weak_self.infoKit configNowPlayingInfoCenter:weak_self.mediaTitle image:image];
    }];

    [downloadTask resume];
}


@end
