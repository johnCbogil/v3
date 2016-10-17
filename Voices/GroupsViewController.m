//
//  GroupsViewController.m
//  Voices
//
//  Created by John Bogil on 12/19/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "GroupsViewController.h"
#import "GroupTableViewCell.h"
#import "ActionTableViewCell.h"
#import "GroupTableViewCell.h"
#import "ListOfGroupsViewController.h"
#import "ActionDetailViewController.h"
#import "GroupDetailViewController.h"
#import "Group.h"
#import "Action.h"
#import "GroupsEmptyState.h"
#import "CurrentUser.h"

@import Firebase;
@import FirebaseMessaging;

@interface GroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) NSInteger selectedSegment;
@property (nonatomic, assign) BOOL isUserAuthInProgress;
@property (strong, nonatomic) FIRDatabaseReference *rootRef;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;
@property (strong, nonatomic) FIRDatabaseReference *groupsRef;
@property (strong, nonatomic) FIRDatabaseReference *actionsRef;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) GroupsEmptyState *emptyStateView;
@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureTableView];
    [self createActivityIndicator];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = [UIColor voicesOrange];
    
    self.segmentControl.tintColor = [UIColor voicesOrange];
    
    self.rootRef = [[FIRDatabase database] reference];
    self.usersRef = [self.rootRef child:@"users"];
    self.groupsRef = [self.rootRef child:@"groups"];
    self.actionsRef = [self.rootRef child:@"actions"];
    self.currentUserID = [FIRAuth auth].currentUser.uid;
    self.isUserAuthInProgress = NO;
}

- (void)configureEmptyState {
    if (self.segmentControl.selectedSegmentIndex) {
        [self.emptyStateView updateLabels:kGroupEmptyStateTopLabel bottom:kGroupEmptyStateBottomLabel];
    }
    else {
        [self.emptyStateView updateLabels:kActionEmptyStateTopLabel bottom:kActionEmptyStateBottomLabel];
    }
    [self.view layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.currentUserID) {
        [self fetchFollowedGroupsForUserID:self.currentUserID];
    }
    else {
        self.tableView.backgroundView.hidden = NO;
    }
    
    [self.tableView reloadData];
}

- (void)configureTableView {
    
    self.emptyStateView = [[GroupsEmptyState alloc]init];
    self.tableView.backgroundView = self.emptyStateView;
    if (!self.isUserAuthInProgress) {
        self.tableView.backgroundView.hidden = YES;
    }

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"GroupTableViewCell" bundle:nil]forCellReuseIdentifier:@"GroupTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActionTableViewCell" bundle:nil]forCellReuseIdentifier:@"ActionTableViewCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)createActivityIndicator {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]
                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.color = [UIColor grayColor];
    self.activityIndicatorView.center=self.view.center;
    [self.view addSubview:self.activityIndicatorView];
}

- (void)toggleActivityIndicatorOn {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicatorView startAnimating];
    });
}

- (void)toggleActivityIndicatorOff {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // TODO: THIS IS NOT DRY
        if (self.selectedSegment == 0) {
            if (![CurrentUser sharedInstance].listOfActions.count) {
                self.tableView.backgroundView.hidden = NO;
            }
            else {
                self.tableView.backgroundView.hidden = YES;
            }
        }
        else {
            if (![CurrentUser sharedInstance].listOfFollowedGroups.count) {
                self.tableView.backgroundView.hidden = NO;
            }
            else {
                self.tableView.backgroundView.hidden = YES;
            }
        }
    });
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Firebase Methods

- (void)userAuth {
    if (self.isUserAuthInProgress) {
        return;
    }
    self.isUserAuthInProgress = YES;
    NSString *userID = [[NSUserDefaults standardUserDefaults]stringForKey:@"userID"];
    if (userID) {
        [self fetchFollowedGroupsForUserID:userID];
    }
}

- (void)fetchFollowedGroupsForUserID:(NSString *)userID {
    
    self.isUserAuthInProgress = NO;
    [self toggleActivityIndicatorOn];
    
    [[CurrentUser sharedInstance]fetchFollowedGroupsForUserID:userID WithCompletion:^(NSArray *listOfFollowedGroups) {
        [self toggleActivityIndicatorOff];
        NSLog(@"List of Followed Groups: %@", listOfFollowedGroups);
        [self.tableView reloadData];
        
        [[CurrentUser sharedInstance]fetchActionsWithCompletion:^(NSArray *listOfActions) {
            [self.tableView reloadData];
        } onError:^(NSError *error) {
            
        }];
    } onError:^(NSError *error) {
        [self toggleActivityIndicatorOff];
    }];
}

- (IBAction)listOfGroupsButtonDidPress:(id)sender {
    
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    ListOfGroupsViewController *viewControllerB = (ListOfGroupsViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"ListOfGroupsViewController"];
    viewControllerB.currentUserID = self.currentUserID;
    [self.navigationController pushViewController:viewControllerB animated:YES];
}

- (void)learnMoreButtonDidPress:(UIButton*)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    ActionDetailViewController *actionDetailViewController = (ActionDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"ActionDetailViewController"];
    actionDetailViewController.action = [CurrentUser sharedInstance].listOfActions[indexPath.row];
    [self.navigationController pushViewController:actionDetailViewController animated:YES];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.selectedSegment) {
        return [CurrentUser sharedInstance].listOfFollowedGroups.count;
    }
    else {
        return [CurrentUser sharedInstance].listOfActions.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedSegment == 0) {
        ActionTableViewCell *cell = (ActionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ActionTableViewCell" forIndexPath:indexPath];
        [cell.takeActionButton addTarget:self action:@selector(learnMoreButtonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        Action *action = [CurrentUser sharedInstance].listOfActions[indexPath.row];
        [cell initWithAction:action];
        return cell;
    }
    else {
        GroupTableViewCell *cell = (GroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"GroupTableViewCell" forIndexPath:indexPath];
        Group *group = [CurrentUser sharedInstance].listOfFollowedGroups[indexPath.row];
        [cell initWithGroup:group];
        return cell;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedSegment == 0) {
        return NO;
    }
    else {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Group *currentGroup = [CurrentUser sharedInstance].listOfFollowedGroups[indexPath.row];
        [[CurrentUser sharedInstance]removeGroup:currentGroup];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:currentGroup.name message:@"You will no longer receive actions from this group" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alert show];
        
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *groupsStoryboard = [UIStoryboard storyboardWithName:@"Groups" bundle: nil];
    if (self.segmentControl.selectedSegmentIndex) {
        GroupDetailViewController *groupDetailViewController = (GroupDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier:@"GroupDetailViewController"];
        groupDetailViewController.group = [CurrentUser sharedInstance].listOfFollowedGroups[indexPath.row];
        groupDetailViewController.currentUserID = self.currentUserID;
        [self.navigationController pushViewController:groupDetailViewController animated:YES];
    }
    else {
        ActionDetailViewController *actionDetailViewController = (ActionDetailViewController *)[groupsStoryboard instantiateViewControllerWithIdentifier: @"ActionDetailViewController"];
        actionDetailViewController.action = [CurrentUser sharedInstance].listOfActions[indexPath.row];
        [self.navigationController pushViewController:actionDetailViewController animated:YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.selectedSegment) {
        return 75.0;
    }
    else {
        self.tableView.estimatedRowHeight = 255.0;
        return self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}

#pragma mark - Segment Control

- (IBAction)segmentControlDidChange:(id)sender {
    [self configureEmptyState];
    self.segmentControl = (UISegmentedControl *) sender;
    self.selectedSegment = self.segmentControl.selectedSegmentIndex;
    if (self.currentUserID) {
        [self fetchFollowedGroupsForUserID:self.currentUserID];
    } else {
        [self userAuth];
    }

    [self.tableView reloadData];
}

@end
