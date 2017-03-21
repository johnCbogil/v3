//
//  NewActionDetailTableViewCell.m
//  Voices
//
//  Created by John Bogil on 3/20/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import "NewActionDetailTableViewCell.h"
#import "ActionRepCollectionViewCell.h"

@interface NewActionDetailTableViewCell() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *groupLogo;
@property (weak, nonatomic) IBOutlet UILabel *actionTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *selectRepLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) Action *action;
@property (strong, nonatomic) Group *group;
@property (strong, nonatomic) NSArray *repsArray;

@end

@implementation NewActionDetailTableViewCell

- (void)initWithGroup:(Group *)group andAction:(Action *)action {
    
    self.group = group;
    self.action = action;
    self.repsArray = @[@"one", @"two", @"three"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ActionRepCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ActionRepCollectionViewCell"];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fetchGroupLogoForImageURL:(NSURL *)url {
    
}

#pragma mark - UICollectionView Delegate methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.repsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ActionRepCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ActionRepCollectionViewCell" forIndexPath:indexPath];
    // CELL INIT WITH REP
    return cell;
}
@end
