//
//  Translation.h
//  VoiceTranslator
//
//  Created by xuzepei on 6/19/13.
//  Copyright (c) 2013 xuzepei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Translation : NSManagedObject
{
    CGFloat _heightForCell;
}

@property (nonatomic, retain) NSString * fromCode;
@property (nonatomic, retain) NSString * toCode;
@property (nonatomic, retain) NSString * fromText;
@property (nonatomic, retain) NSString * toText;
@property (nonatomic, retain) NSString * fromVoice;
@property (nonatomic, retain) NSString * toVoice;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * isHidden;
@property (nonatomic, retain) NSNumber * align;
@property (nonatomic, retain) NSNumber * isLoading;
@property (nonatomic, retain) NSString * textUrl;
@property (nonatomic, retain) NSString * ttsUrl;
@property (nonatomic, retain) NSNumber * showTime;
@property (assign)BOOL isExisting;

- (CGFloat)getHeightForCell:(BOOL)redo;
- (CGSize)getFromTextSize;
- (CGSize)getToTextSize;
- (CGSize)getFromBubbleSize;
- (CGSize)getToBubbleSize;
- (UIFont*)fontForType:(BUBBLE_FONT_TYPE)type;

@end
