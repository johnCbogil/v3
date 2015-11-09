//
//  CongressViewController.h
//  v2
//
//  Created by John Bogil on 7/23/15.
//  Copyright (c) 2015 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfluenceExplorerViewController.h"
#import "CustomAlertViewController.h"
#import "CongresspersonTableViewCell.h"

@interface CongressViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CustomAlertDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) InfluenceExplorerViewController *influenceExplorerVC;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

