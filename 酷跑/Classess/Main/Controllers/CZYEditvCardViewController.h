//
//  CZYEditvCardViewController.h
//  酷跑
//
//  Created by hzxsdz030 on 15/12/7.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPvCardTemp.h"
#import "XMPPUserCoreDataStorageObject.h"
@interface CZYEditvCardViewController : UIViewController
@property (nonatomic, strong) XMPPvCardTemp *vCardTemp;
@property (nonatomic, strong) XMPPUserCoreDataStorageObject *roster;
@end
