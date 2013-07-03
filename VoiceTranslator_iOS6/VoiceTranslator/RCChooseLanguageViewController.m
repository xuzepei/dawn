//
//  RCChooseLanguageViewController.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/19/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCChooseLanguageViewController.h"
#import "RCTool.h"

@interface RCChooseLanguageViewController ()

@end

@implementation RCChooseLanguageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _itemArray = [[NSMutableArray alloc] init];
        [_itemArray addObjectsFromArray:[RCTool getLanguages]];

        self.title = NSLocalizedString(@"Choose Language", @"");
    }
    
    return self;
}

- (void)dealloc
{
    NSLog(@"%s",__FUNCTION__);
    
    self.tableView = nil;
    self.itemArray = nil;
    self.chosenLanguageCode = nil;
    
    [super dealloc];
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

- (void)updateContent:(CHOOSE_LANGUAGE_TYPE)type
{
    self.type = type;
    
    if(CLT_LEFT == self.type)
        self.chosenLanguageCode = [RCTool getLeftLanguage];
    else if(CLT_RIGHT == self.type)
        self.chosenLanguageCode = [RCTool getRightLanguage];
    
    if(_tableView)
        [_tableView reloadData];
}

#pragma mark - UITableView

- (void)initTableView
{
    if(nil == _tableView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
        UITableViewStyle style = UITableViewStyleGrouped;
//        if([RCTool systemVersion] >= 7.0)
//        {
//            height = [RCTool getScreenSize].height;
//            style = UITableViewStylePlain;
//        }
        
        _tableView = [[UITableView alloc] initWithFrame: CGRectMake(0,0,[RCTool getScreenSize].width,height)
                                                  style:style];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
	
    [_tableView reloadData];
	[self.view addSubview:_tableView];
}

- (NSDictionary*)getItemByIndex:(int)index
{
    if(index < [_itemArray count])
        return [_itemArray objectAtIndex:index];
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *cellId = @"cellId";
	
	UITableViewCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if(nil == cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                       reuseIdentifier: cellId] autorelease];
    }
    
    
    NSDictionary* language = [self getItemByIndex:indexPath.row];
    if(language)
    {
        NSString* code = [language objectForKey:@"code"];
        NSString* imageName = [NSString stringWithFormat:@"flag_%@",code];
        UIImage* image = [RCTool createImage:imageName];
        cell.imageView.image = image;
        [image release];
        cell.textLabel.text = [language objectForKey:@"name"];
        
        if([code isEqualToString:self.chosenLanguageCode])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
    
    NSDictionary* language = [self getItemByIndex:indexPath.row];
    if(language)
    {
        self.chosenLanguageCode = [language objectForKey:@"code"];
        
        if(CLT_LEFT == self.type)
            [RCTool setLeftLanguage:self.chosenLanguageCode];
        else if(CLT_RIGHT == self.type)
            [RCTool setRightLanguage:self.chosenLanguageCode];
        
        [_tableView reloadData];
    }
}

@end
