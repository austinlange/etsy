//
//  ALEtsyListingCollectionViewCell.h
//  Etsy Project
//
//  Created by Austin Lange on 12/21/14.
//  Copyright (c) 2014 Austin Lange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ALEtsyListingCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UILabel *titleLabel;
@property (nonatomic, strong, readonly) UIImageView *imageView;

+ (NSString *)identifier;
+ (CGSize)cellSize;

@end
