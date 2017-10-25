//
//  CollectionCell.h
//  FlickrTest
//
//  Created by Dmitry on 14/03/2017.
//  Copyright © 2017 company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)setupWithPhoto:(NSURL *)url;
- (void)setupWithTitle:(NSString *)title;

@end
