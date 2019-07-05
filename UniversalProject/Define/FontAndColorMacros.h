//
//  FontAndColorMacros.h
//  MiAiApp
//
//  Created by 徐阳 on 2017/5/18.
//  Copyright © 2017年 徐阳. All rights reserved.
//

//字体大小和颜色配置

#ifndef FontAndColorMacros_h
#define FontAndColorMacros_h

#pragma mark -  间距区

//默认间距
#define KNormalSpace 12.0f

#pragma mark -  颜色区
//主题色 导航栏颜色
#define CNavBgColor  [UIColor colorWithHexString:@"00AE68"]
//#define CNavBgColor  [Ulor colorWithHexString:@"ffffff"]
#define CNavBgFontColor  [UIColor colorWithHexString:@"ffffff"]
//默认字体颜色
#define CDefaultFontColor kColor(0x333333)
//默认页面背景色
#define CViewBgColor [UIColor colorWithHexString:@"f2f2f2"]
//分割线颜色
#define CLineColor [UIColor colorWithHexString:@"ededed"]
//次级字色
#define CFontColor1 [UIColor colorWithHexString:@"1f1f1f"]
//再次级字色
#define CFontColor2 [UIColor colorWithHexString:@"5c5c5c"]

#define kColor(color) [UIColor colorWithHex:color]

#pragma mark -  字体区
//字体大小
#define kFont(font) [UIFont systemFontOfSize:font]

#pragma mark - 图片区
//图片名字 k
#define IMAGE_NAMED(imageName) [UIImage imageNamed:imageName]
//图片地址
#define IMAGE_URL(imageUrl) [NSURL URLWithString:imageUrl]

#define ImageWithFile(_pointer) [UIImage imageWithContentsOfFile:([[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%dx", _pointer, (int)[UIScreen mainScreen].nativeScale] ofType:@"png"])]

#pragma mark - 自定义区
#define kPortraitPlaceHolderName @"knb_default_user"
#define kPortraitPlaceHolder kImages(kPortraitPlaceHolderName)

#endif /* FontAndColorMacros_h */
