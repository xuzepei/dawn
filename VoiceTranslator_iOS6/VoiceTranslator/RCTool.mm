//
//  RCTool.m
//  rsscoffee
//
//  Created by beer on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RCTool.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "RCAppDelegate.h"
#import "SBJSON.h"
#import "Translation.h"
#import "ASIHTTPRequest.h"
#import <AudioToolbox/AudioToolbox.h>

static SystemSoundID g_soundID = 0;

void systemSoundCompletionProc(SystemSoundID ssID,void *clientData)
{
	AudioServicesRemoveSystemSoundCompletion(ssID);
	AudioServicesDisposeSystemSoundID(g_soundID);
	g_soundID = 0;
}

static int g_reachabilityType = -1;

@implementation RCTool

+ (BOOL)checkCrackedApp
{
    static BOOL isCraked = NO;
    
    NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary *info = [bundle infoDictionary];
	if ([info objectForKey: @"SignerIdentity"] != nil)//判断是否为破解App,方法可能已过时
	{
		isCraked = YES;
	}
    else//通过检查是否为jailbreak设备来判断是否为破解App
    {
        NSArray *jailbrokenPath = [NSArray arrayWithObjects:
                                   @"/Applications/Cydia.app",
                                   @"/Applications/RockApp.app",
                                   @"/Applications/Icy.app",
                                   @"/usr/sbin/sshd",
                                   @"/usr/bin/sshd",
                                   @"/usr/libexec/sftp-server",
                                   @"/Applications/WinterBoard.app",
                                   @"/Applications/SBSettings.app",
                                   @"/Applications/MxTube.app",
                                   @"/Applications/IntelliScreen.app",
                                   @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                                   @"/Applications/FakeCarrier.app",
                                   @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                                   @"/private/var/lib/apt",
                                   @"/Applications/blackra1n.app",
                                   @"/private/var/stash",
                                   @"/private/var/mobile/Library/SBSettings/Themes",
                                   @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                                   @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                                   @"/private/var/tmp/cydia.log",
                                   @"/private/var/lib/cydia", nil];
        
        for(NSString *path in jailbrokenPath)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                isCraked = YES;
                break;
            }
        }
        
    }
    
    return isCraked;
}

+ (NSString*)getUserDocumentDirectoryPath
{
    NSArray* array = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
	if([array count])
		return [array objectAtIndex: 0];
	else
		return @"";
}

+ (NSString *)md5:(NSString *)str 
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];	
}

+ (UIWindow*)frontWindow
{
	UIApplication *app = [UIApplication sharedApplication];
    NSArray* windows = [app windows];
    
    for(int i = [windows count] - 1; i >= 0; i--)
    {
        UIWindow *frontWindow = [windows objectAtIndex:i];
            return frontWindow;
    }
    
	return nil;
}

/**
 显示提示筐
 */
+ (void)showAlert:(NSString*)aTitle message:(NSString*)message
{
	if(0 == [aTitle length] || 0 == [message length])
		return;
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: aTitle
													message: message
												   delegate: self
										  cancelButtonTitle: NSLocalizedString(@"OK",@"")
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
}

/**
 隐藏UIWebView拖拽时顶部的阴影效果
 */
+ (void)hidenWebViewShadow:(UIWebView*)webView
{
    if(nil == webView)
        return;
    
    if ([[webView subviews] count])
    {
        for (UIView* shadowView in [[[webView subviews] objectAtIndex:0] subviews])
        {
            [shadowView setHidden:YES];
        }
        
        // unhide the last view so it is visible again because it has the content
        [[[[[webView subviews] objectAtIndex:0] subviews] lastObject] setHidden:NO];
    }
}

+ (NSString*)getDateString:(NSDate*)date
{
    if(nil == date)
        return @"";
    
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.dateStyle = kCFDateFormatterMediumStyle;
    fmt.timeStyle = kCFDateFormatterNoStyle;
    NSString* dateString = [fmt stringFromDate:date];
    [fmt release];

    return dateString;
}

+ (void)playSound:(NSString*)filename
{
    if(g_soundID || 0 == [filename length])
	    return;
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback
                                           error: NULL];
    
    [[AVAudioSession sharedInstance] setActive:YES
                                         error:NULL];
    
	NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	
	NSURL *fileUrl = [NSURL fileURLWithPath:path];
    
    g_soundID = 0;
	AudioServicesCreateSystemSoundID((CFURLRef)fileUrl, &g_soundID);
	AudioServicesAddSystemSoundCompletion(g_soundID,NULL,NULL,systemSoundCompletionProc, NULL);
	AudioServicesPlaySystemSound(g_soundID);
}

+ (UIImage*)createImage:(NSString*)imageName
{
    if(0 == [imageName length])
        return nil;
    
    if(NO == [imageName hasSuffix:@"@2x.png"])
        imageName = [NSString stringWithFormat:@"%@@2x.png",imageName];
    
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@""];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    
    return image;
}

#pragma mark - Network

+ (void)setReachabilityType:(int)type
{
	g_reachabilityType = type;
}

+ (int)getReachabilityType
{
	return g_reachabilityType;
}

+ (BOOL)isReachableViaInternet
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

+ (BOOL)isReachableViaWiFi
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return NO;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

#pragma mark - Core Data

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator
{
	RCAppDelegate* appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate persistentStoreCoordinator];
}

+ (NSManagedObjectContext*)getManagedObjectContext
{
	RCAppDelegate* appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate managedObjectContext];
}

+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context

{
	if(0 == [entityName length] || nil == context)
		return nil;
	
	//NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectIDResultType];
	
	
	//	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] 
	//															initWithFetchRequest:fetchRequest 
	//															managedObjectContext:context 
	//															sectionNameKeyPath:nil 
	//															cacheName:@"Root"];
	//	
	//	//[context tryLock];
	//	[fetchedResultsController performFetch:nil];
	//	//[context unlock];
	
	NSArray* objectIDs = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	if(objectIDs && [objectIDs count])
		return [objectIDs lastObject];
	else
		return nil;
}

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors
{
	if(0 == [entityName length])
		return nil;
	
	NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectResultType];
	
	NSArray* objects = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	return objects;
}

+ (id)insertEntityObjectForName:(NSString*)entityName 
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(0 == [entityName length] || nil == managedObjectContext)
		return nil;
	
	NSManagedObjectContext* context = managedObjectContext;
	id entityObject = [NSEntityDescription insertNewObjectForEntityForName:entityName 
													inManagedObjectContext:context];
	
	
	return entityObject;
	
}

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID 
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(nil == objectID || nil == managedObjectContext)
		return nil;
	
	return [managedObjectContext objectWithID:objectID];
}

+ (void)saveCoreData
{
	RCAppDelegate* appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSError *error = nil;
    if ([appDelegate managedObjectContext] != nil) 
	{
        if ([[appDelegate managedObjectContext] hasChanges] && ![[appDelegate managedObjectContext] save:&error]) 
		{
            
        } 
    }
}

+ (void)deleteOldData
{
    //NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isHidden == NO"];
    NSArray* translations = [RCTool getExistingEntityObjectsForName:@"Translation" predicate:nil sortDescriptors:nil];
    NSManagedObjectContext* context = [RCTool getManagedObjectContext];
    for(Translation* translation in translations)
    {
        [context deleteObject:translation];
    }
    [RCTool saveCoreData];
    
    NSString* recorDirectoryPath = [NSString stringWithFormat:@"%@/record",[RCTool getUserDocumentDirectoryPath]];
    [RCTool removeFile:recorDirectoryPath];
    
    NSString* ttsDirectoryPath = [[RCTool getUserDocumentDirectoryPath] stringByAppendingString:@"/tts"];
    [RCTool removeFile:ttsDirectoryPath];
}

- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2
{
    NSTimeInterval date1 = [object1 doubleValue];
    NSTimeInterval date2 = [object2 doubleValue];
    if(date1 > date2)
        return NSOrderedDescending;
    else if(date1 == date2)
        return NSOrderedSame;
    return NSOrderedAscending;
}

+ (NSArray*)getAllTranslations
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isHidden == NO"];
    NSArray* translations = [RCTool getExistingEntityObjectsForName:@"Translation" predicate:predicate sortDescriptors:nil];
    
    if([translations count])
    {
        translations = [translations sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            Translation* translation1 = (Translation*)obj1;
            Translation* translation2 = (Translation*)obj2;
            
            NSTimeInterval date1 = [translation1.time doubleValue];
            NSTimeInterval date2 = [translation2.time doubleValue];
            if(date1 > date2)
                return NSOrderedDescending;
            else if(date1 == date2)
                return NSOrderedSame;
            return NSOrderedAscending;
        }];
    }
    
    return translations;
}

#pragma mark - 兼容iOS6和iPhone5

+ (CGSize)getScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGRect)getScreenRect
{
    return [[UIScreen mainScreen] bounds];
}

+ (BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        if(568 == size.height)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (CGFloat)systemVersion
{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return systemVersion;
}

#pragma mark - 文件相关操作

+ (NSString*)getRecordFilePath:(NSString*)filename
{
    if(0 == [filename length])
        return @"";
    
    NSString* directoryPath = [NSString stringWithFormat:@"%@/record",[RCTool getUserDocumentDirectoryPath]];
    if(NO == [RCTool isExistingFile:directoryPath])
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    return [NSString stringWithFormat:@"%@/record/%@.wav",[RCTool getUserDocumentDirectoryPath],filename];
}

+ (BOOL)isExistingFile:(NSString*)filePath
{
	NSFileManager* fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:filePath];
}

+ (void)removeFile:(NSString*)filePath
{
    if([filePath length])
        [[NSFileManager defaultManager] removeItemAtPath:filePath
                                                   error:nil];
}

+ (NSString*)createRecordFilename
{
    NSDate* date = [NSDate date];
    NSTimeInterval interval = [date timeIntervalSince1970];
    return [RCTool md5:[NSString stringWithFormat:@"%ld",(long)interval]];
}

#pragma mark - UserDefault

+ (void)setLeftLanguage:(NSString*)language
{
    if(0 == [language length])
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"left_language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)getLeftLanguage
{
    NSString* leftLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"left_language"];
    if([leftLanguage length])
        return leftLanguage;
    
    return @"en";
}

+ (void)setRightLanguage:(NSString*)language
{
    if(0 == [language length])
        return;
    
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"right_language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)getRightLanguage
{
    NSString* rightLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"right_language"];
    if([rightLanguage length])
        return rightLanguage;
    
    return @"zh-CN";
}

+ (void)setDetectEnd:(BOOL)b
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setBool:b forKey:@"SWT_DETECTEND"];
    [temp synchronize];
}

+ (BOOL)getDectectEnd
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* b = [temp objectForKey:@"SWT_DETECTEND"];
    if(b)
        return [b boolValue];
    
    return YES;
}

+ (void)setAutoSpeak:(BOOL)b
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setBool:b forKey:@"SWT_AUTOSPEAK"];
    [temp synchronize];
}

+ (BOOL)getAutoSpeak
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* b = [temp objectForKey:@"SWT_AUTOSPEAK"];
    if(b)
        return [b boolValue];
    
    return YES;
}

+ (BOOL)setShowHintMask:(BOOL)b
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setBool:b forKey:@"showHintMask"];
    [temp synchronize];
}

+ (BOOL)getShowHintMask
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* b = [temp objectForKey:@"showHintMask"];
    if(b)
        return [b boolValue];
    
    return YES;
}

#pragma mark - 解析数据

+ (NSDictionary*)parseJSON:(NSString*)jsonString
{
    if(0 == [jsonString length])
		return nil;
    
	SBJSON* sbjson = [[SBJSON alloc] init];
	NSDictionary* dict = [sbjson objectWithString:jsonString error:nil];
	
	if(dict && [dict isKindOfClass:[NSDictionary class]])
	{
        [sbjson release];
        return dict;
	}
	
	[sbjson release];
    
	return nil;
}

#pragma mark - TTS文件下载与保存

+ (NSString*)getTTSUrl:(NSString*)code text:(NSString*)text
{
    if(0 == [code length] || 0 == [text length])
        return @"";
    
    NSString* urlString = [NSString stringWithFormat:@"http://translate.google.com/translate_tts?tl=%@&q=%@",code,text];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    return urlString;
}

+ (NSString*)getTTSPath:(NSString*)ttsUrl
{
	if(0 == [ttsUrl length])
		return nil;
    
    NSString* directoryPath = [[RCTool getUserDocumentDirectoryPath] stringByAppendingString:@"/tts"];
    if(NO == [RCTool isExistingFile:directoryPath])
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
	
	return [NSString stringWithFormat:@"%@/%@.mp3",
			directoryPath,[RCTool md5:ttsUrl]];
}

+ (NSString*)getTTSTempPath:(NSString*)ttsUrl
{
    if(0 == [ttsUrl length])
		return nil;
    
    NSString* directoryPath = [[RCTool getUserDocumentDirectoryPath] stringByAppendingString:@"/tts"];
    if(NO == [RCTool isExistingFile:directoryPath])
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
	
	return [NSString stringWithFormat:@"%@/%@_temp",
			directoryPath,[RCTool md5:ttsUrl]];
}

+ (NSString*)getTTSSumLengthFilePath:(NSString*)ttsUrl
{
	if(0 == [ttsUrl length])
		return nil;
	
    NSString* directoryPath = [[RCTool getUserDocumentDirectoryPath] stringByAppendingString:@"/tts"];
    
	return [NSString stringWithFormat:@"%@/%@_sumlength",
			directoryPath,[RCTool md5:ttsUrl]];
}

+ (void)removeTTSFile:(NSString*)ttsUrl
{
    if(0 == [ttsUrl length])
		return;
    
    NSString* temp = [RCTool getTTSPath:ttsUrl];
    [RCTool removeFile:temp];
    
    temp = [RCTool getTTSTempPath:ttsUrl];
    [RCTool removeFile:temp];
    
    temp = [RCTool getTTSSumLengthFilePath:ttsUrl];
    [RCTool removeFile:temp];
}

+ (void)playTTS:(NSString*)ttsUrl
{
    NSString* ttsPath = nil;
    if([ttsUrl hasPrefix:@"http"])
        ttsPath = [RCTool getTTSPath:ttsUrl];
    else
        ttsPath = ttsUrl;
    
    if([RCTool isExistingFile:ttsPath])
    {
        //if(nil == _mp3Player)
        {
            AVAudioSession * sharedSession = [AVAudioSession sharedInstance];
            [sharedSession setCategory:AVAudioSessionCategoryPlayback error:NULL];
            [sharedSession setActive:YES error:NULL];
            
            AVAudioPlayer* mp3Player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:ttsPath]
                                                                              error:nil];
            
            //[_mp3Player stop];
            mp3Player.delegate = nil;
            mp3Player.volume = 1.0;
            [mp3Player prepareToPlay];
            [mp3Player play];
        }
        
        
    }
//    else if([ttsUrl hasPrefix:@"http"])
//    {
//
//    }
}

#pragma mark - Languages

+ (NSDictionary*)getLangaugeByCode:(NSString*)code
{
    if(0 == [code length])
        return nil;
    
    NSArray* languages = nil;
    if(nil == languages)
        languages = [RCTool getLanguages];
    
    for(NSDictionary* language in languages)
    {
        NSString* temp = [language objectForKey:@"code"];
        if([code isEqualToString:temp])
        {
            return language;
        }
    }
    
    return nil;
}

+ (NSArray*)getLanguages
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"languages" ofType:@"plist"];
    
    return [NSArray arrayWithContentsOfFile:path];
}

@end
