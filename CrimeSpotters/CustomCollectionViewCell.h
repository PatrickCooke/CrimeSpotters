//
//  CustomCollectionViewCell.h
//  CrimeSpotters
//
//  Created by Patrick Cooke on 5/20/16.
//  Copyright © 2016 Patrick Cooke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel        *itemLabel;
@property (nonatomic, weak) IBOutlet UIImageView    *itemImageView;
@property (nonatomic,weak)  IBOutlet  UIActivityIndicatorView   *activityIndicator;

@end
