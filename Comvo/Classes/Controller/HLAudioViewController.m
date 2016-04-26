//
//  HLAudioViewController.m
//  Comvo
//
//  Created by DeMing Yu on 1/8/15.
//  Copyright (c) 2015 DeMing Yu. All rights reserved.
//

#import "HLAudioViewController.h"

#import "AppEngine.h"
#import "Constants_Comvo.h"

@interface HLAudioViewController () <AVAudioPlayerDelegate, UIAlertViewDelegate>

@end

#define kAudioFilePath @"EZAudioTest.aac"

@implementation HLAudioViewController

@synthesize delegate;
@synthesize audioPlot;
@synthesize microphone;
@synthesize recorder;

#pragma mark - Initialization
-(id)init {
    self = [super init];
    if(self){
        [self initializeViewController];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initializeViewController];
    }
    return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
    // Create an instance of the microphone and tell it to use this view controller instance as the delegate
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = NULL;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
    if( err ){
        NSLog(@"There was an error creating the audio session");
    }
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:NULL];
    if( err ){
        NSLog(@"There was an error sending the audio to the speakers");
    }
    
    [self removeFile: [NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory],kAudioFilePath]];
    
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNavigation];
    
    self.audioPlot.backgroundColor = UIColorFromRGB(0x149eec);
    // Waveform color
    self.audioPlot.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    // Plot type
    self.audioPlot.plotType        = EZPlotTypeRolling;
    // Fill
    self.audioPlot.shouldFill      = YES;
    // Mirror
    self.audioPlot.shouldMirror    = YES;
    
    NSString *strAudioSearchMode = [Engine gAudioRecordingMode];
    
    if ([strAudioSearchMode isEqualToString:@"StreamingAudio"])
    {
        mLblDescription.text = @"You can upload audio for streaming page or comment page.";
    }
    else if ([strAudioSearchMode isEqualToString:@"GreetingAudio"])
    {
        mLblDescription.text = @"You can upload greeting audio file for profile page.";
    }
    
    [self.tabBarController.tabBar setHidden: YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)removeFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        
    }
    else {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}


//==========================================================================================================================

#pragma mark -
#pragma mark - Initialize

- (void)initNavigation {
    [self.navigationController setNavigationBarHidden: NO];
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.title = @"Record";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UIButton *btnBack = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnBack setFrame: CGRectMake(0, 0, 30, 30)];
    [btnBack setTintColor: [UIColor whiteColor]];
    [btnBack setImage: [UIImage imageNamed: @"audio_img_close.png"] forState: UIControlStateNormal];
    [btnBack addTarget: self action: @selector(onTouchBtnBack :) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnBack];    
    
    UIButton *btnDone = [UIButton buttonWithType: UIButtonTypeSystem];
    [btnDone setFrame: CGRectMake(0, 0, 50, 30)];
    [btnDone setTintColor: [UIColor whiteColor]];
    [btnDone setTitle: @"Done" forState: UIControlStateNormal];
    [btnDone addTarget: self action: @selector(onTouchBtnDone:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnDone];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Touch Event

- (IBAction)onTouchBtnBack: (id)sender {
    if(mIsRecording)
    {
        [self commitRecording];
        [self.microphone stopFetchingAudio];
        
        mIsRecording = FALSE;
    }
    
    [delegate didBackedFromRecordAudio];
}

- (IBAction)onTouchBtnDone: (id)sender {
    
    if (mCounterDuringTimer == 0)
    {
        mIsRecording = FALSE;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Audio recording is empty." message: @"Warning" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    
    if(mIsRecording)
    {
        [self commitRecording];
        [self.microphone stopFetchingAudio];
        
        mIsRecording = FALSE;
    }
    
    [delegate didFinishedRecordAudio: [self testFilePathURL]];
}

- (IBAction)onTouchBtnRecord: (id)sender {
    
    if(mIsRecording)
    {
        [mBtnRecord setImage: [UIImage imageNamed: @"audio_img_record_start.png"] forState: UIControlStateNormal];
        
        if(mDuringTimer) {
            [mDuringTimer invalidate];
            mDuringTimer = nil;
        }
        
        [self commitRecording];
        [self.microphone stopFetchingAudio];
        
        mIsRecording = FALSE;
    }
    else
    {
        [mBtnRecord setImage: [UIImage imageNamed: @"audio_img_record.png"] forState: UIControlStateNormal];
        
        mIsRecording = TRUE;

//        mCounterDuringTimer = 0;
        mDuringTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0f
                                                             target:self
                                                           selector:@selector(refreshTimerLabel)
                                                           userInfo:nil
                                                            repeats:YES];
        
        [self.microphone startFetchingAudio];
        [self startForFilePath: [NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory],kAudioFilePath]];
    }
}

- (void)refreshTimerLabel
{
    mCounterDuringTimer += 1;
    if(mCounterDuringTimer > 15) {
        mCounterDuringTimer = 15;
    }
    
    mLblTime.text = [NSString stringWithFormat:@"00:00:%02d", mCounterDuringTimer];
}

//==========================================================================================================================

#pragma mark -
#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming microphone input) happens on a separate audio thread that should not be blocked. When we feed audio data into any of the UI components we need to explicity create a GCD block on the main thread to properly get the UI to work.
-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    // Getting audio data as an array of float buffer arrays. What does that mean? Because the audio is coming in as a stereo signal the data is split into a left and right channel. So buffer[0] corresponds to the float* data for the left channel while buffer[1] corresponds to the float* data for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks happen on a separate audio thread. We wrap any UI updating in a GCD block on the main thread to avoid blocking that audio flow.
    dispatch_async(dispatch_get_main_queue(),^{
        // All the audio plot needs is the buffer data (float*) and the size. Internally the audio plot will handle all the drawing related code, history management, and freeing its own resources. Hence, one badass line of code gets you a pretty plot :)
        [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

-(void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription {
    // The AudioStreamBasicDescription of the microphone stream. This is useful when configuring the EZRecorder or telling another component what audio format type to expect.
    
    // Here's a print function to allow you to inspect it a little easier
    [EZAudio printASBD:audioStreamBasicDescription];
    
    // We can initialize the recorder with this ASBD
//    self.recorder = [EZRecorder recorderWithDestinationURL: [self testFilePathURL] sourceFormat: audioStreamBasicDescription destinationFileType: EZRecorderFileTypeM4A];
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    // Getting audio data as a buffer list that can be directly fed into the EZRecorder. This is happening on the audio thread - any UI updating needs a GCD main queue block. This will keep appending data to the tail of the audio file.
//    if( self.isRecording ){
//        [self.recorder appendDataFromBufferList:bufferList
//                                 withBufferSize:bufferSize];
//    }
    
}

//==========================================================================================================================

#pragma mark -
#pragma mark - AVAudioPlayerDelegate
/*
 Occurs when the audio player instance completes playback
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
//    self.audioPlayer = nil;
//    self.playingTextField.text = @"Finished Playing";
    
//    [self.microphone startFetchingAudio];
//    self.microphoneSwitch.on = YES;
//    self.microphoneTextField.text = @"Microphone On";
}

//==========================================================================================================================

#pragma mark -
#pragma mark - Utility
-(NSArray*)applicationDocuments {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

-(NSString*)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSURL*)testFilePathURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",[self applicationDocumentsDirectory],kAudioFilePath]];
}

//

- (void)startForFilePath:(NSString *)filePath {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    // You can change the settings for the voice quality
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    NSLog(@"Recording at: %@", filePath);
    NSString *recorderFilePath = filePath;
    
    NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
    
    err = nil;
    
    NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
    if(audioData)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:[url path] error:&err];
    }
    
    err = nil;
    mRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
    if(!mRecorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: [err localizedDescription]
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [mRecorder setDelegate:self];
    [mRecorder prepareToRecord];
    mRecorder.meteringEnabled = YES;
    
    BOOL audioHWAvailable = audioSession.inputIsAvailable;
    if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
                                   message: @"Audio input hardware not available"
                                  delegate: nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [cantRecordAlert show];
        return;
    }
    
    [mRecorder recordForDuration:(NSTimeInterval) 20];
}

- (void)cancelRecording {
    mIsRecording=FALSE;
    [mRecorder stop];
}

- (void)commitRecording {
    [mRecorder stop];
    mIsRecording=FALSE;
}

@end
