//
//  CZYLoginViewController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/3.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYLoginViewController.h"
#import "CZYXMPPTool.h"
#import "CZYUserInfo.h"
#import "MBProgressHUD+KR.h"
@interface CZYLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *userpwdTF;

@end

@implementation CZYLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *iconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    iconIV.frame = CGRectMake(0, 0, 55, 20);
    iconIV.contentMode = UIViewContentModeCenter;
    UIImageView *lockIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
    lockIV.frame = CGRectMake(0, 0, 55, 20);
    lockIV.contentMode = UIViewContentModeCenter;
    
    self.userNameTF.leftView = iconIV;
    self.userNameTF.leftViewMode = UITextFieldViewModeAlways;
    
    self.userpwdTF.leftView = lockIV;
    self.userpwdTF.leftViewMode = UITextFieldViewModeAlways;
    MYLog(@"测试mylog");


}
- (IBAction)loginBtnClick:(UIButton *)sender {
    if (self.userNameTF.text.length == 0  ) {
        [MBProgressHUD showError:@"请输入用户名"];
        return;
    }else if (self.userpwdTF.text.length == 0) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    //点击按钮将值传给单例对象
    CZYUserInfo *userInfo = [CZYUserInfo sharedCZYUserInfo];
    userInfo.username = self.userNameTF.text;   
    userInfo.userpwd = self.userpwdTF.text;
    userInfo.isRegister = NO;
    CZYXMPPTool *xmppTool  =[CZYXMPPTool sharedCZYXMPPTool];
    __weak typeof(self) weakSelf = self;
    [xmppTool userLogin:^(CZYXMPPResultType type) {
        [weakSelf header:type];
    }];
    MYLog(@"1");
}

- (void)header:(CZYXMPPResultType)type {
    switch (type) {
        case CZYXMPPResultTypeLoginSuccess:
            //跳转到主界面
        {
            MYLog(@"登录成功");
            [MBProgressHUD showMessage:@"登录成功"];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            //切换rootController的根视图控制器
            [UIApplication sharedApplication].keyWindow.rootViewController = [mainStoryboard instantiateInitialViewController];
            break;
        }
            
        case CZYXMPPResultTypeLoginFailed:
            [MBProgressHUD showError:@"登录失败"];
            break;
        case CZYXMPPResultTypeNetError:
            [MBProgressHUD showError:@"联网失败"];
            break;
        default:
            break;
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
