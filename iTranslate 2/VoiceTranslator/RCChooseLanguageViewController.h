//
//  RCChooseLanguageViewController.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/19/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCChooseLanguageViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,retain)UITableView* tableView;
@property(nonatomic,retain)NSMutableArray* itemArray;
@property(assign)CHOOSE_LANGUAGE_TYPE type;
@property(nonatomic,retain)NSString* chosenLanguageCode;

- (void)updateContent:(CHOOSE_LANGUAGE_TYPE)type;

@end
