//
//  RCSettingViewController.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/18/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface RCSettingViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,MFMailComposeViewControllerDelegate>

@property(nonatomic,retain)UITableView* tableView;
@property(nonatomic,retain)NSMutableArray* itemArray;


@end
