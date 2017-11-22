//
//  CZYChatViewController.h
//  酷跑
//
//  Created by hzxsdz030 on 15/12/9.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPJID.h"
@interface CZYChatViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForBottom;
@property (nonatomic, strong) XMPPJID *friendJid;
@end
