//
//  CZYMyProfileViewController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/7.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYMyProfileViewController.h"
#import "CZYUserInfo.h"
#import "XMPPvCardTemp.h"
#import "CZYEditvCardViewController.h"
#import "CZYXMPPTool.h"
#import "UIImageView+CZYImageView.h"
#import "CZYEditvCardViewController.h"
@interface CZYMyProfileViewController ()

@property (nonatomic,strong) XMPPvCardTemp *vCardTemp;
@end

@implementation CZYMyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MYLog(@"2");
    // Do any additional setup after loading the view.
    XMPPvCardTemp *vCardTemp = [CZYXMPPTool sharedCZYXMPPTool].xmppvCard.myvCardTemp;
    self.nickName.text = [CZYUserInfo sharedCZYUserInfo].username;
    if (vCardTemp.photo) {
        self.headImage.image = [UIImage imageWithData:vCardTemp.photo];
    }else {
        self.headImage.image = [UIImage imageNamed:@"placehoder"];
        vCardTemp.photo = UIImagePNGRepresentation(self.headImage.image);
    }
    [self.headImage setRoundLayer];
    self.vCardTemp = vCardTemp;
    
//    self.gender.text = self.vCardTemp.givenName;
//    self.age.text = self.vCardTemp.middleName;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.nickName.text = self.vCardTemp.nickname;
}
#pragma mark - 退出登录
- (IBAction)loginOut:(UIButton *)sender {
    CZYUserInfo *userInfo = [CZYUserInfo sharedCZYUserInfo];
    [userInfo saveCZYUserInfoToSandBox];
    userInfo.jid = nil;
    if (userInfo.sinaLogin) {
        userInfo.sinaLogin = NO;
        userInfo.username = nil;
    }
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"LoginAndRegister" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = [loginStoryboard instantiateInitialViewController];
}

- (IBAction)backProfilebtnClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //获取导航控制器
    UINavigationController *navi = segue.destinationViewController;
    //判断当前控制器对象是否是edit控制器的当前类或父类的对象
    
    if ([[navi topViewController] isKindOfClass:[CZYEditvCardViewController class]]) {
        CZYEditvCardViewController *editvCardVC = (CZYEditvCardViewController*)[navi topViewController];
        editvCardVC.vCardTemp = self.vCardTemp;
    }
}


@end
