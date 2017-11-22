//
//  CZYEditvCardViewController.m
//  酷跑
//
//  Created by hzxsdz030 on 15/12/7.
//  Copyright © 2015年 hzxsdz030. All rights reserved.
//

#import "CZYEditvCardViewController.h"
#import "CZYMyProfileViewController.h"
#import "CZYXMPPTool.h"
#import "UIImageView+CZYImageView.h"
@interface CZYEditvCardViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nikeNameTF;
@property (weak, nonatomic) IBOutlet UITextField *genderTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;

@end

@implementation CZYEditvCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.headImage setRoundLayer];

    self.headImage.userInteractionEnabled = YES;
    //添加点击imageView的手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeHeadImage)];
    [self.headImage addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.vCardTemp.photo) {
        self.headImage.image = [UIImage imageWithData:self.vCardTemp.photo];
    }else {
        self.headImage.image = [UIImage imageNamed:@"微信"];
    }
    self.nikeNameTF.text = self.vCardTemp.nickname;
}
#pragma mark - 更换头像
- (void)changeHeadImage {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"请选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"摄像头" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *pc = [[UIImagePickerController alloc] init];
        pc.delegate = self;
        pc.allowsEditing = YES;
        pc.sourceType = UIImagePickerControllerCameraCaptureModeVideo;
        [self presentViewController:pc animated:YES completion:nil];
    }];
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"从相册中选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *pc = [[UIImagePickerController alloc] init];
        pc.delegate = self;
        pc.allowsEditing = YES;
        pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pc animated:YES completion:nil];
    }];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [actionSheet addAction:camera];
    [actionSheet addAction:album];
    [actionSheet addAction:cancle];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}
- (IBAction)saveUserInfo:(UIBarButtonItem *)sender {
    self.vCardTemp.photo = UIImagePNGRepresentation(self.headImage.image);
    self.vCardTemp.nickname = self.nikeNameTF.text;
    self.roster.nickname = self.nikeNameTF.text;
    [[CZYXMPPTool sharedCZYXMPPTool].xmppvCard updateMyvCardTemp:self.vCardTemp];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)nikeName:(UITextField *)sender {
    [self.genderTF becomeFirstResponder];
}
- (IBAction)gender:(UITextField *)sender {
    [self.ageTF becomeFirstResponder];
}
- (IBAction)age:(UITextField *)sender {
    [self.ageTF resignFirstResponder];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@",info);
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.headImage.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
