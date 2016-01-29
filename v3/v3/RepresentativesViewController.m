//
//  RepresentativesViewController.m
//  Voices
//
//  Created by Bogil, John on 1/22/16.
//  Copyright © 2016 John Bogil. All rights reserved.
//

#import "RepresentativesViewController.h"
#import "CongresspersonTableViewCell.h"
#import "StateRepTableViewCell.h"
#import "NYCRepresentativeTableViewCell.h"
#import "RepManager.h"
#import "LocationService.h"
#import "CacheManager.h"
#import "NetworkManager.h"

@interface RepresentativesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIView *zeroStateContainer;
@property (strong, nonatomic) NSString *tableViewCellName;
@property (strong, nonatomic) NSString *cachedRepresentatives;
@property (strong, nonatomic) NSArray *tableViewDataSource;
@end

@implementation RepresentativesViewController

- (void)viewWillAppear:(BOOL)animated {
    [self setDataSources];
    [self addObservers];
    [self checkCache];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDataSources];
    [self createTableView];
    [self checkLocationAuthorizationStatus];
    [self createRefreshControl];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[LocationService sharedInstance]removeObserver:self forKeyPath:@"currentLocation" context:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOn) name:@"turnZeroStateOn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(turnZeroStateOff) name:@"turnZeroStateOff" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endRefreshing) name:@"endRefreshing" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableView) name:@"reloadData" object:nil];
    [[LocationService sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setDataSources {
    if (self.index == 0) {
        self.tableViewCellName = @"CongresspersonTableViewCell";
        self.cachedRepresentatives = @"cachedCongresspersons";
        self.tableViewDataSource = [RepManager sharedInstance].listOfCongressmen;
    }
    else if (self.index == 1) {
        self.tableViewCellName = @"StateRepTableViewCell";
        self.cachedRepresentatives = @"cachedStateLegislators";
        self.tableViewDataSource = [RepManager sharedInstance].listOfStateLegislators;
    }
    else if (self.index == 2) {
        self.tableViewCellName = @"NYCRepresentativeTableViewCell";
        self.cachedRepresentatives = @"cachedNYCRepresentatives";
        self.tableViewDataSource = [RepManager sharedInstance].listOfNYCRepresentatives;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:self.tableViewCellName bundle:nil] forCellReuseIdentifier:self.tableViewCellName];
}

#pragma mark - UI Methods

- (void)createTableView {
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//    if (self.index == 0) {
        [self.tableView registerNib:[UINib nibWithNibName:self.tableViewCellName bundle:nil]forCellReuseIdentifier:self.tableViewCellName];
//    }
//    else if (self.index == 1) {
//        [self.tableView registerNib:[UINib nibWithNibName:@"StateRepTableViewCell" bundle:nil]forCellReuseIdentifier:@"StateRepTableViewCell"];
//    }
//    else if ([self.title isEqualToString:@"NYC Council"]) {
//        [self.tableView registerNib:[UINib nibWithNibName:@"NYCRepresentativeTableViewCell" bundle:nil]forCellReuseIdentifier:@"NYCRepresentativeTableViewCell"];
//    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (void)checkCache {
//    if (self.index == 0) {
        [[CacheManager sharedInstance] checkCacheForRepresentative:self.cachedRepresentatives];
//    }
//    else if (self.index == 1) {
//        [[CacheManager sharedInstance] checkCacheForRepresentative:@"cachedStateLegislators"];
//    }
//    else if (self.index == 2) {
//        [[CacheManager sharedInstance]checkCacheForRepresentative:@"cachedNYCRepresentatives"];
//    }
}

- (void)turnZeroStateOn {
    [UIView animateWithDuration:.25 animations:^{
        self.zeroStateContainer.alpha = 1;
    }];
}

- (void)turnZeroStateOff {
    [UIView animateWithDuration:.25 animations:^{
        self.zeroStateContainer.alpha = 0;
    }];
}

- (void)endRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (void)createRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateCurrentLocation) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

#pragma mark - UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.index == 0) {
        if ([RepManager sharedInstance].listOfCongressmen.count > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[RepManager sharedInstance].listOfCongressmen] forKey:@"cachedCongresspersons"];
        }
        return [RepManager sharedInstance].listOfCongressmen.count;
    }
    else if (self.index == 1) {
        if ([RepManager sharedInstance].listOfStateLegislators.count > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[RepManager sharedInstance].listOfStateLegislators] forKey:@"cachedStateLegislators"];
        }
        return [RepManager sharedInstance].listOfStateLegislators.count;
    }
    else if (self.index == 2) {
        if ([RepManager sharedInstance].listOfNYCRepresentatives) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[RepManager sharedInstance].listOfNYCRepresentatives] forKey:@"cachedNYCRepresentatives"];
        }
        return [RepManager sharedInstance].listOfNYCRepresentatives.count;
    }
    else {
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView dequeueReusableCellWithIdentifier:self.tableViewCellName];
    [cell initFromIndexPath:indexPath];
    return cell;
//    if (self.index == 0) {
//        CongresspersonTableViewCell *cell = (CongresspersonTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CongresspersonTableViewCell" forIndexPath:indexPath];
//        [cell initFromIndexPath:indexPath];
//        return cell;
//    }
//    else if (self.index == 1) {
//        StateRepTableViewCell *cell = (StateRepTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"StateRepTableViewCell" forIndexPath:indexPath];
//        [cell initFromIndexPath:indexPath];
//        return cell;
//    }
//    else if (self.index == 2){
//        NYCRepresentativeTableViewCell *cell = (NYCRepresentativeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"NYCRepresentativeTableViewCell" forIndexPath:indexPath];
//        [cell initFromIndexPath:indexPath];
//        return cell;
//    }
//    else {
//        return nil;
//    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 140;
}

#pragma mark - LocationServices Methods

- (void)updateCurrentLocation {
    [[LocationService sharedInstance]startUpdatingLocation];
}

- (void)checkLocationAuthorizationStatus {
    if ([CLLocationManager authorizationStatus] <= 2) {
        [self turnZeroStateOn];
    }
    else {
        [self turnZeroStateOff];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object  change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"currentLocation"]) {
        [self getRepresentativesForCurrentLocation];
        [self.refreshControl endRefreshing];
    }
}

- (void)getRepresentativesForCurrentLocation {
    if (self.index == 0) {
        [[RepManager sharedInstance]createCongressmenFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } onError:^(NSError *error) {
            NSLog(@"error");
        }];
    }
    else if (self.index == 1) {
        [[RepManager sharedInstance]createStateLegislatorsFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } onError:^(NSError *error) {
            NSLog(@"error");
        }];
    }
    else if (self.index == 2){
        [[RepManager sharedInstance]createNYCRepresentativesFromLocation:[LocationService sharedInstance].currentLocation WithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        } onError:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
    });
}
@end