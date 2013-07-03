//
//  RCTranslateProcess.m
//  VoiceTranslator
//
//  Created by xuzepei on 12/6/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import "RCTranslateProcess.h"
#import "RCTool.h"
#import "ASIHTTPRequest.h"


@implementation RCTranslateProcess

+ (RCTranslateProcess*)sharedInstance
{
	static RCTranslateProcess* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([RCTranslateProcess class])
		{
            if(nil == sharedInstance)
                sharedInstance = [[RCTranslateProcess alloc] init];
		}
	}
	
	return sharedInstance;
}

- (void)dealloc
{
    self.recordFilePath = nil;
    self.fromLanguage = nil;
    self.toLanguage = nil;
    self.delegate = nil;
    
    self.translateVoiceHttpRequest = nil;
    self.translateTextHttpRequest = nil;
    self.ttsHttpRequest = nil;
    self.token = nil;
    
    [super dealloc];
}

- (BOOL)translate:(NSString*)recordFilePath fromLanguage:(NSString*)fromLanguage toLanguage:(NSString*)toLanguage delegate:(id)delegate token:(NSDictionary*)token
{
    if(self.isTranslating || 0 == [fromLanguage length] || 0 == [toLanguage length] || nil == delegate)
        return NO;
    
    if(NO == [RCTool isExistingFile:recordFilePath])
        return NO;
    
    self.recordFilePath = recordFilePath;
    self.fromLanguage = fromLanguage;
    self.toLanguage = toLanguage;
    self.delegate = delegate;
    self.token = token;
    
    if(_translateVoiceHttpRequest)
    {
        [_translateVoiceHttpRequest cancel];
        self.translateTextHttpRequest = nil;
    }
    
    _translateVoiceHttpRequest = [[RCTranslateVoiceHttpRequest alloc] init];
    
    NSString* urlString = [NSString stringWithFormat:@"http://www.google.com/speech-api/v1/recognize?xjerr=1&client=chromium&lang=%@&maxresults=1",self.fromLanguage];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.fromLanguage,@"from_language",self.toLanguage,@"to_language",nil];
    if(token)
        [dict addEntriesFromDictionary:token];
    
    BOOL b = [_translateVoiceHttpRequest request:urlString delegate:self token:dict];
    
    if(b)
        self.isTranslating = YES;
    
    return b;
}

#pragma mark - RCTranslateVoiceHttpRequestDelegate

- (void) willStartTranslateVoiceHttpRequest: (id)token
{
    if(_delegate && [_delegate respondsToSelector: @selector(willStartTranslateProcess:)])
        [_delegate willStartTranslateProcess:token];
}

- (void) didFinishTranslateVoiceHttpRequest: (id)result token: (id)token
{
    NSLog(@"didFinishTranslateVoiceHttpRequest");
    
    NSDictionary* data = (NSDictionary*)result;
    NSDictionary* tokenDict = (NSDictionary*)token;
    NSLog(@"data:%@",data);
    
    int errorType = ET_UNKNOWN;
    if(data)
    {
        NSArray* hypotheses = [data objectForKey:@"hypotheses"];
        if(hypotheses && [hypotheses isKindOfClass:[NSArray class]] && [hypotheses count])
        {
            NSDictionary* result = [hypotheses objectAtIndex:0];
            if(result)
            {
                NSString* text = [result objectForKey:@"utterance"];
                
                NSLog(@"text:%@",text);
                
                if([text length] && tokenDict)
                {
                    Translation* translation = [RCTool insertEntityObjectForName:@"Translation" managedObjectContext:[RCTool getManagedObjectContext]];
                    if(translation)
                    {
                        NSDate* date = [NSDate date];
                        NSTimeInterval interval = [date timeIntervalSince1970];
                        translation.time = [NSNumber numberWithDouble:interval];
                        translation.fromCode = self.fromLanguage;
                        translation.toCode = self.toLanguage;
                        translation.fromVoice = self.recordFilePath;
                        translation.fromText = text;
                        translation.align = [self.token objectForKey:@"type"];
                    }
                    
                    BOOL b = [self translateText:translation delegate:self.delegate];
                    if(b)
                    {
                        return;
                    }
                }
            }
        }
        else
            errorType = ET_UTTERANCE;
        
    }
    
    
    self.isTranslating = NO;
    if(_delegate && [_delegate respondsToSelector: @selector(didFailTranslateProcess:token:)])
        [_delegate didFailTranslateProcess:errorType token:token];
    
}

- (void) didFailTranslateVoiceHttpRequest: (id)token
{
    NSLog(@"didFailTranslateVoiceHttpRequest");
    
    int errorType = ET_UNKNOWN;
    self.isTranslating = NO;
    if(_delegate && [_delegate respondsToSelector: @selector(didFailTranslateProcess:token:)])
        [_delegate didFailTranslateProcess:errorType token:token];
}


#pragma mark - RCTranslateTextHttpRequestDelegate

- (BOOL)translateText:(Translation*)translation delegate:(id)delegate
{
    self.delegate = delegate;
    
    if(_translateTextHttpRequest)
    {
        [_translateTextHttpRequest cancel];
        self.translateTextHttpRequest = nil;
    }
    
    _translateTextHttpRequest = [[RCTranslateTextHttpRequest alloc] init];
    
    NSString* urlString = [NSString stringWithFormat:@"http://translate.google.com/translate_a/t?text=%@&client=it&hl=en&ie=UTF-8&oe=UTF-8&sl=%@&tl=%@",translation.fromText,translation.fromCode,translation.toCode];
    
    return [_translateTextHttpRequest request:urlString delegate:self token:translation];
}

- (void) willStartTranslateTextHttpRequest: (id)token
{
    NSLog(@"willStartTranslateTextHttpRequest");
    
    if(_delegate && [_delegate respondsToSelector:@selector(didFinishedTranslateVoiceToText:)])
    {
        [_delegate didFinishedTranslateVoiceToText:token];
    }
}

- (void) didFinishTranslateTextHttpRequest: (id)result token: (id)token
{
    NSLog(@"didFinishTranslateTextHttpRequest");
    
    NSDictionary* data = (NSDictionary*)result;
    NSLog(@"data:%@",data);
    Translation* translation = (Translation*)token;
    
    int errorType = ET_UNKNOWN;
    if(data)
    {
        NSArray* sentences = [data objectForKey:@"sentences"];
        if(sentences && [sentences isKindOfClass:[NSArray class]] && [sentences count])
        {
            NSDictionary* result = [sentences objectAtIndex:0];
            if(result)
            {
                NSString* translatedText = [result objectForKey:@"trans"];
                
                NSLog(@"translatedText:%@",translatedText);
                
                if([translatedText length] && translation)
                {
                    if(_ttsHttpRequest)
                    {
                        [_ttsHttpRequest cancel];
                        self.ttsHttpRequest = nil;
                    }
                    
//                    NSString* urlString = [NSString stringWithFormat:@"http://translate.google.com/translate_tts?tl=%@&q=%@",translation.toCode,translatedText];
                    NSString* urlString = [RCTool getTTSUrl:translation.toCode text:translatedText];
//                    urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                    
                    translation.ttsUrl = urlString;
                    translation.toText = translatedText;
                    
                    NSString* ttsPath = [RCTool getTTSPath:urlString];
                    if([RCTool isExistingFile:ttsPath])
                    {
                        self.isTranslating = NO;
                        
                        if(_delegate && [_delegate respondsToSelector: @selector(didFinishTranslateProcess:token:)])
                        {
                            [_delegate didFinishTranslateProcess:nil token:translation];
                        }
                        
                        return;
                    }
                    
                    if(_delegate && [_delegate respondsToSelector:@selector(didFinishedTranslateFromText:)])
                    {
                        [_delegate didFinishedTranslateFromText:translation];
                    }
                    
                    [RCTool removeTTSFile:urlString];
                    [self requestTTS:urlString token:(NSDictionary*)translation];
                    
                    return;
                }
            }
        }
    }
    
    
    self.isTranslating = NO;
    if(_delegate && [_delegate respondsToSelector: @selector(didFailTranslateProcess:token:)])
        [_delegate didFailTranslateProcess:errorType token:token];
}

- (void) didFailTranslateTextHttpRequest: (id)token
{
    NSLog(@"didFailTranslateTextHttpRequest");
    
    if(_delegate && [_delegate respondsToSelector:@selector(didFailedTranslateFromText:)])
    {
        [_delegate didFailedTranslateFromText:token];
    }
    
    int errorType = ET_UNKNOWN;
    self.isTranslating = NO;
    if(_delegate && [_delegate respondsToSelector: @selector(didFailTranslateProcess:token:)])
        [_delegate didFailTranslateProcess:errorType token:token];
}


#pragma mark - Request TTS

- (void)requestTTS:(NSString*)urlString token:(NSDictionary*)token
{
    NSURL *url = [NSURL URLWithString:urlString];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    if(token)
        [request setUserInfo:token];
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
    [dict setObject:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31" forKey:@"User-Agent"];
    [request setRequestHeaders:dict];
    [request setDownloadDestinationPath:[RCTool getTTSPath:urlString]];
    [request startAsynchronous];
    
    NSLog(@"willStartTTSHttpRequest");
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    self.isTranslating = NO;
    NSDictionary* token = [request userInfo];
    if(_delegate && [_delegate respondsToSelector: @selector(didFinishTranslateProcess:token:)])
        [_delegate didFinishTranslateProcess:nil token:token];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"didFailTTSHttpRequest:error:%@",[error description]);
    
    int errorType = ET_TTS;
    self.isTranslating = NO;
    NSDictionary* token = [request userInfo];
    if(_delegate && [_delegate respondsToSelector: @selector(didFailTranslateProcess:token:)])
        [_delegate didFailTranslateProcess:errorType token:token];
}

@end
