//
//  RCTool.h
//  rsscoffee
//
//  Created by beer on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCTool : NSObject {

}

+ (BOOL)checkCrackedApp;
+ (NSString*)getUserDocumentDirectoryPath;
+ (NSString *)md5:(NSString *)str;
+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
+ (UIColor*)colorWithHex:(NSInteger)hexValue;
+ (UIWindow*)frontWindow;
+ (NSDictionary*)parseToDictionary:(NSString*)jsonString;

+ (void)showAlert:(NSString*)aTitle message:(NSString*)message;
+ (void)hidenWebViewShadow:(UIWebView*)webView;
+ (NSString*)getDateString:(NSDate*)date;
//播放音效
+ (void)playSound:(NSString*)filename;

+ (NSString*)createBody:(NSDictionary*)dict;
+ (NSDictionary*)parseToDetail:(NSString*)jsonString;

+ (void)showIndicator:(NSString*)text view:(UIView*)addedToView;
+ (void)hideIndicator:(UIView*)addedToView;


#pragma mark In-App Purchase

+ (void)setRemoveAD:(BOOL)b;
+ (BOOL)isRemoveAD;

#pragma mark - Network

+ (void)setReachabilityType:(int)type;
+ (int)getReachabilityType;
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaInternet;

#pragma mark - Core Data

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator;
+ (NSManagedObjectContext*)getManagedObjectContext;
+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context;

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors;

+ (id)insertEntityObjectForName:(NSString*)entityName 
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID 
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (void)saveCoreData;

+ (void)deleteOldData;

+ (NSArray*)getAllTranslations;

#pragma mark - 兼容iOS6和iPhone5

+ (CGSize)getScreenSize;

+ (CGRect)getScreenRect;

+ (BOOL)isIphone5;

+ (CGFloat)systemVersion;

#pragma mark - 文件相关操作

+ (NSString*)getRecordFilePath:(NSString*)filename;
+ (BOOL)isExistingFile:(NSString*)filePath;
+ (void)removeFile:(NSString*)filePath;
+ (NSString*)createRecordFilename;

#pragma mark - UserDefault

+ (void)setLeftLanguage:(NSString*)language;
+ (NSString*)getLeftLanguage;

+ (void)setRightLanguage:(NSString*)language;
+ (NSString*)getRightLanguage;

+ (void)setDetectEnd:(BOOL)b;
+ (BOOL)getDectectEnd;

+ (void)setAutoSpeak:(BOOL)b;
+ (BOOL)getAutoSpeak;

+ (void)setShowHintMask:(BOOL)b;
+ (BOOL)getShowHintMask;

+ (void)setShowTipLabel:(BOOL)b;
+ (BOOL)getShowTipLabel;

+ (void)setVolume:(CGFloat)volume;
+ (CGFloat)getVolume;

+ (void)setSpeed:(CGFloat)speed;
+ (CGFloat)getSpeed;



#pragma mark - 解析数据
+ (NSDictionary*)parseJSON:(NSString*)jsonString;

#pragma mark - TTS文件下载与保存
+ (BOOL)isSupportedTTS:(NSString*)code;
+ (NSString*)getTTSUrl:(NSString*)code text:(NSString*)text;
+ (NSString*)getTTSPath:(NSString*)ttsUrl;
+ (NSString*)getTTSTempPath:(NSString*)ttsUrl;
+ (NSString*)getTTSSumLengthFilePath:(NSString*)ttsUrl;
+ (void)removeTTSFile:(NSString*)ttsUrl;
+ (void)playTTS:(NSString*)ttsUrl;

#pragma mark - Languages

+ (NSDictionary*)getLanguagesDictionary;
+ (NSDictionary*)getLangaugeByCode:(NSString*)code;
+ (NSArray*)getLanguages:(BOOL)needSort;
+ (BOOL)needSetTextRightAlignment:(NSString*)code;


#pragma mark - App Info

+ (NSString*)getAdId;
+ (NSString*)getScreenAdId;
+ (int)getScreenAdRate;
+ (NSString*)getAppURL;
+ (BOOL)isOpenAll;
+ (UIView*)getAdView;
+ (NSString*)decrypt:(NSString*)text;

@end
