//
//  ActionDetailEmptyRepTableViewCell.m
//  Voices
//
//  Created by Bogil, John on 6/13/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "ActionDetailEmptyRepTableViewCell.h"
#import "VoicesUtilities.h"

@interface ActionDetailEmptyRepTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *addAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyLabel;
@property (weak, nonatomic) IBOutlet UIButton *addAddressButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ActionDetailEmptyRepTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [self createActivityIndicator];
    self.addAddressLabel.font = [UIFont voicesFontWithSize:17];
    self.emojiLabel.font = [UIFont voicesFontWithSize:60];
    self.privacyLabel.font = [UIFont voicesFontWithSize:12];
    self.addAddressButton.tintColor = [UIColor whiteColor];
    self.addAddressButton.backgroundColor = [UIColor voicesOrange];
    self.addAddressButton.layer.cornerRadius = kButtonCornerRadius + 10;
    self.emojiLabel.text = [NSString stringWithFormat:@"%@ %@", [VoicesUtilities getRandomEmojiMale], [VoicesUtilities getRandomEmojiFemale]];
    self.addAddressButton.titleLabel.font = [UIFont voicesFontWithSize:24];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleActivityIndicatorOn) name:@"startFetchingReps" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleActivityIndicatorOff) name:@"endFetchingReps" object:nil];

}
- (void)createActivityIndicator {
    
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.activityIndicatorView.color = [UIColor grayColor];
    self.activityIndicatorView.hidesWhenStopped = YES;
    
    NSString *homeAddress = [[NSUserDefaults standardUserDefaults]stringForKey:kHomeAddress];
    if (homeAddress) {
        [self toggleActivityIndicatorOn];
    }
}

- (void)toggleActivityIndicatorOn {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView stopAnimating];
    });
}

- (IBAction)addAddressButtonDidPress:(id)sender {

    [[NSNotificationCenter defaultCenter]postNotificationName:@"presentSearchViewController" object:nil];
}

@end
