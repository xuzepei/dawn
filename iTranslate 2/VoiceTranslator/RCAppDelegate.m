//
//  RCAppDelegate.m
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import "RCAppDelegate.h"
#import "RCTool.h"


@implementation RCAppDelegate

- (void)dealloc
{
    [_window release];
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    
    [_translatorViewController release];
    [_translatorNavigationController release];
    
    self.adMobAd = nil;
    self.adInterstitial = nil;
    
    self.adView = nil;
    self.interstitial = nil;
    
    self.ad_id = nil;
    
    [super dealloc];
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //UMeng
    [MobClick startWithAppkey:UMENG_APP_KEY
                 reportPolicy:SEND_INTERVAL
                    channelId:nil];

    [application setApplicationIconBadgeNumber:0];
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert
     | UIRemoteNotificationTypeBadge
     | UIRemoteNotificationTypeSound];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    _translatorViewController = [[RCTranslatorViewController alloc] initWithNibName:nil bundle:nil];
    
    _translatorNavigationController = [[UINavigationController alloc] initWithRootViewController:_translatorViewController];
    
    [self.window setRootViewController:_translatorNavigationController];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    //[[UINavigationBar appearance] setBarTintColor:APP_TINT_COLOR];
    //[[UINavigationBar appearance] setTintColor:APP_TINT_COLOR];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    self.showFullScreenAd = YES;
    //[self getAppInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"VoiceTranslator" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"VoiceTranslator.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - AdMob

- (void)getAppInfo
{
    NSString* urlString = APP_INFO_URL;
    
    RCHttpRequest* temp = [RCHttpRequest sharedInstance];
    [temp request:urlString delegate:self resultSelector:@selector(finishedGetAppInfoRequest:) token:nil];
}

- (void)finishedGetAppInfoRequest:(NSDictionary*)token
{
    if(nil == token)
    {
        self.ad_id = [RCTool getAdId];
        
        [self getAD];
        
        return;
    }
    
    NSDictionary* result = [RCTool parseToDictionary:[RCTool decrypt:[token objectForKey:@"content"]]];
    if(result && [result isKindOfClass:[NSDictionary class]])
    {
        //保存用户信息
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"app_info"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.ad_id = [RCTool getAdId];
        
        [self getAD];
    }
    
}

- (void)initAdMob
{
    if(_adMobAd && _adMobAd.alpha == 0.0 && nil == _adMobAd.superview)
	{
		[_adMobAd removeFromSuperview];
		_adMobAd.delegate = nil;
		[_adMobAd release];
		_adMobAd = nil;
	}
    
    if([RCTool isRemoveAD])
        return;
    
	//if(NO == [RCTool isIpad])
	{
		_adMobAd = [[GADBannerView alloc]
                    initWithFrame:CGRectMake(0.0,0,
                                             320.0f,
                                             50.0f)];
	}

	
	
	
	_adMobAd.adUnitID = [RCTool getAdId];
	_adMobAd.delegate = self;
	_adMobAd.alpha = 0.0;
	_adMobAd.rootViewController = _translatorViewController;
	[_adMobAd loadRequest:[GADRequest request]];
	
}

- (void)getAD
{
	NSLog(@"getAD");
    
    if(self.adMobAd && self.adMobAd.superview)
    {
        [self.adMobAd removeFromSuperview];
        self.adMobAd = nil;
    }
    
    if(self.adView && self.adView.superview)
    {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    self.adInterstitial = nil;
    self.interstitial = nil;
	
	[self initAdMob];
    
    [self getAdInterstitial];
}

#pragma mark -
#pragma mark GADBannerDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
	NSLog(@"adViewDidReceiveAd");
	
    if(nil == _adMobAd.superview && _adMobAd.alpha == 0.0)
    {
        _adMobAd.alpha = 1.0;
        CGRect rect = _adMobAd.frame;
        rect.origin.x = ([RCTool getScreenSize].width - rect.size.width)/2.0;
        rect.origin.y = [RCTool getScreenSize].height - _adMobAd.bounds.size.height;
        _adMobAd.frame = rect;
        
        self.isAdMobVisible = NO;
    }
    
    if(NO == [RCTool isRemoveAD])
    {
        [_translatorViewController.view addSubview:_adMobAd];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_AD_NOTIFICATION object:nil userInfo:nil];
    }
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
	NSLog(@"didFailToReceiveAdWithError");
    
    self.isAdMobVisible = NO;
    
    [self performSelector:@selector(initAdMob) withObject:nil afterDelay:10];
}

- (void)getAdInterstitial
{
    if(nil == self.adInterstitial && [self.ad_id length])
    {
        _adInterstitial = [[GADInterstitial alloc] init];
        _adInterstitial.adUnitID = [RCTool getScreenAdId];
        _adInterstitial.delegate = self;
    }
    
    if([RCTool isRemoveAD])
        return;
    
    [_adInterstitial loadRequest:[GADRequest request]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialDidReceiveAd");
    
    if(self.showFullScreenAd && NO == [RCTool isRemoveAD])
    {
        self.showFullScreenAd = NO;
        [self showInterstitialAd:nil];
    }
    
}

- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%s",__FUNCTION__);
    
    [self initInterstitial];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    self.adInterstitial = nil;
    //[self getAdInterstitial];
}

- (void)showInterstitialAd:(id)argument
{
    if(self.adInterstitial)
    {
        [self.adInterstitial presentFromRootViewController:_translatorViewController];
    }
    else if(self.interstitial && self.interstitial.loaded)
    {
        [self.interstitial presentFromViewController:_translatorViewController];
    }
}

#pragma mark - iAd

- (void)initAdView
{
    if(nil == _adView)
        _adView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    _adView.delegate = self;
    CGRect rect = _adView.frame;
    rect.origin.y = [RCTool getScreenSize].height;
    _adView.frame = rect;
    
    self.isAdViewVisible = NO;
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"iAd,bannerViewDidLoadAd");
    
    //[[RCTool getRootNavigationController].topViewController.view addSubview:_adView];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAd,didFailToReceiveAdWithError");
    
    self.isAdViewVisible = NO;
    [self.adView removeFromSuperview];
    self.adView = nil;
    
    //如果iAd失败，则调用admob
    [self performSelector:@selector(initAdMob) withObject:nil afterDelay:3];
}

- (void)initInterstitial
{
    if(nil == _interstitial)
    {
        _interstitial = [[ADInterstitialAd alloc] init];
        _interstitial.delegate = self;
    }
    
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"iAd,interstitialAdDidLoad");
    
    
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    NSLog(@"iAd,interstitialAdDidUnload");
    self.interstitial = nil;
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    NSLog(@"iAd,interstitialAd <%@> recieved error <%@>", interstitialAd, error);
    self.interstitial = nil;
    
    //尝试调用Admob的全屏广告
    [self getAdInterstitial];
}


@end
