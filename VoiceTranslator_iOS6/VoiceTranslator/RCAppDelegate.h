//
//  RCAppDelegate.h
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTranslatorViewController.h"

@interface RCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic,strong)RCTranslatorViewController* translatorViewController;
@property (nonatomic,strong)UINavigationController* translatorNavigationController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
