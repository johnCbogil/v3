//
//  StateRepTableViewCell.m
//  v3
//
//  Created by John Bogil on 10/16/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "StateRepTableViewCell.h"
#import "RepManager.h"
#import "StateLegislator.h"
#import "UIFont+voicesFont.h"
#import "UIColor+voicesOrange.h"

@interface StateRepTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (strong, nonatomic) StateLegislator *stateLegislator;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *districtNumberLabel;
@property (strong, nonatomic) NSArray *listOfStatesWithAssembly;
@end

@implementation StateRepTableViewCell

- (void)awakeFromNib {
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    self.photo.layer.cornerRadius = 5;
    self.photo.clipsToBounds = YES;
    [self setFont];
    [self setColor];
    self.listOfStatesWithAssembly = [NSArray arrayWithObjects:@"CA", @"NV", @"NJ", @"NY", @"WI", nil];
}

- (void)initFromIndexPath:(NSIndexPath*)indexPath {
    self.stateLegislator =  [RepManager sharedInstance].listOfStateLegislators[indexPath.row];
    self.name.text = [NSString stringWithFormat:@"%@ %@ %@", self.stateLegislator.chamber, self.stateLegislator.firstName, self.stateLegislator.lastName];
    [self createDistrictNumberLabel];
    self.photo.image = [UIImage imageWithData:self.stateLegislator.photo];
}

- (void)setColor {
    self.emailButton.imageView.tintColor = [UIColor voicesOrange];
    self.emailButton.tintColor = [UIColor voicesOrange];
    self.callButton.tintColor = [UIColor voicesOrange];
}

- (void)createDistrictNumberLabel {
    if ([self.stateLegislator.chamber isEqualToString:@"Rep."]) {
        if ([self.listOfStatesWithAssembly containsObject:self.stateLegislator.stateCode.uppercaseString]) {
            self.districtNumberLabel.text = [NSString stringWithFormat:@"Assembly District %@", self.stateLegislator.districtNumber];
        }
        else {
            self.districtNumberLabel.text = [NSString stringWithFormat:@"House District %@", self.stateLegislator.districtNumber];
        }
    }
    else {
        self.districtNumberLabel.text = [NSString stringWithFormat:@"Senate District %@", self.stateLegislator.districtNumber];
    }
}

- (void)setFont {
    self.name.font = [UIFont voicesFontWithSize:24];
    self.districtNumberLabel.font = [UIFont voicesFontWithSize:20];
}

- (IBAction)callButtonDidPress:(id)sender {
    if (self.stateLegislator.phone) {
        NSString *confirmCallMessage;
        if (![self.stateLegislator.firstName isEqual:[NSNull null]]) {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@, do you know what to say?", self.stateLegislator.firstName];
        }
        else {
            confirmCallMessage =  [NSString stringWithFormat:@"You're about to call %@ %@, do you know what to say?", self.stateLegislator.firstName, self.stateLegislator.lastName];
        }
        UIAlertView *confirmCallAlert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"Representative %@ %@",self.stateLegislator.firstName, self.stateLegislator.lastName]  message:confirmCallMessage delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [confirmCallAlert show];
        confirmCallAlert.delegate = self;
    }
    else {
        [self.delegate presentCustomAlertWithMessage:@"This legislator does not have a phone number listed.\n\n Try tweeting instead" andTitle:[NSString stringWithFormat:@"%@. %@", self.stateLegislator.firstName, self.stateLegislator.lastName]];
    }
}
- (IBAction)emailButtonDidPress:(id)sender {
    if (self.stateLegislator.email.length > 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentEmailVC" object:self.stateLegislator.email];
    }
    else {
        [self.delegate presentCustomAlertWithMessage:@"This legislator does not have an email listed.\n\n Try calling instead, it's more effective."andTitle:[NSString stringWithFormat:@"%@. %@", self.stateLegislator.firstName, self.stateLegislator.lastName]];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentInfoViewController" object:nil];
    }
    else if (buttonIndex == 1) {
        NSURL* callUrl=[NSURL URLWithString:[NSString   stringWithFormat:@"tel:%@", self.stateLegislator.phone]];
        if([[UIApplication sharedApplication] canOpenURL:callUrl])
        {
            [[UIApplication sharedApplication] openURL:callUrl];
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"ALERT" message:@"This function is only available on the iPhone"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}
@end