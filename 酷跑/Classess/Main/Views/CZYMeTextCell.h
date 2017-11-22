//
//  CZYMeTextCell.h
//  酷跑
//
//  Created by hzxsdz030 on 15/12/9.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZYMeTextCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *chatTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *popImageView;
@property (weak, nonatomic) IBOutlet UIImageView *friendHeadImageView;
@property (weak, nonatomic) IBOutlet UILabel *friendChatTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *friendPopImageView;
@end
