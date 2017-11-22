//
//  CZYContactTableViewCell.h
//  酷跑
//
//  Created by hzxsdz030 on 15/12/8.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CZYContactTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *friendHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *friendNikeName;
@property (weak, nonatomic) IBOutlet UILabel *friendSignature;
@property (weak, nonatomic) IBOutlet UILabel *status;

@end
