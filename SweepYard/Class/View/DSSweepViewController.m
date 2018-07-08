////————————————————————————————————————————————————————————————
//                       .::::.             DSSweepViewController.m
//                     .::::::::.
//                    :::::::::::           DayShow
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

#import "DSSweepViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DSScanView.h"
@interface DSSweepViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIButton *openFlashBtn;
@property (nonatomic, strong) DSScanView *scanView;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation DSSweepViewController
- (DSScanView *)scanView{
    
    if(!_scanView){
        
        _scanView = [[DSScanView alloc] initWithFrame:CGRectMake(0, 0, 260, 260)];
        _scanView.center = CGPointMake(self.view.center.x, self.view.center.y - 50);
    }
    return _scanView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    [self initUI];
    
    [self loadSound];
    [self configureScan];
    [self startScan1];
}
- (void)loadSound
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *soundURL = [NSURL URLWithString:soundFilePath];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    if (error) {
        NSLog(@"文件格式不支持");
        NSLog(@"%@", [error localizedDescription]);
    }
    else {
        [self.audioPlayer prepareToPlay];
    }
}

- (void)initUI{
    
    [self.view addSubview:self.scanView];
    self.openFlashBtn = [[UIButton alloc] init];
    [self.view addSubview:self.openFlashBtn];
    
    [self.openFlashBtn setTitle:@"点击打开闪光灯" forState:UIControlStateNormal];
    [self.openFlashBtn setTitle:@"点击关闭闪光灯" forState:UIControlStateSelected];
    self.openFlashBtn.frame = CGRectMake(0, self.view.frame.size.height-160, self.view.frame.size.width, 40);
    [self.openFlashBtn addTarget:self action:@selector(openORCloseLamp:) forControlEvents:UIControlEventTouchUpInside];
    self.openFlashBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.openFlashBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self hollowoutView];
}
- (void)hollowoutView {
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.view.bounds];
    // 创建矩形
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRect:_scanView.frame];
    [path appendPath:circlePath];
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.frame = self.view.bounds;
    shaperLayer.fillColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    // 设置填充规则
    shaperLayer.fillRule = kCAFillRuleEvenOdd;
    shaperLayer.path = path.CGPath;
    [self.view.layer addSublayer: shaperLayer];
}
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
    // 设置支持 二维码
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    // 如果要支持条形码的话 用下面那个
    //    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]];
    
    
    // 创建输出对象
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
- (void)startScan1{
    self.scanView.timer.fireDate = [NSDate distantPast];
    [_captureSession startRunning];
}
// 结束扫描
- (void)stopScan {
    // 停止会话
    [_captureSession stopRunning];
    //    _captureSession = nil;
    self.scanView.timer.fireDate = [NSDate distantFuture];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
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
// 开启或关闭闪光灯
- (void)openORCloseLamp:(UIButton *)sender {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //判断手机是否有闪光灯
    if ([device hasTorch]) {
        
        NSError *error = nil;
        //获取硬件设备
        [device lockForConfiguration:&error];
        if (sender.selected == NO) {
            [device setTorchMode:AVCaptureTorchModeOn];
            
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            
        }
        //释放硬件
        [device unlockForConfiguration];
    }
    sender.selected = !sender.selected;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    self.scanView.timer.fireDate = [NSDate distantFuture];
    
    [self.captureSession stopRunning];
    self.captureSession = nil;
    //销毁计时器 销毁计时器 销毁计时器
    [self.scanView.timer invalidate];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
@end
