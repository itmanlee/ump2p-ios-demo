//
//  UMProgressView.h
//
//  Created by fred on 2019/2/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMProgressView : UIView

@property (nonatomic, assign) CGFloat progress;

//进度条颜色
@property(nonatomic,strong) UIColor *progerssColor;
//进度条背景颜色
@property(nonatomic,strong) UIColor *progerssBackgroundColor;
//进度条的宽度
@property(nonatomic,assign) CGFloat progerWidth;
//进度数据字体大小
@property(nonatomic,assign) CGFloat percentageFontSize;
//进度数字颜色
@property(nonatomic,strong) UIColor *percentFontColor;

@end

NS_ASSUME_NONNULL_END
