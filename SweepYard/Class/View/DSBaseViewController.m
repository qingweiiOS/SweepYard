////————————————————————————————————————————————————————————————
//                       .::::.             DSBaseViewController.m
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
#import "DSBaseViewController.h"

@interface DSBaseViewController ()

@end

@implementation DSBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  configurationUI];
}
- (void)configurationUI{

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17.0]}];
    self.navigationController.navigationBar.translucent = NO;
    //统一返回
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 20, 20)] ;
    [self.backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:self.backBtn];
    if(self.navigationController.viewControllers.count>1)
    {
        self.navigationItem.leftBarButtonItem = barItem;
        
    }
//    56 255 248
    
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:56/255.0 green:1 blue:1 alpha:1.0]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
}
- (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
