//
//  CZYMyMessageCell.h
//  酷跑
//
//  Created by hzxsdz030 on 15/12/9.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZYMyMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *nikeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
