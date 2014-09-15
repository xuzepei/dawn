//
//  RCSettingViewController.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/18/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <StoreKit/StoreKit.h>

@interface RCSettingViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property(nonatomic,retain)UITableView* tableView;
@property(nonatomic,retain)NSMutableArray* itemArray;
@property(nonatomic,retain)NSArray* products;
@property(nonatomic,retain)SKProduct* removeAdProduct;
@property(assign)BOOL isPaying;
@property(nonatomic,retain)SKProductsRequest *productsRequest;
@property(nonatomic,strong)NSMutableArray* otherApps;

@end
