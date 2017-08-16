//
//  ViewController.m
//  QRReader
//
//  Created by Administrator on 8/16/17.
//  Copyright © 2017 Hussein Jaber. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic) BOOL isReading;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (weak, nonatomic) IBOutlet UIButton *rescanButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isReading = NO;
    self.captureSession = nil;
    [self startStopReading];
    self.rescanButton.hidden = YES;
}

- (void)startStopReading {
    if (!self.isReading) {
        [self startReading];
    } else {
        [self stopReading];
    }
    self.isReading = !self.isReading;
}

- (BOOL)startReading {
    self.rescanButton.hidden = YES;
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input) {
        NSLog(@"%@", error.localizedDescription);
        return NO;
    }
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession addInput:input];
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];

    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];

    self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.videoPreviewLayer setFrame:self.cameraView.layer.bounds];
    [self.cameraView.layer addSublayer:self.videoPreviewLayer];
    [self.captureSession startRunning];

    return YES;
}

- (void)stopReading {
    [self.captureSession stopRunning];
    self.captureSession = nil;
    [self.videoPreviewLayer removeFromSuperlayer];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metaObject = [metadataObjects firstObject];
        if ([metaObject.type isEqualToString:AVMetadataObjectTypeQRCode]) {
            __weak ViewController *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf processQRCode:metaObject];
            });
        }
    }
}

- (void)processQRCode:(AVMetadataMachineReadableCodeObject *)object {
    self.infoLabel.text = object.stringValue;
    [self stopReading];
    self.isReading = NO;
    self.rescanButton.hidden = NO;
}

- (IBAction)rescanAction:(UIButton *)sender {
    if (!self.isReading) {
        [self startReading];
    }
}

@end
