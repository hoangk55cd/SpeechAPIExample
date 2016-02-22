//
//  ViewController.m
//  SpeechAPIExample
//
//  Created by Huy Hoang  on 2/22/16.
//  Copyright © 2016 Huy Hoang . All rights reserved.
//

#import "ViewController.h"
#import "UIImage+animatedGIF.h"
#import "SpeechToTextModule.h"

@interface ViewController ()<SpeechToTextModuleDelegate>  {
    SpeechToTextModule *speechToTextModule;
    BOOL isRecording;
    
    // UI
    __weak IBOutlet UIButton *speakButton;
    __weak IBOutlet UIImageView *animationImageView;

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [speakButton setImage:[UIImage imageNamed:@"voice_contest"] forState:UIControlStateNormal];
    speechToTextModule = [[SpeechToTextModule alloc] initWithCustomDisplay:nil];
    [speechToTextModule setDelegate:self];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)speakTap:(id)sender {
    if (isRecording == NO) {
        [self startRecording];
    } else {
        [self stopRecording];
    }
}

- (void)startRecording {
    if (isRecording == NO) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"recording_animate" withExtension:@"gif"];
        animationImageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
        animationImageView.hidden = NO;
        [speakButton setImage:[UIImage imageNamed:@"voice_contest_recording"] forState:UIControlStateNormal];
        [speechToTextModule beginRecording];
        isRecording = YES;
    }
}

- (void)stopRecording {
    if (isRecording) {
        [speakButton setImage:[UIImage imageNamed:@"voice_contest"] forState:UIControlStateNormal];
        animationImageView.hidden = YES;
        [speechToTextModule stopRecording:YES];
        isRecording = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopRecording];
}

#pragma mark - SpeechToTextModuleDelegate
- (BOOL)didReceiveVoiceResponse:(NSDictionary *)data {
    
    NSLog(@"data %@",data);
    [self stopRecording];
    NSString *result = @"";
    id tmp = data[@"transcript"];
    if ([tmp isKindOfClass:[NSNumber class]] || [tmp rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound) {
        // Spell out number
        // incase user spell number
        NSNumber *resultNumber = [NSNumber numberWithInteger:[tmp integerValue]];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterSpellOutStyle];
        result = [formatter stringFromNumber:resultNumber];
    } else {
        result = tmp;
    }
    if ([result isEqualToString:@"beautiful"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Excelent" message:result delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        if (result == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please pronouce the word or check your microphone" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wrong" message:[NSString stringWithFormat:@"You pronouced \"%@\". You better try again", result] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    return YES;
}

- (void)requestFailedWithError:(NSError *)error {
    
}

- (void)dealloc {
    if (speechToTextModule) {
        [self stopRecording];
        speechToTextModule = nil;
    }
}


@end
