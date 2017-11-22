//
//  UIImageView+CZYImageView.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/8.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "UIImageView+CZYImageView.h"

@implementation UIImageView (CZYImageView)
- (void)setRoundLayer {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.bounds.size.width*0.5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor cyanColor].CGColor;
}
@end
