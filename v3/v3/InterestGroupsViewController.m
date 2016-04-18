//
//  InterestGroupsViewController.m
//  Voices
//
//  Created by John Bogil on 12/19/15.
//  Copyright © 2015 John Bogil. All rights reserved.
//

#import "InterestGroupsViewController.h"
#import <Parse/Parse.h>

@interface InterestGroupsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *listOfInterestGroups;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (nonatomic) NSInteger selectedSegment;
@property (strong, nonatomic) NSMutableArray *tableViewData;
@end

@implementation InterestGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // FIND OUT WHERE THIS NAVIGATION CONTROLLER IS COMING FROM. I SHOULDN'T HAVE TO HIDE IT
    self.navigationController.navigationBar.hidden = YES;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self exampleUserSignUp];
    [self retrieveInterestGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewData.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [(NSString*)[self.tableViewData objectAtIndex:indexPath.row]valueForKey:@"Name"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.selectedSegment == 0) {
        [self followInterestGroup:[self.tableViewData objectAtIndex:indexPath.row]];
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
        [self removeFollower:self.tableViewData[indexPath.row]];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (IBAction)segmentControlDidChange:(id)sender {
    self.segmentControl = (UISegmentedControl *) sender;
    self.selectedSegment = self.segmentControl.selectedSegmentIndex;
    
    if (self.selectedSegment == 0) {
        [self retrieveInterestGroups];
    }
    else{
        [self retrieveFollowedInterestGroups];
    }
}

#pragma mark - Parse Methods

- (void)retrieveFollowedInterestGroups {
    PFQuery *query = [PFQuery queryWithClassName:@"InterestGroups"];
    [query whereKey:@"followers" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Retrieve Selected Interest Groups Success");
            self.tableViewData = [[NSMutableArray alloc]initWithArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Retrieve Selected Interest Groups Error: %@", error);
        }
    }];
}

- (void)retrieveInterestGroups {
    PFQuery *query = [PFQuery queryWithClassName:@"InterestGroups"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Retrieve Interest Groups Success");
            self.tableViewData = [[NSMutableArray alloc]initWithArray:objects];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Retrieve Interest Group Error: %@", error);
        }
    }];
}

- (void)exampleUserSignUp {
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog(@"Anonymous login failed.");
        } else {
            NSLog(@"Anonymous user logged in.");
        }
    }];
}

- (void)followInterestGroup:(PFObject*)object {
    [[PFInstallation currentInstallation]addUniqueObject:object.objectId forKey:@"channels"];
    [[PFInstallation currentInstallation]saveInBackground];
    [object addUniqueObject:[PFUser currentUser].objectId forKey:@"followers"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Followed!");
        }
        else {
            NSLog(@"Follow Error: %@", error);
        }
    }];
}

- (void)removeFollower:(PFObject*)object {
    [[PFInstallation currentInstallation]removeObject:object.objectId forKey:@"channels"];
    [[PFInstallation currentInstallation]saveInBackground];
    [self.tableViewData removeObject:object];
    [object removeObjectForKey:@"followers"];
    [object save];
}

@end