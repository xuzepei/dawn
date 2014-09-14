//
//  RCSwitchCell.m
//  VoiceTranslator
//
//  Created by xuzepei on 6/18/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCSwitchCell.h"
#import "RCTool.h"

@implementation RCSwitchCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		_switcher = [[UISwitch alloc] initWithFrame:CGRectMake(206,10,80,40)];
		[_switcher addTarget:self
					action:@selector(switchValueDidChange:)
		  forControlEvents:UIControlEventValueChanged];
		
        self.accessoryView = _switcher;
		
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	
	self.switcher = nil;
    
    [super dealloc];
}

- (void)switchValueDidChange:(id)sender
{
    if(SWT_DETECTEND == self.type)
        [RCTool setDetectEnd:_switcher.on];
    else if(SWT_AUTOSPEAK == self.type)
        [RCTool setAutoSpeak:_switcher.on];
}

- (void)updateContent:(SWITCH_TYPE)type
{
    self.type = type;

    if(SWT_DETECTEND == self.type)
    {
        _switcher.on = [RCTool getDectectEnd];
    }
    else if(SWT_AUTOSPEAK == self.type)
    {
        _switcher.on = [RCTool getAutoSpeak];
    }
    
}

@end
