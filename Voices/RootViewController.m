//
//  RootViewController.h
//  Voices
//
//  Created by John Bogil on 8/7/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import "RootViewController.h"
#import "NetworkManager.h"
#import "RepManager.h"
#import "UIFont+voicesFont.h"
#import "StateRepresentative.h"
#import "CacheManager.h"
#import "UIColor+voicesColor.h"
#import "PageViewController.h"
#import "LocationService.h"
#import "VoicesConstants.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <Social/Social.h>
#import <STPopup/STPopup.h>
#import "FBShimmeringView.h"
#import "FBShimmeringLayer.h"


@interface RootViewController () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *legislatureLevel;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (strong, nonatomic) PageViewController *pageVC;
@property (strong, nonatomic) NSString *representativeEmail;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic) BOOL isSearchBarOpen;

@end

@implementation RootViewController

#pragma mark - Lifecycle methods

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.shadowView = [[UIView alloc] init];
    self.shadowView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:self.shadowView belowSubview:self.shimmeringView];
    
    [self addObservers];
    [self setFont];
    [self setColors];
    [self setSearchBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Create a shadow. Fake shadow view is white and below the shimmerview.
    self.shadowView.frame = self.shimmeringView.frame;
    self.shadowView.layer.cornerRadius = self.searchView.layer.cornerRadius;
    
    self.shimmeringView.shimmering = NO;
    self.shimmeringView.contentView = self.searchView;
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds];
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.shadowView.layer.shadowOpacity = 0.125f;
    self.shadowView.layer.shadowPath = shadowPath.CGPath;
}

#pragma mark - Custom accessor methods

- (void)setColors {
    self.searchView.backgroundColor = [UIColor voicesOrange];
    self.searchButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
    self.infoButton.tintColor = [[UIColor whiteColor]colorWithAlphaComponent:1];
    self.pageControl.pageIndicatorTintColor = [[UIColor blackColor]colorWithAlphaComponent:.2];
}

- (void)setFont {
    self.legislatureLevel.font = [UIFont voicesFontWithSize:25];
}

#pragma mark - NSNotifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePage:) name:@"changePage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentEmailViewController:) name:@"presentEmailVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentTweetComposer:)name:@"presentTweetComposer" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentInfoViewController)name:@"presentInfoViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingOperationDidStartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingOperationDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOn) name:AFNetworkingTaskDidResumeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidSuspendNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleShimmerOff) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)note {
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.containerView addGestureRecognizer:self.tap];
}

- (void)dismissKeyboard {
    [self hideSearchBar];
    [self.searchBar resignFirstResponder];
    [self.containerView removeGestureRecognizer:self.tap];
}

- (void)changePage:(NSNotification *)notification {
    NSDictionary* userInfo = notification.object;
    NSString *currentPageString = userInfo[@"currentPage"];
    if (currentPageString.length > 0) {
        self.legislatureLevel.text = currentPageString;
    }
    
    [UIView animateWithDuration:.15 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    if ([currentPageString isEqualToString:@"Federal"]) {
        self.pageControl.currentPage = 0;
    }
    else if ([currentPageString isEqualToString:@"State"]) {
        self.pageControl.currentPage = 1;
    }
    else {
        self.pageControl.currentPage = 2;
    }
}

#pragma mark - Search Bar Delegate Methods

- (void)setSearchBar {
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"Search by location";
    
    // Round the box
    self.searchView.layer.cornerRadius = kButtonCornerRadius;
    self.searchView.clipsToBounds = YES;
    
    // Set cancel button to white color
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName, nil]forState:UIControlStateNormal];
    
    // Set placeholder text to white
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil]setTextColor:[UIColor whiteColor]];
    
    // Set the input text font
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setDefaultTextAttributes:@{NSFontAttributeName : [UIFont voicesFontWithSize:15],NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // Hide the magnifying glass
    [self.searchBar setImage:[UIImage new]
            forSearchBarIcon:UISearchBarIconSearch
                       state:UIControlStateNormal];
    
    // Set the cursor position
    [[UISearchBar appearance] setPositionAdjustment:UIOffsetMake(-20, 0)
                                   forSearchBarIcon:UISearchBarIconSearch];
    
    [self.searchBar setTintColor:[UIColor whiteColor]];
    
    // Set the cursor color
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil]
     setTintColor:[UIColor colorWithRed:255.0 / 255.0
                                  green:160.0 / 255.0
                                   blue:5.0 / 255.0
                                  alpha:1.0]];
    
    // Set the clear button for both states
    [self.searchBar setImage:[UIImage imageNamed:@"ClearButton"]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateHighlighted];
    [self.searchBar setImage:[UIImage imageNamed:@"ClearButton"]
            forSearchBarIcon:UISearchBarIconClear
                       state:UIControlStateNormal];
    
    // Round the search bar
    UITextField *textSearchField = [self.searchBar valueForKey:@"_searchField"];
    textSearchField.layer.cornerRadius = kButtonCornerRadius;
    
    // Hide the search bar
    self.searchBar.alpha = 0.0;
    self.searchButton.alpha = 1.0;
    self.legislatureLevel.alpha = .8;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    for (id vc in self.childViewControllers) {
        if ([vc isKindOfClass:[UIPageViewController class]]) {
            self.pageVC = vc;
        }
    }
    
    [[LocationService sharedInstance]getCoordinatesFromSearchText:searchBar.text withCompletion:^(CLLocation *locationResults) {
        
        [[RepManager sharedInstance]createFederalRepresentativesFromLocation:locationResults WithCompletion:^{
            NSLog(@"%@", locationResults);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepManager sharedInstance]createStateRepresentativesFromLocation:locationResults WithCompletion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:nil];
        } onError:^(NSError *error) {
            [error localizedDescription];
        }];
        
        [[RepManager sharedInstance]createNYCRepsFromLocation:locationResults];
        
    } onError:^(NSError *googleMapsError) {
        NSLog(@"%@", [googleMapsError localizedDescription]);
    }];
    
    [self hideSearchBar];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self hideSearchBar];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (IBAction)openSearchBarButtonDidPress:(id)sender {
    [self showSearchBar];
}

- (void)showSearchBar {
    self.searchBar.showsCancelButton = YES;
    self.isSearchBarOpen = YES;
    [self.searchBar becomeFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.searchBar.alpha = 1.0;
                         self.legislatureLevel.alpha = 0.0;
                         self.searchButton.alpha = 0.0;
                         self.infoButton.alpha = 0.0;
                     }];
}

- (void)hideSearchBar {
    self.isSearchBarOpen = NO;
    [self.searchBar resignFirstResponder];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.searchBar.alpha = 0.0;
                         self.searchButton.alpha = 1.0;
                         self.legislatureLevel.alpha = 1.0;
                         self.infoButton.alpha = 1.0;
                     }];
}

#pragma mark - FB Shimmer methods

- (void)toggleShimmerOn {
    self.shimmeringView.shimmering = YES;
}

- (void)toggleShimmerOff {
    [self.shimmeringView performSelector:@selector(setShimmering:)];
    self.shimmeringView.shimmering = NO;
}

#pragma mark - Presentation Controllers

- (void)presentEmailViewController:(NSNotification*)notification {
    self.representativeEmail = [notification object];
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {
        mailViewController.mailComposeDelegate = self;
        //        [mailViewController setSubject:@"Subject Goes Here."];
        //        [mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        [mailViewController setToRecipients:@[self.representativeEmail]];
        [self presentViewController:mailViewController animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    UIAlertView *alert;
    switch (result) {
        case MFMailComposeResultCancelled:
        {
            break;
        }
        case MFMailComposeResultSaved:
            alert = [[UIAlertView alloc] initWithTitle:@"Draft Saved" message:@"Composed Mail is saved in draft." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case MFMailComposeResultSent:
        {
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
            break;
        }
        case MFMailComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Sorry! Failed to send." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentTweetComposer:(NSNotification*)notification {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *tweetSheetOBJ = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *initialText = [NSString stringWithFormat:@".@%@", [notification.userInfo objectForKey:@"accountName"]];
        [tweetSheetOBJ setInitialText:initialText];
        [tweetSheetOBJ setCompletionHandler:^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Twitter Post Canceled");
                    
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Twitter Post Sucessful");
                    break;
                default:
                    break;
            }
        }];
        [self presentViewController:tweetSheetOBJ animated:YES completion:nil];
    }
}

- (void)presentInfoViewController {
    UIViewController *infoViewController = [[UIStoryboard storyboardWithName:@"Info" bundle:nil] instantiateViewControllerWithIdentifier:@"InfoViewController"];
    STPopupController *popupController = [[STPopupController alloc] initWithRootViewController:infoViewController];
    popupController.containerView.layer.cornerRadius = 10;
    [STPopupNavigationBar appearance].barTintColor = [UIColor orangeColor]; // This is the only OK "orangeColor", for now
    [STPopupNavigationBar appearance].tintColor = [UIColor whiteColor];
    [STPopupNavigationBar appearance].barStyle = UIBarStyleDefault;
    [STPopupNavigationBar appearance].titleTextAttributes = @{ NSFontAttributeName: [UIFont voicesFontWithSize:23], NSForegroundColorAttributeName: [UIColor whiteColor] };
    popupController.transitionStyle = STPopupTransitionStyleFade;
    [[UIBarButtonItem appearanceWhenContainedIn:[STPopupNavigationBar class], nil] setTitleTextAttributes:@{ NSFontAttributeName:[UIFont voicesFontWithSize:19] } forState:UIControlStateNormal];
    [popupController presentInViewController:self];
}

#pragma mark - IBActions

- (IBAction)infoButtonDidPress:(id)sender {
    [self presentInfoViewController];
}

@end
