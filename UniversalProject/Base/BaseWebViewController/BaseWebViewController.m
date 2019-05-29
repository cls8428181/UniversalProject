//
//  BaseWebViewController.m
//  Concubine
//
//  Created by ... on 16/7/15.
//  Copyright © 2016年 dengyun. All rights reserved.
//

#import "BaseWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "KNOCJSModel.h"
#import "MJRefresh.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "UIColor+Hex.h"

@interface NSURLRequest (ForSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;

@end


@implementation NSURLRequest (ForSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}

@end

NSString *const KNWebJavaScriptContext = @"documentView.webView.mainFrame.javaScriptContext";
NSString *const KNWebDocumentTitles = @"document.title";


@interface BaseWebViewController () <WKNavigationDelegate>
// JS_OC Model
@property (nonatomic, strong) KNOCJSModel *objectModel;
//分享相关
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareDesc;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *sharePictureUrl;

@property (nonatomic,assign) double lastProgress;//上次进度条位置
@end


@implementation BaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.naviView addLeftBarItemImageName:@"knb_back_black" target:self sel:@selector(backAction)];
    self.webView.frame = CGRectMake(0, KNB_NAV_HEIGHT, KNB_SCREEN_WIDTH, KNB_SCREEN_HEIGHT - KNB_NAV_HEIGHT);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)backAction {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//-(void)updateNavigationItems{
//    if (_isShowCloseBtn) {
//        if (self.webView.canGoBack) {
//            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//            [self addNavigationItemWithImageNames:@[@"back_icon",@"close_icon"] isLeft:YES target:self action:@selector(leftBtnClick:) tags:@[@2000,@2001]];
//        }else{
//            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//            if (kiOS9Later) {
//                [self addNavigationItemWithImageNames:@[@"back_icon"] isLeft:YES target:self action:@selector(leftBtnClick:) tags:@[@2001]];
//            }
//        }
//    }
//}

-(void)leftBtnClick:(UIButton *)btn{
    switch (btn.tag) {
        case 2000:
            [super backAction];
            
            break;
        case 2001:
        {
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            
            break;
        default:
            break;
    }
}


#pragma mark--通知
// 解决h5界面内嵌视频 状态栏丢失bug
- (void)addObserverNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeHidden:) name:UIWindowDidBecomeHiddenNotification object:nil];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)windowDidBecomeHidden:(NSNotification *)noti {
    UIWindow *win = (UIWindow *)noti.object;
    if (win) {
        UIViewController *rootVC = win.rootViewController;
        NSArray<__kindof UIViewController *> *vcs = rootVC.childViewControllers;
        if ([vcs.firstObject isKindOfClass:NSClassFromString(@"AVPlayerViewController")]) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        }
    }
}


#pragma mark - Private Method
- (void)addMJRefreshHeadView {
    KNB_WS(weakSelf);
    MJRefreshNormalHeader *webViewHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.webView.canGoBack) {
            [weakSelf.webView reload];
        } else {
            [weakSelf loadWebView];
        }
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    webViewHeader.automaticallyChangeAlpha = YES;
    // 隐藏时间
    webViewHeader.lastUpdatedTimeLabel.hidden = YES;
    self.webView.scrollView.mj_header = webViewHeader;
}

- (void)loadWebView {
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
//    NSString *mtmyUserId = [NSString stringWithFormat:@"%ld", (long)[KNBUserInfo shareInstance].mtmyUserId];
//    NSDictionary *dic = @{
//        @"userId" : mtmyUserId ?: @"",
//        @"fzxUserId" : [KNBUserInfo shareInstance].userId ?: @"",
//        @"cityName" : [KNGetUserLoaction shareInstance].cityName ?: @"",
//        @"version" : KNB_APP_VERSION,
//        @"client" : @"ios",
//        @"cityId" : [KNGetUserLoaction shareInstance].cityAreaId ?: @"",
//        @"isApp" : @"2",
//    };

//    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
//    [muDic addEntriesFromDictionary:[KNBGroManager shareInstance].userLocation];

//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:muDic options:NSJSONWritingPrettyPrinted error:nil];
//    NSString *userInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    if (!isNullStr(userInfo)) {
//        NSString *userInfoDes = [userInfo stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        [request addValue:userInfoDes forHTTPHeaderField:@"ClientUserInfo"];
//    }
//    [self.webView loadRequest:request];
}

//分享
//- (void)shareButtonAction:(UIButton *)sender {
//    if (isNullStr(self.shareTitle) || isNullStr(self.shareDesc) || isNullStr(self.urlString)) {
//        return;
//    }
//    KNBShareViewController *shareViewController = [[KNBShareViewController alloc] initWithContainStatinShare:YES];
//    shareViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    self.definesPresentationContext = YES;
//    KNB_WS(weakSelf);
//    shareViewController.shareVCBtnClick = ^(UMSocialPlatformType platfromType) {
//        if (platfromType == UMSocialPlatformType_KenuoTraining) {
//            KNBIMGoodsMessage *goodsMessage = [[KNBIMGoodsMessage alloc] init];
//            goodsMessage.goodsId = [self.adModel.ad_id intValue];
//            goodsMessage.goodsTitle = self.shareTitle;
//            goodsMessage.goodsContent = self.shareDesc;
//            goodsMessage.goodsPortraitUrl = self.sharePictureUrl;
//            goodsMessage.webUrl = self.urlString;
//            goodsMessage.msgType = @"3";
//            [KNBChoiceChatController pushWithContent:goodsMessage withCurrentController:self];
//            [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"KNB_StationShareType"];
//        } else {
//            [[KNUMManager shareInstance] shareWebPage:weakSelf toPlatformType:platfromType withTitle:self.shareTitle url:self.shareUrl descr:self.shareDesc shareImageName:self.sharePictureUrl withTransmit:NO];
//        }
//    };
//    [self presentViewController:shareViewController animated:YES completion:nil];
//}


#pragma mark -  UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self loadFailed:NO];
    
    self.naviView.title = [webView stringByEvaluatingJavaScriptFromString:KNWebDocumentTitles];
    
    JSContext *context = [webView valueForKeyPath:KNWebJavaScriptContext];
    // JS-OC
    context[@"native"] = self.objectModel;
    //OC-JS
    [context evaluateScript:@"isApp(2)"];
//    [context evaluateScript:[NSString stringWithFormat:@"pushFzxAppUserInfo(\"%@\")", [KNBUserInfo shareInstance].userId]];
    if (self.needGoBack) {
        [context evaluateScript:@"setTabindex()"];
    }
    //    2、都有效果
    NSString *js=@"var script = document.createElement('script');"
    "script.type = 'text/javascript';"
    "script.text = \"function ResizeImages() { "
    "var myimg,oldwidth;"
    "var maxwidth = %f;"
    "for(i=0;i <document.images.length;i++){"
    "myimg = document.images[i];"
    "if(myimg.width > maxwidth){"
    "oldwidth = myimg.width;"
    "myimg.width = %f;"
    "}"
    "}"
    "}\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    js=[NSString stringWithFormat:js,[UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.width-15];
    [webView stringByEvaluatingJavaScriptFromString:js];
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self loadFailed:YES];
}

- (void)loadFailed:(BOOL)failed {
    [self.webView.scrollView.mj_header endRefreshing];
    [self.progressView setProgress:1 animated:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [self.progressView setProgress:progress animated:YES];
}

#pragma mark - Getting && Setting
- (KNOCJSModel *)objectModel {
    if (!_objectModel) {
        _objectModel = [KNOCJSModel new];
        KNB_WS(weakSelf);
        _objectModel.goodsIdBlock = ^(NSString *goodsId, NSString *actionType) {
            KNB_PerformOnMainThread(^{
                
            });
        };
        _objectModel.popControllerBlock = ^(BOOL needDelay) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger timeDelay = needDelay ? 2 : 0;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            });
        };
        _objectModel.webViewPopBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        };
        _objectModel.webViewShareBlock = ^(NSString *title, NSString *describe, NSString *url) {
            weakSelf.shareTitle = title;
            weakSelf.shareDesc = describe;
            weakSelf.shareUrl = url;
        };
        _objectModel.gotoArticleDetailBlock = ^(NSInteger articleId) {
            KNB_PerformOnMainThread(^{
                
            });
        };
    }
    return _objectModel;
}

#pragma mark - BackButton
- (NSArray *)barButtonImageName:(NSString *)imgName sel:(SEL)sel {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 40, 44);
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
    [backBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [backBtn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    UIBarButtonItem *placeHolditem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil];
    return @[ item, placeHolditem ];
}

#pragma mark - UIBarButtonItemAction
- (void)leftBarButtonItemAction:(UIBarButtonItem *)item {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        if (self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


#pragma mark - 由子类继承
- (void)turnToAppStore {
    NSURL *urlString = [NSURL URLWithString:@"https://itunes.apple.com/cn/app/mei-tian-mei-ye/id1134417101?mt=8"];
    if ([[UIApplication sharedApplication] canOpenURL:urlString]) {
        [[UIApplication sharedApplication] openURL:urlString];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
