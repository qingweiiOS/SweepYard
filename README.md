# SweepYard
二维码 扫描  

![扫码界面](https://upload-images.jianshu.io/upload_images/2342189-0f5d8ba57bd959ad.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

以上图为参照 把界面进行划分

> 1、灰色区域(镂空)
   2、二维码识别区域
   3、摄像头捕捉的视频

###  一、镂空视图创建 
```
   UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
    // 创建矩形
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRect:CGRectMake(100, 100, 260,260)];
    [path appendPath:circlePath];
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.frame = self.view.bounds;
    shaperLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    // 设置填充规则
    shaperLayer.fillRule = kCAFillRuleEvenOdd;
    shaperLayer.path = path.CGPath;
    [self.view.layer addSublayer: shaperLayer];
```
![66EF22CB-05A8-4002-92E3-BBCB33E8F453.png](https://upload-images.jianshu.io/upload_images/2342189-40be6b3e07784cfb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

设置的楼空区域在    ` CGRectMake(100, 100, 260,260)` 所以没在正中
后面 把 `CGRectMake(100, 100, 260,260)` 换成 **二维码识别区域** 的frame



### 二、二维码识别区域

![4EF9DFA5-EFC4-4873-AFB6-76B62E9586F4.png](https://upload-images.jianshu.io/upload_images/2342189-7c9792332f4132cc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

创建一个类继承于 UIView  `DSScanView`

 **1、重写方法**

  ```
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.backgroundColor = [UIColor clearColor];
      //  [self loadScanLine];
        self.clipsToBounds = YES;
//
    }
    return self;

}
```
**2、绘制扫描区间**
```

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
```

```
- (DSScanView *)scanView{
    
    if(!_scanView){
        
        _scanView = [[DSScanView alloc] initWithFrame:CGRectMake(0, 0, 260, 260)];
        _scanView.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    }
    return _scanView;
    
}
```
然后添加到`[self.view addSubview:self.scanView];`
![结果](https://upload-images.jianshu.io/upload_images/2342189-29c089a44006bc7e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

**3、中间的网格实现**

![网格](https://upload-images.jianshu.io/upload_images/2342189-84f2723c43447455.gif?imageMogr2/auto-orient/strip)

实际上就是一个图片从上至下往复运动

用到了       `计时器` 和` 动画`
```
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
```

三、摄像头捕捉的视频并处理


1、导入
```
#import <AVFoundation/AVFoundation.h>
```

2、实现 `AVCaptureMetadataOutputObjectsDelegate` 协议

3、获取视频输入 
```
- (void)configureScan {
     self.scanView.timer.fireDate = [NSDate distantPast];
    // 获取手机硬件设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 初始化输入流
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        
        NSLog(@"%@",[error localizedDescription]);
    }
    // 创建会话
    _captureSession = [[AVCaptureSession alloc] init];
    // 添加输入流
    [_captureSession addInput:input];
    
    // 初始化输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 添加输出流
    [_captureSession addOutput:output];
    
    // 创建dispatch queue
    dispatch_queue_t queue = dispatch_queue_create("ScanQueue", DISPATCH_QUEUE_CONCURRENT);
    //扫描的结果苹果是通过代理的方式区回调，所以outPut需要添加代理，并且因为扫描是耗时的工作，所以把它放到子线程里面
    [output setMetadataObjectsDelegate:self queue:queue];
    // 设置扫描类型 AVMetadataObjectTypeQRCode 二维码
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    // 如果还需要支持条形码的话 用下面那个
//    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    
    
    // 创建输出对象  _previewLayer 展示摄像头捕捉的视频
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    _previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:_previewLayer atIndex:0];

 //输入设备已连接
    [[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
     
        /// 设置扫描区域
        output.rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect:self.scanView.frame];
    }];
    
}
```

关于`rectOfInterest` [点击这里](https://blog.csdn.net/lixianyue1991/article/details/70894982)


4、`#pragma mark - AVCaptureMetadataOutputObjectsDelegate` 获取到扫描结果的回调
```
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects != nil && metadataObjects.count > 0) {
            // 扫描到之后，停止扫描
         [self stopScan];
            // 获取结果并对其进行处理
        AVMetadataMachineReadableCodeObject *object = metadataObjects.firstObject;
        // 判断是否为二维码 AVMetadataObjectTypeQRCode
        if ([[object type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *result = object.stringValue;
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"扫描成功" message:result preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self startScan1];
            }];
            [alertView addAction:action1];
            [self presentViewController:alertView animated:YES completion:^{
                
            }];
           NSLog(@"扫描结果 : [ %@ ]",result);
        } else {
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"扫描失败" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                 [self startScan1];
            }];
            [alertView addAction:action1];
            [self presentViewController:alertView animated:YES completion:^{
                
            }]; 
        }
        //播放音效
        if (self.audioPlayer) {
            [self.audioPlayer play];
        }
    }
}
```
![完整](https://upload-images.jianshu.io/upload_images/2342189-c1a0211ffc84c188.gif?imageMogr2/auto-orient/strip)

[Dome 地址](https://github.com/qingweiiOS/SweepYard.git)





