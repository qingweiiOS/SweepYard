////————————————————————————————————————————————————————————————
//                       .::::.             DSScanView.m
//                     .::::::::.
//                    :::::::::::           
//                 ..:::::::::::'
//              '::::::::::::'               Created by Mr.Qing on 2018/7/4.
//                .::::::::::
//           '::::::::::::::..              Copyright © 2018年 KESHANG. All rights reserved.
//                ..::::::::::::.
//              ``::::::::::::::::
//               ::::``:::::::::'        .:::.
//              ::::'   ':::::'       .::::::::.
//            .::::'      ::::     .:::::::'::::.
//           .:::'       :::::  .:::::::::' ':::::.
//          .::'        :::::.:::::::::'      ':::::.
//         .::'         ::::::::::::::'         ``::::.
//     ...:::           ::::::::::::'              ``::.
//    ```` ':.          ':::::::::'                  ::::..
//                       '.:::::'                    ':'````..
//——————————————————————————————————————————————————————————————

#import "DSScanView.h"

@implementation DSScanView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
        [self loadScanLine];//
        self.clipsToBounds = YES;
//
    }
    return self;

}
#pragma mark 『 重绘扫描区间 』
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 绘制边框
    CGContextAddRect(context, self.bounds);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokePath(context);
    // 绘制四角
    
    // 画笔颜色
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:56/255.0 green:1 blue:1 alpha:1.0].CGColor);
    // 画笔宽度
    CGContextSetLineWidth(context, 5.0);
    
    
    // 左上角：
    CGContextMoveToPoint(context, 0, 30);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 30, 0);
    CGContextStrokePath(context);
    
    
    // 右上角：
    CGContextMoveToPoint(context, self.bounds.size.width - 30, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 30);
    CGContextStrokePath(context);
    
    // 右下角：
    CGContextMoveToPoint(context, self.bounds.size.width, self.bounds.size.height - 30);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width - 30, self.bounds.size.height);
    CGContextStrokePath(context);
    
    // 左下角：
    CGContextMoveToPoint(context, 30, self.bounds.size.height);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, 0, self.bounds.size.height - 30);
    CGContextStrokePath(context);
}
- (void)dealloc{
    [self.timer invalidate];
}
- (void)loadScanLine
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(-5, -170, self.bounds.size.width+10, 170)];
        
        lineView.contentMode = UIViewContentModeScaleAspectFill;
        lineView.image = [UIImage imageNamed:@"ScanningLineGrid"];
        [self addSubview:lineView];
        [UIView animateWithDuration:5 delay: 0 options: UIViewAnimationOptionCurveLinear animations: ^{
            lineView.frame = CGRectMake(-5,self.bounds.size.height+170, self.bounds.size.width+10, 218);
        } completion:^(BOOL finished) {
            [lineView removeFromSuperview];
        }];
    }];
    
    self.timer.fireDate = [NSDate distantFuture];
}

@end
