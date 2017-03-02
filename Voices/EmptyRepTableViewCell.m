//
//  EmptyRepTableViewCell.m
//  Voices
//
//  Created by Bogil, John on 8/4/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "EmptyRepTableViewCell.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@interface EmptyRepTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UIImageView *jonLennonImageView;
@property (weak, nonatomic) IBOutlet UIImageView *swipeDownImageView;
@property (weak, nonatomic) IBOutlet UIImageView *malalaImageView;
@property (weak, nonatomic) IBOutlet UILabel *swipeForRepsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *missingRepImageView;
@property (weak, nonatomic) IBOutlet UIImageView *missingRepImageViewTwo;

@end

@implementation EmptyRepTableViewCell

- (instancetype)init {
    self = [super init];
    
    self = [[[NSBundle mainBundle] loadNibNamed:@"EmptyRepTableViewCell" owner:self options:nil] objectAtIndex:0];
    
    [self setFont];
    self.missingRepImageView.alpha = 0;
    self.missingRepImageViewTwo.alpha = 0;
    
    return self;
}

- (void)setFont {
    
    self.topLabel.font = [UIFont voicesMediumFontWithSize:23];
    self.bottomLabel.font = [UIFont voicesFontWithSize:21];

    self.swipeDownImageView.alpha = 0.15f;
    self.jonLennonImageView.layer.cornerRadius = kButtonCornerRadius;
    self.malalaImageView.layer.cornerRadius = kButtonCornerRadius;
    self.jonLennonImageView.clipsToBounds = YES;
    self.malalaImageView.clipsToBounds = YES;
    
    self.swipeForRepsLabel.font = [UIFont voicesFontWithSize:21];
}

- (void)updateLabels:(NSString *)top bottom:(NSString *)bottom  {

    self.topLabel.text = top;
    self.bottomLabel.text = bottom;
}

- (void)updateImage {
    
    self.missingRepImageView.alpha = 0.75;
    self.missingRepImageViewTwo.alpha = 0.75;
    self.swipeDownImageView.alpha = 0.0;
}

@end
