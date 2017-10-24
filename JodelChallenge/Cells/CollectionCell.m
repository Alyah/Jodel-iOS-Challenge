//
//  CollectionCell.m
//  FlickrTest
//
//  Created by Dmitry on 14/03/2017.
//  Copyright © 2017 company. All rights reserved.
//

#import "CollectionCell.h"
#import "UIImageView+AFNetworking.h"

@interface CollectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CollectionCell

- (void)setupWithPhoto:(NSURL *)url {
    [self.imageView setImageWithURL:url];
}


@end
