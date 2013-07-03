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

#define CLEAR_TAG 200

typedef enum {
    ST_LANGUAGE = 0,
	ST_VOICE,
    ST_CLEANUP,
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
    NSLog(@"%s",__FUNCTION__);
    
    self.tableView = nil;
    self.itemArray = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(_tableView)
        [_tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self initTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickedRightBarButtonItem:(id)sender
{
    NSLog(@"clickedRightBarButtonItem");
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITableView

- (void)initTableView
{
    if(nil == _tableView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
        //        if([RCTool systemVersion] >= 7.0)
        //            height = [RCTool getScreenSize].height;
        
        _tableView = [[UITableView alloc] initWithFrame: CGRectMake(0,0,[RCTool getScreenSize].width,height)
                                                  style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
	
    [_tableView reloadData];
	[self.view addSubview:_tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
	else if(ST_CLEANUP == section)
	{
		return NSLocalizedString(@"Clear", @"");
	}
    else if(ST_HELP == section)
    {
        return NSLocalizedString(@"Help", @"");
    }
    
	return @"";
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(ST_LANGUAGE == section)
		return 2;
	else if(ST_VOICE == section)
		return 2;
	else if(ST_CLEANUP == section)
		return 1;
    else if(ST_HELP == section)
		return 2;
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellId = @"cellId";
    static NSString *cellId1 = @"cellId1";
	static NSString *cellId2 = @"cellId2";
	static NSString *cellId3 = @"cellId3";
	static NSString *cellId4 = @"cellId4";
    static NSString *cellId5 = @"cellId5";
	
	UITableViewCell *cell = nil;
	if(ST_LANGUAGE == indexPath.section)
	{
		if(0 == indexPath.row)
		{
			cell = [tableView dequeueReusableCellWithIdentifier:cellId];
			if(nil == cell)
			{
				cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                               reuseIdentifier: cellId] autorelease];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            
            
            NSString* code = [RCTool getLeftLanguage];
            NSDictionary* language = [RCTool getLangaugeByCode:code];
            NSString* imageName = [NSString stringWithFormat:@"flag_%@",code];
            
            UIImage* image = [RCTool createImage:imageName];
            cell.imageView.image = image;
            [image release];
            
            cell.textLabel.text = [language objectForKey:@"name"];
		}
        else if(1 == indexPath.row)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:cellId1];
			if(nil == cell)
			{
				cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                               reuseIdentifier: cellId1] autorelease];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            
            NSString* code = [RCTool getRightLanguage];
            NSDictionary* language = [RCTool getLangaugeByCode:code];
            NSString* imageName = [NSString stringWithFormat:@"flag_%@",code];
            
            UIImage* image = [RCTool createImage:imageName];
            cell.imageView.image = image;
            [image release];
            
            cell.textLabel.text = [language objectForKey:@"name"];
        }
		
	}
	else if(ST_VOICE == indexPath.section)
	{
        if(0 == indexPath.row)
		{
			cell = [tableView dequeueReusableCellWithIdentifier:cellId2];
			if (cell == nil)
			{
				cell = [[[RCSwitchCell alloc] initWithStyle: UITableViewCellStyleDefault
                                            reuseIdentifier: cellId2] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = @"Detect End of Speech";
			}
			
			RCSwitchCell* temp = (RCSwitchCell*)cell;
			[temp updateContent:SWT_DETECTEND];
		}
		else if(1 == indexPath.row)
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
	else if(ST_CLEANUP == indexPath.section)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:cellId4];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: cellId4] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.textLabel.text = NSLocalizedString(@"Clear Translation History",@"");
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
    
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    if(0 == indexPath.section)//Languages
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
    else if(2 == indexPath.section)//Clear history
    {
        UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:@""
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:@"Clear Up"
                                                         otherButtonTitles:nil]autorelease];
        actionSheet.delegate = self;
        actionSheet.tag = CLEAR_TAG;
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.view];
        //[actionSheet release];
        
    }
    else if(3 == indexPath.section)
    {
        if( 0 == indexPath.row)
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
            [subject appendString:@"Feedback from Voice Translate "];
            [subject appendFormat:@"%.2f",APP_VERSION];
            [subject appendFormat:@", iOS %.2f",[RCTool systemVersion]];
            
            [mailComposeViewController setSubject:subject];
            
            [mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"intelligentapps@gmail.com"]];
            
            NSMutableString *mailContent = [[NSMutableString alloc] init];
            [mailContent appendString:@"If you have any question, please let us know. Thanks."];
            
            [mailComposeViewController setMessageBody:mailContent isHTML:NO];
            [mailContent release];
            [self presentModalViewController:mailComposeViewController animated:YES];
            [mailComposeViewController release];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
    
    if(MFMailComposeResultSent == result)
    {
        [RCTool showAlert:@"Hint" message:@"Send email successfully."];
    }
}

@end
