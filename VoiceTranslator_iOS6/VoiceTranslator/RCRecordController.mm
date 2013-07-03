//
//  RCRecordController.m
//  VoiceTranslator
//
//  Created by xuzepei on 11/10/12.
//  Copyright (c) 2012 xuzepei. All rights reserved.
//

#import "RCRecordController.h"
#import "RCTool.h"

char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4] = {0};
    char *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

@implementation RCRecordController
@synthesize player;
@synthesize recorder;

+ (RCRecordController*)sharedInstance
{
    static RCRecordController* sharedInstance = nil;
    
    if(nil == sharedInstance)
    {
        @synchronized([RCRecordController class])
        {
            if(nil == sharedInstance)
            {
                sharedInstance = [[RCRecordController alloc] init];
            }
        }
    }
    
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    delete player;
    player = nil;
    
	delete recorder;
    recorder = nil;
    
    self.language = nil;
    self.delegate = nil;
    self.filename = nil;
    
    [super dealloc];
}

#pragma mark - Initialization

- (void)initRecorder
{
	// Allocate our singleton instance for the recorder & player object
	recorder = new AQRecorder();
	player = new AQPlayer();
    
	OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
	if (error)
        NSLog(@"ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
	else
	{
		UInt32 category = kAudioSessionCategory_PlayAndRecord;
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error)
            NSLog(@"couldn't set audio category!");
        
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);
		
		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
		//btn_record.enabled = (inputAvailable) ? YES : NO;
		
		// we also need to listen to see if input availability changes
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
        
		error = AudioSessionSetActive(true);
		if (error) printf("AudioSessionSetActive (true) failed");
	}
	
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
    
    [self registerForBackgroundNotifications];
}

#pragma mark - Record Action

- (void)record:(NSString*)filename
{
	if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[self stop];
	}
	else // If we're not recording, start.
	{
        self.filename = filename;
        
        [RCTool removeFile:[RCTool getRecordFilePath:self.filename]];

		// Start the recorder
		recorder->StartRecord((CFStringRef)[RCTool getRecordFilePath:self.filename]);
        
        if(_delegate && [_delegate respondsToSelector:@selector(willStartRecording:)])
        {
            [_delegate willStartRecording:nil];
        }
	}
}

- (void)stop
{
    self.filename = nil;
    
    if(_delegate && [_delegate respondsToSelector:@selector(willStopRecording:)])
    {
        [_delegate willStopRecording:nil];
    }
    
	recorder->StopRecord();
    
	// now create a new queue for the recorded file
    //	recordFilePath = (CFStringRef)[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];
    //	player->CreateQueueForFile(recordFilePath);
}

- (BOOL)isRecording
{
    if(recorder)
        return recorder->IsRunning();
    
    return NO;
}

#pragma mark - AudioSession listeners

void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
	RCRecordController *THIS = (RCRecordController*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS->recorder->IsRunning()) {
			[THIS stop];
		}
	}
    //	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
    //	{
    //	}
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	RCRecordController *THIS = (RCRecordController*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			/*CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
             if (oldRoute)
             {
             printf("old route:\n");
             CFShow(oldRoute);
             }
             else
             printf("ERROR GETTING OLD AUDIO ROUTE!\n");
             
             CFStringRef newRoute;
             UInt32 size; size = sizeof(CFStringRef);
             OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
             if (error) printf("ERROR GETTING NEW AUDIO ROUTE! %d\n", error);
             else
             {
             printf("new route:\n");
             CFShow(newRoute);
             }*/
            
			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			{
			}
            
			// stop the queue if we had a non-policy route change
			if (THIS->recorder->IsRunning()) {
				[THIS stop];
			}
		}
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32)) {
			//UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
			//THIS->btn_record.enabled = (isAvailable > 0) ? YES : NO;
		}
	}
}


#pragma mark - background notifications

- (void)registerForBackgroundNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resignActive)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(enterForeground)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void)resignActive
{
    if (recorder->IsRunning())
        [self stop];
    
    //inBackground = true;
}

- (void)enterForeground
{
    OSStatus error = AudioSessionSetActive(true);
    if (error)
        printf("AudioSessionSetActive (true) failed");
    
	//inBackground = false;
}

@end
