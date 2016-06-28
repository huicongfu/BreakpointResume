//
//  ViewController.m
//  BreakpointResume
//
//  Created by fu on 16/6/28.
//  Copyright © 2016年 fhc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDownloadDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

/**
 *  下载的任务
 */
@property (nonatomic, strong) NSURLSessionDownloadTask * task;
/**
 *  记录上次暂停下载返回的记录
 */
@property (nonatomic, strong) NSData * resumeData;
/**
 *  创建下载任务的属性
 */
@property (nonatomic, strong) NSURLSession * session;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSURLSession *)session
{
    if (_session == nil) {
        
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}
- (IBAction)download:(UIButton *)sender {
    
    sender.selected = ! sender.isSelected;
    
    if (self.task == nil) {
        if (self.resumeData) {
            [self resume];
        }else
        {
            [self start];
        }
    }
}

- (void)start
{
    /**
     *  开始下载的两个步骤
     */
    //1.创建下载任务
    NSURL * url = [NSURL URLWithString:@"http://filelx.liqucn.com/upload/2011/gps/baidumap_AndroidPhone"];
    self.task = [self.session downloadTaskWithURL:url];
    
    //2.开始下载任务
    [self.task resume];
}

/**
 *  继续下载任务
 */
- (void)resume
{
    /**
     *  继续下载的三步骤
     */
    
    [[self session] downloadTaskWithResumeData:self.resumeData];
    [self.task resume];
    self.resumeData = nil;
}

/**
 *  暂停下载任务
 */
- (void)pause
{
    __weak typeof(self) weakSelf = self;
    
    [self.task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
       
        weakSelf.resumeData = resumeData;
        weakSelf.task = nil;
    }];
}

#pragma mark - delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"温馨提示：" message:@"文件下载好了哦！！！！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
    [alert show];
    
    //
    NSString * caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    //
    NSString * file = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    //移动下载好的文件到指定的文件夹
    [fileManager moveItemAtPath:location.path toPath:file error:nil];
    
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    self.progressView.progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
    NSString * text = [NSString stringWithFormat:@"当前下载进度：%f",self.progressView.progress];
    self.progressLabel.text = text;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        self.progressView.progress = 0.0f;
        self.progressLabel.text = @"当前没有下载任务";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
