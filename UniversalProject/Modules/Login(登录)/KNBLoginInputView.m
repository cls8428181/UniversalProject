//
//  KNBLoginInputView.m
//  FishFinishing
//
//  Created by 常立山 on 2019/3/27.
//  Copyright © 2019 常立山. All rights reserved.
//

#import "KNBLoginInputView.h"
#import "KNBButton.h"

#define KNBTimerInvalue 60

@interface KNBLoginInputView () <UITextFieldDelegate>
//线
@property (nonatomic, strong) UIView *lineView;
//icon
@property (nonatomic, strong) UIImageView *iconImageView;
//标题
@property (nonatomic, strong) UILabel *titleLabel;
//获取验证码
@property (nonatomic, strong) KNBButton *timeButton;
//显示隐藏密码
@property (nonatomic, strong) KNBButton *showOrHidenButton;
//视图类型
@property (nonatomic, assign) KNBLoginInputViewType viewType;
//定时器
@property (nonatomic) dispatch_source_t theTimer;
@end

@implementation KNBLoginInputView

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame viewType:(KNBLoginInputViewType)viewType {
    if (self = [super initWithFrame:frame]) {
        self.viewType = viewType;
        if (viewType == KNBLoginInputViewTypeMobileAndIcon) {//手机号并展示icon
            self.textField.placeholder = @"请输入手机号";
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
            [self addSubview:self.textField];
            [self addSubview:self.iconImageView];
            [self.textField addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
            self.iconImageView.image = [UIImage imageNamed:@"knb_login_phone"];
        } else if (viewType == KNBLoginInputViewTypeMobileAndText) {//手机号并展示文字
            self.textField.placeholder = @"请输入手机号";
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
            [self addSubview:self.textField];
            [self addSubview:self.titleLabel];
            [self.textField addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
            self.titleLabel.text = @"手机号";
        } else if (viewType == KNBLoginInputViewTypeVerify) {//验证码
            self.textField.placeholder = @"请输入验证码";
            self.textField.keyboardType = UIKeyboardTypeNumberPad;
            [self addSubview:self.textField];
            [self addSubview:self.timeButton];
            [self addSubview:self.titleLabel];
            self.titleLabel.text = @"验证码";
        } else if (viewType == KNBLoginInputViewTypePassword) {//密码
            self.textField.placeholder = @"请输入密码";
            [self addSubview:self.textField];
            [self addSubview:self.iconImageView];
            self.textField.secureTextEntry = YES;
            self.iconImageView.image = [UIImage imageNamed:@"knb_login_password"];
        } else {
            self.textField.placeholder = @"请输入密码";
            [self addSubview:self.textField];
            [self addSubview:self.showOrHidenButton];
            [self addSubview:self.titleLabel];
            self.textField.secureTextEntry = YES;
            if (viewType == KNBLoginInputViewTypeSetPassword) {//设置密码
                self.titleLabel.text = @"设置密码";
            } else if (viewType == KNBLoginInputViewTypeNewPassword) {//新的密码
                self.titleLabel.text = @"新的密码";
            } else {//确认密码
                self.titleLabel.text = @"确认密码";
            }
        }
        [self addSubview:self.lineView];
        
        self.textField.tintColor = [UIColor colorWithHex:0xffb0a1];
        [self.textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//        [self addGestureRecognizer:[self addTapGesture]];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(1);
    }];
    
    if (self.viewType == KNBLoginInputViewTypeMobileAndIcon || self.viewType == KNBLoginInputViewTypePassword) {//手机号并展示icon || 密码并展示icon
        [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(45);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(self.lineView.mas_top).offset(0);
            make.height.mas_equalTo(40);
        }];
        [self.iconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(self.lineView.mas_top).offset(-10);
        }];
    } else if (self.viewType == KNBLoginInputViewTypeMobileAndText) {//手机号并展示文字
        [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(85);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(self.lineView.mas_top).offset(0);
            make.height.mas_equalTo(40);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(self.lineView.mas_top).offset(-10);
        }];
    } else if (self.viewType == KNBLoginInputViewTypeVerify) {//验证码
        [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(85);
            make.right.mas_equalTo(55);
            make.bottom.mas_equalTo(self.lineView.mas_top).offset(0);
            make.height.mas_equalTo(40);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(self.lineView.mas_top).offset(-10);
        }];
        [self.timeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.textField.mas_centerY);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(40);
            make.width.mas_equalTo(60);
        }];
    } else {
        [self.textField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(85);
            make.right.mas_equalTo(55);
            make.bottom.mas_equalTo(self.lineView.mas_top).offset(0);
            make.height.mas_equalTo(40);
        }];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(self.lineView.mas_top).offset(-10);
        }];
        [self.showOrHidenButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.textField.mas_centerY);
            make.right.mas_equalTo(0);
        }];
    }
}

- (void)timerControll:(BOOL)startTimer {
    if (!startTimer) {
        if (self.theTimer != nil) {
            dispatch_source_cancel(self.theTimer);
        }
        [self.timeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    } else {
        __block int timeout = KNBTimerInvalue; //倒计时时间
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), 1.0 * NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            if (timeout <= 0) { //倒计时结束，关闭
                dispatch_source_cancel(_timer);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.timeButton setTitle:@"重新获取" forState:UIControlStateNormal];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //设置界面的按钮显示 根据自己需求设置
                    [self.timeButton setTitle:[NSString stringWithFormat:@"(%ds)", timeout] forState:UIControlStateNormal];
                });
                timeout--;
            }
        });
        self.theTimer = _timer;
        dispatch_resume(_timer);
    }
}

#pragma mark - Event Response
- (void)selectVeriNumClick:(KNBButton *)sender {
    if (self.getVerifyCodeBlock) {
        self.getVerifyCodeBlock();
    }
}

- (void)showOrHidenButtonClick:(KNBButton *)sender {
    [sender sizeToFit];
    //两种状态图片不一致
    [sender mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.textField.mas_centerY);
        make.right.mas_equalTo(0);
    }];
    self.textField.secureTextEntry = sender.selected;
    sender.selected = !sender.selected;
}

//手机号
- (void)textFieldEditingChanged {
    if (self.textField.text.length >= 11) {
        self.textField.text = [self.textField.text substringToIndex:11];
//        !self.inverTelNumBlock ?: self.inverTelNumBlock();
        [self.textField endEditing:YES];
    }
}

#pragma mark - Getters And Setters
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.textColor = [UIColor whiteColor];
        _textField.font = kFont(16);
        _textField.secureTextEntry = NO;
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeyDone;
        [_textField setValue:kFont(14) forKeyPath:@"_placeholderLabel.font"];
    }
    return _textField;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHex:0xffffff];
    }
    return _lineView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = kFont(16);
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (KNBButton *)timeButton {
    if (!_timeButton) {
        _timeButton = [KNBButton buttonWithType:UIButtonTypeCustom];
        [_timeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        _timeButton.titleLabel.font = kFont(11);
        [_timeButton setTitleColor:[UIColor colorWithHex:0x009fe8] forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(selectVeriNumClick:) forControlEvents:UIControlEventTouchUpInside];
        _timeButton.titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeButton;
}
- (KNBButton *)showOrHidenButton {
    if (!_showOrHidenButton) {
        _showOrHidenButton = [KNBButton buttonWithType:UIButtonTypeCustom];
        [_showOrHidenButton setImage:IMAGE_NAMED(@"knb_login_invisible") forState:UIControlStateNormal];
        [_showOrHidenButton setImage:IMAGE_NAMED(@"knb_login_eye") forState:UIControlStateSelected];
        [_showOrHidenButton addTarget:self action:@selector(showOrHidenButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showOrHidenButton;
}

//- (UITapGestureRecognizer *)addTapGesture {
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyborad)];
//    return tap;
//}

@end
