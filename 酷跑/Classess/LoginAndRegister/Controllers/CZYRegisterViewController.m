//
//  CZYRegisterViewController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/3.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYRegisterViewController.h"
#import "CZYUserInfo.h"
#import "CZYXMPPTool.h"
#import "MBProgressHUD+KR.h"
#import "AFNetworking.h"
#import "NSString+md5.h"
@interface CZYRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *userpwdTF;

@end

@implementation CZYRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)registerClick:(UIButton *)sender {
    CZYUserInfo *userInfo = [CZYUserInfo sharedCZYUserInfo];
    userInfo.registerName = self.userNameTF.text;
    userInfo.registerPwd = self.userpwdTF.text;
    userInfo.isRegister = YES;
    CZYXMPPTool *xmppTool = [CZYXMPPTool sharedCZYXMPPTool];
    //弱引用self
    __weak typeof (self) weakSelf = self;
    [xmppTool userLogin:^(CZYXMPPResultType type) {
        [weakSelf handleXMPPResult:type];
    }];
    
    
    
    
}

- (void)handleXMPPResult:(CZYXMPPResultType)type {
    switch (type) {
        case CZYXMPPResultTypeRegisterSuccess:
            [MBProgressHUD showMessage:@"注册成功"];
            [self sendRegisterUserToWebServer];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case CZYXMPPResultTypeRegisterFailed:
            [MBProgressHUD showError:@"注册失败"];
            break;
        case CZYXMPPResultTypeNetError:
            [MBProgressHUD showError:@"联网失败"];
            break;
        default:
            break;
    }

}

#pragma mark - 发送注册信息到web服务器

- (void)sendRegisterUserToWebServer {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //请求的URL
    NSString *urlStr = [NSString stringWithFormat:@"http://%@:8080/allRunServer/register.jsp",CZYXMPPHOSTNAME];
    NSMutableDictionary *parmaters = [NSMutableDictionary dictionary];
    CZYUserInfo *userInfo = [CZYUserInfo sharedCZYUserInfo];
    parmaters[@"username"] = userInfo.registerName;
    parmaters[@"md5password"] = [userInfo.registerPwd md5Str];
    MYLog(@"%@",parmaters[@"md5password"]);
    parmaters[@"nikename"] = userInfo.registerName;
//    parmaters[@"gender"] = @"1";
//    parmaters[@""];
    
    [manager POST:urlStr parameters:parmaters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        UIImage *image = [UIImage imageNamed:@"512"];
        NSData *data = UIImagePNGRepresentation(image);
        [formData appendPartWithFileData:data name:@"pic" fileName:@"headerImage.png" mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        MYLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [MBProgressHUD showError:@"图片上传失败"];
    }];

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIImageView *iconIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon"]];
    iconIV.contentMode = UIViewContentModeCenter;
    iconIV.frame = CGRectMake(0, 0, 55, 20);
    self.userNameTF.leftView = iconIV;
    self.userNameTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *lockIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock"]];
    lockIV.contentMode = UIViewContentModeCenter;
    lockIV.frame = CGRectMake(0, 0, 55, 20);
    
    self.userpwdTF.leftView = lockIV;
    self.userpwdTF.leftViewMode = UITextFieldViewModeAlways;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
