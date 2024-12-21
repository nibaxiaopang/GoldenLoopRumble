//
//  UIViewController+ext.h
//  GoldenLoopRumble
//
//  Created by jin fu on 2024/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ext)

+ (NSString *)goldenGetUserDefaultKey;

+ (void)goldenSetUserDefaultKey:(NSString *)key;

- (void)goldenSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)goldenAppsFlyerDevKey;

- (NSString *)goldenMainHostUrl;

- (BOOL)goldenNeedShowAdsView;

- (void)goldenShowAdView:(NSString *)adsUrl;

- (void)goldenSendEventsWithParams:(NSString *)params;

- (NSDictionary *)goldenJsonToDicWithJsonString:(NSString *)jsonString;

- (void)goldenAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)goldenAfSendEventWithName:(NSString *)name value:(NSString *)valueStr;

- (NSString *)goldenLowercase:(NSString *)org;

@end

NS_ASSUME_NONNULL_END
