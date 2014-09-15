//
//  RCSettingViewController.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/18/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCSettingViewController.h"
#import "RCTool.h"
#import "RCSwitchCell.h"
#import "RCChooseLanguageViewController.h"
#import "RCHelpViewController.h"
#import "RCSliderCell.h"
#import "RCImageLoader.h"

#define CLEAR_TAG 200
#define PURCHASE_TAG 201
#define REMOVE_AD_ID @"20130817"

typedef enum {
    ST_LANGUAGE = 0,
	ST_VOICE,
    ST_VOLUME,
    ST_CLEANUP,
    ST_OTHERAPP,
    ST_PURCHASE,
    ST_HELP,
}SettingType;

@interface RCSettingViewController ()

@end

@implementation RCSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _itemArray = [[NSMutableArray alloc] init];
        
        UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(clickedRightBarButtonItem:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        [rightBarButtonItem release];
        
        self.title = NSLocalizedString(@"Settings", @"");
    }
    
    return self;
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    self.productsRequest.delegate = nil;
    self.productsRequest = nil;
    
    self.tableView = nil;
    self.itemArray = nil;
    self.products = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_tableView)
        [_tableView reloadData];
    
    if([self checkEnableIAP] && nil == self.removeAdProduct)
        [self requestProductData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initTableView];
    
//    if([self checkEnableIAP])
//    {
//        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//        [self requestProductData];
//    }
    
    //[self.navigationController.navigationBar setTintColor:APP_TINT_COLOR];
    
    [self requestContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickedRightBarButtonItem:(id)sender
{
    NSLog(@"clickedRightBarButtonItem");
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)requestContent
{
    if(nil == _otherApps)
        _otherApps = [[NSMutableArray alloc] init];
    
    [_otherApps removeAllObjects];
    
    NSArray* otherApps = [RCTool getOtherApps];
    if([otherApps count])
        [_otherApps addObjectsFromArray:otherApps];
    
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (void)initTableView
{
    if(nil == _tableView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            height = [RCTool getScreenSize].height;
        
        _tableView = [[UITableView alloc] initWithFrame: CGRectMake(0,0,[RCTool getScreenSize].width,height)
                                                  style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
	
    [_tableView reloadData];
	[self.view addSubview:_tableView];
}

- (id)getCellDataAtIndexPath:(NSIndexPath*)indexPath
{
    if(ST_OTHERAPP == indexPath.section)
    {
        if(indexPath.row < [_otherApps count])
            return [_otherApps objectAtIndex: indexPath.row];
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([_otherApps count])
        return 5;
    
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(ST_LANGUAGE == section)
	{
		return NSLocalizedString(@"Languages", @"");
	}
	else if(ST_VOICE == section)
	{
		return NSLocalizedString(@"Voice", @"");
	}
    else if(ST_VOLUME == section)
	{
		return NSLocalizedString(@"Volume & Speed", @"");
	}
	else if(ST_CLEANUP == section)
	{
		return NSLocalizedString(@"Clear", @"");
	}
    else if(ST_PURCHASE == section)
	{
		return NSLocalizedString(@"Purchase", @"");
	}
    else if(ST_HELP == section)
    {
        return NSLocalizedString(@"Help", @"");
    }
    else if(ST_OTHERAPP == section)
    {
        return NSLocalizedString(@"Featured Apps", @"");
    }
    
	return @"";
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(ST_LANGUAGE == section)
		return 2;
	else if(ST_VOICE == section)
		return 1;
    else if(ST_VOLUME == section)
		return 2;
	else if(ST_CLEANUP == section)
		return 1;
    else if(ST_PURCHASE == section)
		return 1;
    else if(ST_HELP == section)
		return 1;
    else if(ST_OTHERAPP == section)
        return [_otherApps count];
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(ST_OTHERAPP == indexPath.section)
    {
        if([RCTool isIpad])
        {
            return 70.0f;
        }
        else{
            return 60.0f;
        }
    }
    
	return 50.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellId = @"cellId";
    static NSString *cellId1 = @"cellId1";
	static NSString *cellId2 = @"cellId2";
	static NSString *cellId3 = @"cellId3";
	static NSString *cellId4 = @"cellId4";
    static NSString *cellId5 = @"cellId5";
    static NSString *cellId6 = @"cellId6";
    static NSString *cellId7 = @"cellId7";
    static NSString *cellId8 = @"cellId8";
	
	UITableViewCell *cell = nil;
	if(ST_LANGUAGE == indexPath.section)
	{
		if(0 == indexPath.row)
		{
			cell = [tableView dequeueReusableCellWithIdentifier:cellId];
			if(nil == cell)
			{
				cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                               reuseIdentifier: cellId] autorelease];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                cell.detailTextLabel.text = @"Translate from";
                cell.detailTextLabel.textColor = [UIColor grayColor];
			}
            
            
            NSString* code = [RCTool getLeftLanguage];
            NSDictionary* language = [RCTool getLangaugeByCode:code];
            NSString* imageName = [NSString stringWithFormat:@"flag_%@",code];
            
            UIImage* image = [UIImage imageNamed:imageName];
            cell.imageView.image = image;
            
            NSString* name = [language objectForKey:@"name"];
            cell.textLabel.text = name; 
		}
        else if(1 == indexPath.row)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellId1];
			if(nil == cell)
			{
				cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                               reuseIdentifier: cellId1] autorelease];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

                cell.detailTextLabel.text = @"Translate to";
                cell.detailTextLabel.textColor = [UIColor grayColor];
			}
            
            NSString* code = [RCTool getRightLanguage];
            NSDictionary* language = [RCTool getLangaugeByCode:code];
            NSString* imageName = [NSString stringWithFormat:@"flag_%@",code];
            
            UIImage* image = [UIImage imageNamed:imageName];
            cell.imageView.image = image;
            
            cell.textLabel.text = [language objectForKey:@"name"];
            
        }
		
	}
	else if(ST_VOICE == indexPath.section)
	{
		{
			cell = [tableView dequeueReusableCellWithIdentifier:cellId3];
			if (cell == nil)
			{
				cell = [[[RCSwitchCell alloc] initWithStyle: UITableViewCellStyleDefault
                                            reuseIdentifier: cellId3] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = @"Auto Speak";
			}
			
			RCSwitchCell* temp = (RCSwitchCell*)cell;
			[temp updateContent:SWT_AUTOSPEAK];
		}
	}
    else if(ST_VOLUME == indexPath.section)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:cellId6];
        if (cell == nil)
        {
            cell = [[[RCSliderCell alloc] initWithStyle: UITableViewCellStyleDefault
                                        reuseIdentifier: cellId6] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        RCSliderCell* temp = (RCSliderCell*)cell;
        if(0 == indexPath.row)
            [temp updateContent:SLT_VOLUME];
        else if(1 == indexPath.row)
            [temp updateContent:SLT_SPEED];
	}
	else if(ST_CLEANUP == indexPath.section)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:cellId4];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: cellId4] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.textLabel.text = NSLocalizedString(@"Clear History",@"");
        }
	}
    else if(ST_PURCHASE == indexPath.section)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:cellId7];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: cellId7] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            if(self.removeAdProduct)
            {
                cell.textLabel.text = self.removeAdProduct.localizedTitle;
            }
            else
            {
                cell.textLabel.text = NSLocalizedString(@"Remove Advertisement",@"");
            }
            
            cell.imageView.image = [UIImage imageNamed:@"adblock"];
        }
	}
    else if(ST_HELP == indexPath.section)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:cellId5];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: cellId5] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if(0 == indexPath.row)
        {
            cell.textLabel.text = NSLocalizedString(@"Help",@"");
        }
        else if(1 == indexPath.row)
        {
            
            cell.textLabel.text = NSLocalizedString(@"Feedback",@"");
        }
	}
    else if(ST_OTHERAPP == indexPath.section)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId8];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                           reuseIdentifier: cellId8] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
        
        NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath:indexPath];
        if(item)
        {
            cell.textLabel.text = [item objectForKey:@"name"];
            cell.detailTextLabel.text = [item objectForKey:@"desc"];
            
            NSString* imageUrl = [item objectForKey:@"img_url"];
            if([imageUrl length])
            {
                UIImage* image = [RCTool getImageFromLocal:imageUrl];
                if(image)
                {
                    image = [RCTool imageWithImage:image scaledToSize:CGSizeMake(40.0, 40.0)];
                    cell.imageView.image = image;
                }
                else
                {
                    [[RCImageLoader sharedInstance] saveImage:imageUrl
                                                     delegate:self
                                                        token:nil];
                }
            }
        }
    }
    
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if(ST_LANGUAGE == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            RCChooseLanguageViewController* temp = [[RCChooseLanguageViewController alloc] initWithNibName:nil bundle:nil];
            [temp updateContent:CLT_LEFT];
            [self.navigationController pushViewController:temp animated:YES];
            [temp release];
        }
        else if(1 == indexPath.row)
        {
            RCChooseLanguageViewController* temp = [[RCChooseLanguageViewController alloc] initWithNibName:nil bundle:nil];
            [temp updateContent:CLT_RIGHT];
            [self.navigationController pushViewController:temp animated:YES];
            [temp release];
        }
    }
    else if(ST_CLEANUP == indexPath.section)
    { 
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Are you sure clear all translation history?"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:@"Clear Up"
                                                         otherButtonTitles:nil]autorelease];
        actionSheet.delegate = self;
        actionSheet.tag = CLEAR_TAG;
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.view];
        
    }
    else if(ST_PURCHASE == indexPath.section)
    {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Remove Advertisement"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:@"Purchase",@"Restore Previous Purchase",nil]autorelease];
        actionSheet.delegate = self;
        actionSheet.tag = PURCHASE_TAG;
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.view];
    }
    else if(ST_HELP == indexPath.section)
    {
        if(0 == indexPath.row)
        {

            RCHelpViewController* temp = [[RCHelpViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:temp animated:YES];
            [temp release];
        }
        else if(1 == indexPath.row)
        {

            [self feedback];
        }
    }
    else if(ST_OTHERAPP == indexPath.section)
    {
        NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath:indexPath];
        if(item)
        {
            NSString* urlString = [item objectForKey:@"url"];
            if([urlString length])
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    actionSheet.delegate = nil;
    
    if(CLEAR_TAG == actionSheet.tag)
    {
        if(0 == buttonIndex)
        {

            NSLog(@"clear up");
            [[NSNotificationCenter defaultCenter] postNotificationName:CLEAR_UP_NOTIFICATION object:nil];
            [RCTool deleteOldData];
        }
    }
    else if(PURCHASE_TAG == actionSheet.tag)
    {
        if(0 == buttonIndex)
        {
            [self buyProduct:self.removeAdProduct];
        }
        else
        {
            [self restoreProduct];
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    NSLog(@"%s",__FUNCTION__);
    actionSheet.delegate = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"%s,%d",__FUNCTION__,[actionSheet retainCount]);
    actionSheet.delegate = nil;
}

- (void)feedback
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
            mailComposeViewController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
            mailComposeViewController.mailComposeDelegate = self;
            
            
            NSMutableString* subject = [[[NSMutableString alloc] init] autorelease];
            [subject appendString:@"Feedback from iTranslate 2"];
            [subject appendFormat:@", v%.2f",APP_VERSION];
            [subject appendFormat:@", iOS %.2f",[RCTool systemVersion]];
            
            [subject appendFormat:@", device type %d",UI_USER_INTERFACE_IDIOM()];
            
            [mailComposeViewController setSubject:subject];
            
            [mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"intelligentapps@gmail.com"]];
            
            NSMutableString *mailContent = [[NSMutableString alloc] init];
            [mailContent appendString:@"If you have any suggestions, questions or need some help, just write us here. We are always happy to help you as soon as possible."];
            
            [mailComposeViewController setMessageBody:mailContent isHTML:NO];
            [mailContent release];
            [self presentViewController:mailComposeViewController animated:YES completion:nil];
            [mailComposeViewController release];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{

    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if(MFMailComposeResultSent == result)
    {
        [RCTool showAlert:@"Hint" message:@"Send email successfully."];
    }
}

#pragma mark - In App Purchase

- (BOOL)checkEnableIAP
{
    if([SKPaymentQueue canMakePayments])
    {
        return YES;
    }
    
    return NO;
}

- (void)requestProductData
{
    if(nil == _productsRequest)
    {
        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObjects:REMOVE_AD_ID,nil]];
    }
    
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.products = response.products;
    
    for(SKProduct* product in self.products)
    {
        if([product.productIdentifier isEqualToString:REMOVE_AD_ID])
        {
            self.removeAdProduct = product;
            break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)buyProduct:(SKProduct*)product
{
    if(self.isPaying)
        return;
    
    if(nil == product)
    {
        if([self checkEnableIAP] && nil == self.removeAdProduct)
            [self requestProductData];
        
        [RCTool showAlert:@"Hint" message:@"No product for purchase!"];
        return;
    }
    
    if(NO == [self checkEnableIAP])
    {
        [RCTool showAlert:@"Hint" message:@"Please enable In-App Purchase first!"];
        return;
    }
    
    //[RCTool showIndicator:@"Loading..." view:self.view];
    self.isPaying = YES;

    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreProduct
{
    if(self.isPaying)
        return;
    
    self.isPaying = YES;
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    self.isPaying = NO;
    NSLog(@"paymentQueueRestoreCompletedTransactionsFinished");
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    self.isPaying = NO;
    NSLog(@"restoreCompletedTransactionsFailedWithError");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
            {
                break;
            }
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"completeTransaction");
    
    self.isPaying = NO;
    [RCTool hideIndicator:self.view];
    
    if(transaction.transactionState == SKPaymentTransactionStatePurchased)
    {
        if(transaction.transactionReceipt)
        {
            if([transaction.payment.productIdentifier isEqualToString:REMOVE_AD_ID])
            {
                NSDate* date = [NSDate date];
                NSTimeInterval now = [date timeIntervalSince1970];
                NSTimeInterval transactionDateTimeInterval = [transaction.transactionDate timeIntervalSince1970];
                
                NSTimeInterval temp = now - transactionDateTimeInterval;
                if(temp && temp < 1*7*24*60*60)
                {
                    [RCTool setRemoveAD:YES];
                    [RCTool showAlert:@"Purchase Successfully" message:@"The advertisement has been removed."];
                }
            }
        }
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"restoreTransaction");
    
    self.isPaying = NO;
    [RCTool hideIndicator:self.view];
    
    if([transaction.payment.productIdentifier isEqualToString:REMOVE_AD_ID])
    {
        [RCTool setRemoveAD:YES];
        [RCTool showAlert:@"Restore Purchase Successfully" message:@"The advertisement has been removed."];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"failedTransaction");
    
    self.isPaying = NO;
    [RCTool hideIndicator:self.view];
    
    if(transaction.error.code != SKErrorPaymentCancelled){
        // Optionally, display an error here.
        
        NSString* temp = [NSString stringWithFormat:@"%@",[transaction.error localizedDescription]];
        [RCTool showAlert:@"Payment Failed" message:temp];
    }
    
    NSLog(@"transaction.error.code:%d",transaction.error.code);
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}


@end
