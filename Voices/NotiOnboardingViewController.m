//
//  NotiOnboardingViewController.m
//  Voices
//
//  Created by John Bogil on 7/14/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "NotiOnboardingViewController.h"
#import "TabBarViewController.h"


@interface NotiOnboardingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *turnOnNotiLabel;
@property (weak, nonatomic) IBOutlet UIImageView *notiOnboardingImageView;
@property (weak, nonatomic) IBOutlet UIView *singleLineView;
@property (weak, nonatomic) IBOutlet UIButton *turnOnNotificationsButton;
@property (weak, nonatomic) IBOutlet UIButton *deferNotiButton;

@end

@implementation NotiOnboardingViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNextVC) name:@"notificationsRegistered" object:nil];
    [self setFont];
}

- (void)setFont {
    self.turnOnNotiLabel.font = [UIFont voicesFontWithSize:19];
    
    self.turnOnNotificationsButton.titleLabel.font = [UIFont voicesFontWithSize:21];
    self.turnOnNotificationsButton.backgroundColor = [UIColor voicesOrange];
    self.turnOnNotificationsButton.layer.cornerRadius = kButtonCornerRadius;
    
    self.deferNotiButton.titleLabel.font = [UIFont voicesFontWithSize:13];
    [self.deferNotiButton setTitleColor:[UIColor voicesGray] forState:UIControlStateNormal];
    self.deferNotiButton.alpha = 0.5;
    [self.deferNotiButton setTitle:@"I'm not interested right now." forState:UIControlStateNormal];
}

- (IBAction)turnOnNotiButtonDidPress:(id)sender {
    if (![self.turnOnNotificationsButton.titleLabel.text isEqualToString:@"Next"]) {
        UIUserNotificationType allNotificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [self pushNextVC];
    }
    
    [self.turnOnNotificationsButton setTitle:@"Next" forState:UIControlStateNormal];
    self.turnOnNotificationsButton.titleLabel.font = [UIFont voicesFontWithSize:29];
    self.deferNotiButton.alpha = 0;
}

- (IBAction)deferNotiButtonDidPress:(id)sender {
    [self pushNextVC];
}

- (void)pushNextVC {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    TabBarViewController *tabVC = (TabBarViewController *)[mainStoryboard instantiateViewControllerWithIdentifier: @"TabBarViewController"];
    [self.navigationController pushViewController:tabVC animated:YES];    
}

@end
