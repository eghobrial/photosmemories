//
//  DetailViewController.m
//  Lab3
//
//  Created by Eman Ghobrial on 5/16/16.
//  Copyright © 2016 Eman Ghobrial. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property NSArray *results;

@end

@implementation DetailViewController


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchResults];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"print myOrder %d", self.myOrder);
    [self fetchResults];
    Image *tempIm = [self.results lastObject];
    NSLog(@"Image Date %@ ", tempIm.dateStamp);
    NSLog(@"Address %@ ", tempIm.streetAdd);
    self.myDate.text = tempIm.dateStamp;
    self.myAddress.text = tempIm.streetAdd;
    self.myCity.text = tempIm.city;
    NSString *audioFile = tempIm.audioURL;
    if ([audioFile isEqualToString:@"none"])
    {
        self.myAudioStatus.text = @"No Audio Note Available";
        self.playButton.enabled = NO;
    } else {
        self.myAudioStatus.text = [NSString stringWithFormat:@"Recording available %@",tempIm.audioURL];
        self.playButton.enabled = YES;
    }
    NSString *fileName = tempIm.localURL;
    
    NSURL *documentsURL = [[[NSFileManager defaultManager]
                            URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
   // NSString *fileName = myImage.localURL;
    documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
    NSLog(@"doc path = %@", documentsURL);
    //NSData *myImageData = UIImagePNGRepresentation(selectedImage);
    //if the image is a video display frame at time 1
    if ([fileName containsString:@"mp4"])
    {
        MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc]
                                                initWithContentURL:documentsURL];
        moviePlayer.shouldAutoplay = NO;
        UIImage *thumbnail = [moviePlayer thumbnailImageAtTime:1
                                                    timeOption:MPMovieTimeOptionNearestKeyFrame];
        self.myImage.image = thumbnail;
    } else {
        self.myImage.image = [UIImage imageWithContentsOfFile:documentsURL.path];
    }
    

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


-(void)fetchResults {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:[[DataManager sharedManager] managedObjectContext]];
    [fetchRequest setEntity:entity];
    //to sort
    NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"displayOrder" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor1]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"displayOrder", @(self.myOrder)];
    
    [fetchRequest setPredicate:predicate];
    NSError *error = nil;
    self.results = [[[DataManager sharedManager] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    } else {
        NSLog(@"%@", self.results);
    }
}


- (IBAction)myRecord:(id)sender {
    
    if ([self.audioRecorder isRecording]) {
        
        [self.audioRecorder stop];
        [self.recordButton setImage:[UIImage imageNamed:@"record1"] forState:UIControlStateNormal];
         self.myAudioStatus.text =  @"Recording status: stopped";
       // self.timeLabel.text = @"Recording status: stopped";
        self.playButton.enabled = YES;
        
    } else {
        
        NSError *error;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        
        if (error == nil) {
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *fileName = [NSString stringWithFormat:@"recording%d.wav",self.myOrder];
            
            Image *tempIm = [self.results lastObject];
            tempIm.audioURL = fileName;
            
        /*    tempIm.streetAdd = tempIm.streetAdd;
            tempIm.city = tempIm.city;
            tempIm.dateStamp = tempIm.dateStamp;
            tempIm.displayOrder = tempIm.displayOrder;
            tempIm.latitude = tempIm.longitude;
            tempIm.longitude = tempIm.longitude;
            tempIm.localURL  = tempIm.localURL;*/
            
            NSError *error = nil;
            if (![[DataManager sharedManager] updateImageWithImageDict:fileName andImageObject:tempIm withError:&error] ) {
                NSLog(@"Unable to update record.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            } else {
                [self fetchResults];
            }

            
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
         //   NSInteger count = 0;
            
            
       /*     while ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSString *fileName = [NSString stringWithFormat:@"recording-%ld", (long)count];
                filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
                count++;
            }*/
            
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            
            NSMutableDictionary *settingsDict = [NSMutableDictionary new];
            [settingsDict setObject:[NSNumber numberWithInt:44100.0] forKey:AVSampleRateKey];
            [settingsDict setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
            [settingsDict setObject:[NSNumber numberWithInt:AVAudioQualityMedium] forKey:AVEncoderAudioQualityKey];
            [settingsDict setObject:[NSNumber numberWithInt:16] forKey:AVEncoderBitRateKey];
            
            
            self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:settingsDict error:&error];
            
            if (error == nil) {
                
                [self.audioRecorder record];
                [self.recordButton setImage:[UIImage imageNamed:@"pause1"] forState:UIControlStateNormal];
          //      self.timeLabel.text = @"Recording status: active";
                self.myAudioStatus.text = @"Recording status: active";
            } else {
                NSLog(@"error initializing audio recorder: %@", [error description]);
            }
            
        } else {
            NSLog(@"error initializing audio session: %@", [error description]);
        }
    }
    

}

- (IBAction)myPlay:(id)sender {
    NSError *error = nil;
    
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder stop];
    }
    
    if ([self.audioPlayer isPlaying]) {
        
        [self.audioPlayer stop];
        [self.playButton setImage:[UIImage imageNamed:@"play1"] forState:UIControlStateNormal];
        
    //    self.timeLabel.text = @"Audio file: stopped";
        self.myAudioStatus.text = @"Audio file: stopped";
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        Image *tempIm = [self.results lastObject];
        NSString *fileName =  tempIm.audioURL;
        if ([fileName isEqualToString:@"none"])
        {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[self.audioRecorder url] error:&error];
        } else {
            
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
             NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
            
        }
        self.audioPlayer.delegate = self;
        
        if (error == nil) {
            
            [self.audioPlayer play];
            [self.playButton setImage:[UIImage imageNamed:@"pause1"] forState:UIControlStateNormal];
            
      //      self.timeLabel.text = @"Audio file: playing";
            self.myAudioStatus.text =  @"Audio file: playing";
        } else {
            NSLog(@"error initializing audio player: %@", [error description]);
        }
        
    }

}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // set finish image
    [self.playButton setImage:[UIImage imageNamed:@"play1"] forState:UIControlStateNormal];
    self.myAudioStatus.text = @"Audio file: stopped";
   // self.timeLabel.text = @"Audio file: stopped";
}
@end
