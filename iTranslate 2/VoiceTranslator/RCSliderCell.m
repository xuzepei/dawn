//
//  RCSliderCell.m
//  VoiceTranslator
//
//  Created by xuzepei on 7/4/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import "RCSliderCell.h"
#import "RCTool.h"

@implementation RCSliderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		_slider = [[UISlider alloc] initWithFrame:CGRectMake(100,0,[RCTool getScreenSize].width - 120,44)];
        [self addSubview:_slider];
        
        [_slider addTarget:self
					action:@selector(progressDidChange:)
		  forControlEvents:UIControlEventValueChanged];	
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	
	self.slider = nil;
    
    [super dealloc];
}

- (void)updateContent:(SLIDER_TYPE)type
{
    self.type = type;
    
    if(SLT_VOLUME == self.type)
    {
        self.textLabel.text = @"Volume";
        _slider.minimumValue = 0.0;
        _slider.maximumValue = 1.0;
        _slider.value = [RCTool getVolume];
    }
    else if(SLT_SPEED == self.type)
    {
        self.textLabel.text = @"Speed";
        _slider.minimumValue = 0.0;
        _slider.maximumValue = 2.0;
        _slider.value = [RCTool getSpeed];
    }
    
}

- (IBAction)progressDidChange:(UISlider*)sender
{
    UISlider* slider = (UISlider*)sender;
    
    if(SLT_VOLUME == self.type)
    {
        [RCTool setVolume:slider.value];
    }
    else if(SLT_SPEED == self.type)
    {
        [RCTool setSpeed:slider.value];
    }
}

@end
