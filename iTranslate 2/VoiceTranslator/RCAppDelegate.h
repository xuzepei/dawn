//
//  RCAppDelegate.h
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTranslatorViewController.h"
#import "GADBannerView.h"
#import "GADInterstitial.h"
#import <iAd/iAd.h>
#import "RCHttpRequest.h"
#import "MobClick.h"

@interface RCAppDelegate : UIResponder <UIApplicationDelegate,GADBannerViewDelegate,GADInterstitialDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic,strong)RCTranslatorViewController* translatorViewController;
@property (nonatomic,strong)UINavigationController* translatorNavigationController;

@property (nonatomic, retain) GADBannerView *adMobAd;
@property (assign)BOOL isAdMobVisible;
@property (nonatomic, retain) GADInterstitial *adInterstitial;
@property (nonatomic,retain) NSString* ad_id;
@property (nonatomic,assign)BOOL showFullScreenAd;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
