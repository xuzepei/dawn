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
+ (UIWindow*)frontWindow;
+ (void)showAlert:(NSString*)aTitle message:(NSString*)message;
+ (void)hidenWebViewShadow:(UIWebView*)webView;
+ (NSString*)getDateString:(NSDate*)date;
//播放音效
+ (void)playSound:(NSString*)filename;
+ (UIImage*)createImage:(NSString*)imageName;

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

+ (BOOL)setShowHintMask:(BOOL)b;
+ (BOOL)getShowHintMask;


#pragma mark - 解析数据
+ (NSDictionary*)parseJSON:(NSString*)jsonString;

#pragma mark - TTS文件下载与保存

+ (NSString*)getTTSUrl:(NSString*)code text:(NSString*)text;
+ (NSString*)getTTSPath:(NSString*)ttsUrl;
+ (NSString*)getTTSTempPath:(NSString*)ttsUrl;
+ (NSString*)getTTSSumLengthFilePath:(NSString*)ttsUrl;
+ (void)removeTTSFile:(NSString*)ttsUrl;
+ (void)playTTS:(NSString*)ttsUrl;

#pragma mark - Languages

+ (NSDictionary*)getLangaugeByCode:(NSString*)code;
+ (NSArray*)getLanguages;

@end