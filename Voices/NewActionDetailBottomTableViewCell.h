//
//  NewActionDetailBottomTableViewCell.h
//  Voices
//
//  Created by John Bogil on 3/26/17.
//  Copyright © 2017 John Bogil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Action.h"
#import "Representative.h"

@protocol SelectRepDelegate <NSObject>

- (void) sendRepToViewController:(Representative *)rep;

@end

@interface NewActionDetailBottomTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) Representative *selectedRep;
@property (strong, nonatomic) NSMutableArray *listOfRepCells;
@property (strong, nonatomic) NSArray *repsArray;
@property (weak, nonatomic) IBOutlet UILabel *selectRepLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) id <SelectRepDelegate> delegate;
- (void)initWithAction:(Action *)action;

@end