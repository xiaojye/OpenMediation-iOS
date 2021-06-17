// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import "OMPangleNative.h"
#import "OMPangleNativeAd.h"
#import "OMPangleAdapter.h"
#import "OMPangleNativeAdView.h"

@implementation OMPangleNative

- (instancetype)initWithParameter:(NSDictionary*)adParameter rootVC:(UIViewController*)rootViewController {
    if (self = [super init]) {
        if (adParameter && [adParameter isKindOfClass:[NSDictionary class]]) {
            NSString *pid = [adParameter objectForKey:@"pid"];
            Class slotClass = NSClassFromString(@"BUAdSlot");
            Class buSize = NSClassFromString(@"BUSize");
            if (slotClass) {
                BUAdSlot *slot = [[slotClass alloc] init];
                slot.ID = pid;
                slot.AdType = BUAdSlotAdTypeFeed;
                slot.position = BUAdSlotPositionFeed;
                slot.imgSize = [buSize sizeBy:BUProposalSize_Feed228_150];
                
                if ([OMPangleAdapter internalAPI]) {
                    Class adLoaderClass = NSClassFromString(@"BUNativeExpressAdManager");
                    if (adLoaderClass && [adLoaderClass instancesRespondToSelector:@selector(initWithSlot:adSize:)]) {
                        _adLoader = [[adLoaderClass alloc] initWithSlot:slot adSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 0)];
                    }
                }else{
                    Class adLoaderClass = NSClassFromString(@"BUNativeAdsManager");
                    if (adLoaderClass && [adLoaderClass instancesRespondToSelector:@selector(initWithSlot:)]) {
                        _adLoader = [[adLoaderClass alloc] initWithSlot:slot];
                    }
                }
                _adLoader.delegate = self;
            }
            
        }
        _rootVC = rootViewController;
    }
    return self;
}

- (void)loadAd {
    if (_adLoader && [_adLoader respondsToSelector:@selector(loadAdDataWithCount:)]) {
        [_adLoader loadAdDataWithCount:1];
    }
}

- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    if (nativeAdDataArray.count >0) {
        BUNativeAd *nativeAd = nativeAdDataArray[0];
        nativeAd.delegate = self;
        nativeAd.rootViewController = _rootVC;
        OMPangleNativeAd *pangleNativeAd = [[OMPangleNativeAd alloc]initWithNativeAd:nativeAd];
        if (_delegate && [_delegate respondsToSelector:@selector(customEvent:didLoadAd:)]) {
            [_delegate customEvent:self didLoadAd:pangleNativeAd];
        }
    }
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    if (error && _delegate && [_delegate respondsToSelector:@selector(customEvent:didFailToLoadWithError:)]) {
        [_delegate customEvent:self didFailToLoadWithError:error];
    }
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    if (_delegate && [_delegate respondsToSelector:@selector(nativeCustomEventWillShow:)]) {
        [_delegate nativeCustomEventWillShow:self];
    }
}


- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType {
    
}


- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    if (_delegate && [_delegate respondsToSelector:@selector(nativeCustomEventDidClick:)]) {
        [_delegate nativeCustomEventDidClick:self];
    }
}

- (void)nativeAd:(BUNativeAd *_Nullable)nativeAd dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterWords {
    
}

- (void)videoAdView:(BUVideoAdView *)videoAdView didLoadFailWithError:(NSError *_Nullable)error {
    
}


- (void)videoAdView:(BUVideoAdView *)videoAdView stateDidChanged:(BUPlayerPlayState)playerState {
    
}

- (void)playerDidPlayFinish:(BUVideoAdView *)videoAdView {
    
}

- (void)videoAdViewDidClick:(BUVideoAdView *)videoAdView {
    if (_delegate && [_delegate respondsToSelector:@selector(nativeCustomEventDidClick:)]) {
        [_delegate nativeCustomEventDidClick:self];
    }
}


- (void)videoAdViewFinishViewDidClick:(BUVideoAdView *)videoAdView {
    
}

- (void)videoAdViewDidCloseOtherController:(BUVideoAdView *)videoAdView interactionType:(BUInteractionType)interactionType {
    
}

// ************************ ExpressNative

/**
 * Sent when views successfully load ad
 */
- (void)nativeExpressAdSuccessToLoad:(BUNativeExpressAdManager *)nativeExpressAdManager views:(NSArray<__kindof BUNativeExpressAdView *> *)views {
    if (views.count >0) {
        BUNativeExpressAdView *expressAdView = views[0];
        [expressAdView render];
    }
}

/**
 * Sent when views fail to load ad
 */
- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAdManager error:(NSError *_Nullable)error {
    if (error && _delegate && [_delegate respondsToSelector:@selector(customEvent:didFailToLoadWithError:)]) {
        [_delegate customEvent:self didFailToLoadWithError:error];
    }
}

/**
 * This method is called when rendering a nativeExpressAdView successed, and nativeExpressAdView.size.height has been updated
 */
- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    OMPangleNativeAdView *nativeAdView = [[OMPangleNativeAdView alloc] initWithNativeAdView:nativeExpressAdView];
    if (_delegate && [_delegate respondsToSelector:@selector(customEvent:didLoadAd:)]) {
        [_delegate customEvent:self didLoadAd:nativeAdView];
    }
    
}

/**
 * This method is called when a nativeExpressAdView failed to render
 */
- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *_Nullable)error {
    
}

/**
 * Sent when an ad view is about to present modal content
 */
- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
    if (!_hasShown && _delegate && [_delegate respondsToSelector:@selector(nativeCustomEventWillShow:)]) {
        [_delegate nativeCustomEventWillShow:self];
    }
}

/**
 * Sent when an ad view is clicked
 */
- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    if (_delegate && [_delegate respondsToSelector:@selector(nativeCustomEventDidClick:)]) {
        [_delegate nativeCustomEventDidClick:self];
    }
    _hasShown = YES;
}

/**
 Sent when a playerw playback status changed.
 @param playerState : player state after changed
 */
- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView stateDidChanged:(BUPlayerPlayState)playerState {
    
}

/**
 * Sent when a player finished
 * @param error : error of player
 */
- (void)nativeExpressAdViewPlayerDidPlayFinish:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    
}

/**
 * Sent when a user clicked dislike reasons.
 * @param filterWords : the array of reasons why the user dislikes the ad
 */
- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    
}

/**
 * Sent after an ad view is clicked, a ad landscape view will present modal content
 */
- (void)nativeExpressAdViewWillPresentScreen:(BUNativeExpressAdView *)nativeExpressAdView {
    
}

/**
 This method is called when another controller has been closed.
 @param interactionType : open appstore in app or open the webpage or view video ad details page.
 */
- (void)nativeExpressAdViewDidCloseOtherController:(BUNativeExpressAdView *)nativeExpressAdView interactionType:(BUInteractionType)interactionType {
    
}

@end
