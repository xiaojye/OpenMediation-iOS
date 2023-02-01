// Copyright 2020 ADTIMING TECHNOLOGY COMPANY LIMITED
// Licensed under the GNU Lesser General Public License Version 3

#import "OMGoogleAdAdapter.h"
#import "OMGoogleAdInterstitial.h"

@implementation OMGoogleAdInterstitial

- (instancetype)initWithParameter:(NSDictionary*)adParameter {
    if (self = [super init]) {
        if (adParameter && [adParameter isKindOfClass:[NSDictionary class]]) {
            _pid = [adParameter objectForKey:@"pid"];
        }
        
    }
    return self;
}
- (void)loadAd {
    Class interstitialClass = NSClassFromString(@"GAMInterstitialAd");
    Class requestClass = NSClassFromString(@"GAMRequest");
    if (interstitialClass && [interstitialClass respondsToSelector:@selector(loadWithAdUnitID:request:completionHandler:)] && requestClass && [requestClass respondsToSelector:@selector(request)]) {
        __weak typeof(self) weakSelf = self;
        GAMRequest *request  = [requestClass request];
        if ([OMGoogleAdAdapter npaAd] && NSClassFromString(@"GADExtras")) {
            GADExtras *extras = [[NSClassFromString(@"GADExtras") alloc] init];
            extras.additionalParameters = @{@"npa": @"1"};
            [request registerAdNetworkExtras:extras];
        }
        [interstitialClass loadWithAdManagerAdUnitID:_pid
                                       request:request
                             completionHandler:^(GAMInterstitialAd *ad, NSError *error) {
            if (!error) {
                weakSelf.ready = YES;
                weakSelf.admobInterstitial = ad;
                weakSelf.admobInterstitial.fullScreenContentDelegate = weakSelf;
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(customEvent:didLoadWithAdnName:)]) {
                    NSString *adnName = @"";
                    GADResponseInfo *info = [ad responseInfo];
                    if (info && [info respondsToSelector:@selector(adNetworkClassName)]) {
                        adnName = [info adNetworkClassName];
                    }
                    [weakSelf.delegate customEvent:weakSelf didLoadWithAdnName:adnName];
                }
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(customEvent:didLoadAd:)]) {
                    [weakSelf.delegate customEvent:weakSelf didLoadAd:nil];
                }
            } else {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(customEvent:didFailToLoadWithError:)]) {
                    [weakSelf.delegate customEvent:weakSelf didFailToLoadWithError:error];
                }
            }
        }];
    }
}

- (BOOL)isReady{
    return self.ready;
}

- (void)show:(UIViewController*)vc{
    if ([self ready]) {
        [_admobInterstitial presentFromRootViewController:vc];
    }
    self.ready = NO;
}


- (void)ad:(id)ad didFailToPresentFullScreenContentWithError:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(interstitialCustomEventDidFailToShow:error:)]) {
        NSError *error = [NSError errorWithDomain:@"com.admob.interstitial" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"interstitialDidFailToPresentScreen"}];
        [_delegate interstitialCustomEventDidFailToShow:self error:error];
    }
}

- (void)adDidRecordImpression:(id)ad {
    if (_delegate && [_delegate respondsToSelector:@selector(interstitialCustomEventDidOpen:)]) {
        [_delegate interstitialCustomEventDidOpen:self];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(interstitialCustomEventDidShow:)]) {
        [_delegate interstitialCustomEventDidShow:self];
    }
}

- (void)adDidRecordClick:(nonnull id<GADFullScreenPresentingAd>)ad {
    if (_delegate && [_delegate respondsToSelector:@selector(interstitialCustomEventDidClick:)]) {
        [_delegate interstitialCustomEventDidClick:self];
    }
}

- (void)adDidDismissFullScreenContent:(id)ad {
    if (_delegate && [_delegate respondsToSelector:@selector(interstitialCustomEventDidClose:)]) {
        [_delegate interstitialCustomEventDidClose:self];
    }
    _admobInterstitial = nil;
}

@end
