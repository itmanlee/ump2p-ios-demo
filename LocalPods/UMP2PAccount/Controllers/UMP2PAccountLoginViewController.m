//
//  UMP2PAccountLoginViewController
//  UMP2PAccount
//
//  Created by Fred on 2019/3/15.
//
#import "UMP2PAccountLoginViewController.h"
#import "UMP2PAccountLoginView.h"
#import "UMP2PAccountLoginViewModel.h"
#import "UMP2PRegisterViewController.h"

#import <SVProgressHUD/SVProgressHUD.h>
#import <Masonry/Masonry.h>
@interface UMP2PAccountLoginViewController()

@property (nonatomic, strong) UMP2PAccountLoginView *mView;
@property (nonatomic, strong) UMP2PAccountLoginViewModel *viewModel;
@end
@implementation UMP2PAccountLoginViewController

/// 初始化数据
- (void)initialDefaultsForController{
    
}

/// 配置导航栏
- (void)configNavigationForController{
    
}

/// 创建视图
- (void)createViewForConctroller{
    [self.view addSubview:self.mView];
    [self.view setNeedsUpdateConstraints];
}

/// 绑定 vm
- (void)bindViewModelForController{
    [self.mView.loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.mView.forgotBtn addTarget:self action:@selector(forgotPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.mView.smsBtn addTarget:self action:@selector(pushSMS) forControlEvents:UIControlEventTouchUpInside];
    [self.mView.registerBtn addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mView bindViewModel:self.viewModel withParams:nil];
}

- (void)updateViewConstraints{
    [self.mView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    [super updateViewConstraints];
}

#pragma mark -
- (void)login{
    [SVProgressHUD show];
    [self.viewModel subscribeNext:^(id x) {
        [SVProgressHUD um_displaySuccessWithStatus:@"登录成功"];
        // 进入设备列表界面
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } error:^(NSError *error) {
        [SVProgressHUD um_displayErrorWithStatus:error.localizedDescription];
    } api:UMHAPICmdLogin];
    
}

- (void)forgotPassword{
    [SVProgressHUD show];
    [self.viewModel subscribeNext:^(id x) {
        [SVProgressHUD um_displaySuccessWithStatus:@"找回密码成功"];
    } error:^(NSError *error) {
        [SVProgressHUD um_displayErrorWithStatus:error.localizedDescription];
    } api:UMHAPICmdFindPwd];
    
}

- (void)pushSMS{
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionPush = [UIAlertAction actionWithTitle:@"请求短信验证码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        [self.viewModel subscribeNext:^(id x) {
            [SVProgressHUD um_displaySuccessWithStatus:@"请求短信成功"];
        } error:^(NSError *error) {
            [SVProgressHUD um_displayErrorWithStatus:error.localizedDescription];
        } api:UMHAPICmdPushSMS];
    }];
    
    UIAlertAction *actionEmail = [UIAlertAction actionWithTitle:@"请求邮箱验证码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SVProgressHUD show];
        [self.viewModel subscribeNext:^(id x) {
            [SVProgressHUD um_displaySuccessWithStatus:@"请求邮件成功"];
        } error:^(NSError *error) {
            [SVProgressHUD um_displayErrorWithStatus:error.localizedDescription];
        } api:UMHAPICmdPushEmail];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [ac addAction:actionPush];
    [ac addAction:actionEmail];
    [ac addAction:actionCancel];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)registerUser{
    UMP2PRegisterViewController *vc = [[UMP2PRegisterViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
#pragma mark -
- (UMP2PAccountLoginView *)mView{
    if (!_mView) {
        _mView = [[UMP2PAccountLoginView alloc] init];
    }
    return _mView;
}

- (UMP2PAccountLoginViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[UMP2PAccountLoginViewModel alloc] init];
    }
    return _viewModel;
}
@end
