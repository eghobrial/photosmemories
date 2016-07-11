//
//  DetailViewController.h
//  Lab3
//
//  Created by Eman Ghobrial on 5/16/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "DataManager.h"

@interface DetailViewController : UIViewController <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@property (weak, nonatomic) IBOutlet UIImageView *myImage;

@property (weak, nonatomic) IBOutlet UILabel *myDate;

@property (weak, nonatomic) IBOutlet UILabel *myAddress;

@property (weak, nonatomic) IBOutlet UILabel *myCity;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
- (IBAction)myRecord:(id)sender;

- (IBAction)myPlay:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *myAudioStatus;
@property int myOrder;


@end
