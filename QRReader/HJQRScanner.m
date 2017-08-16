//
//  ViewController.m
//  QRReader
//
//  Created by Administrator on 8/16/17.
//  Copyright © 2017 Hussein Jaber. All rights reserved.
//

#import "HJQRScanner.h"
#import <AVFoundation/AVFoundation.h>

@interface HJQRScanner ()<AVCaptureMetadataOutputObjectsDelegate>

/**
 The view in which the camera appears.
 */
@property (strong, nonatomic) UIView *cameraView;
/**
 Label holding user friendly text.
 */
@property (strong, nonatomic) UILabel *infoLabel;
/**
 Indicates if QR reader is in reading mode.
 */
@property (nonatomic) BOOL isReading;



@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@end

@implementation HJQRScanner

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initializeReader {
    self.isReading = NO;
    self.captureSession = nil;
    [self addCameraView];
    if (self.infoLabelEnabled) {
        [self addInfoLabel];
    }
}

- (void)addCameraView {
    self.cameraView = [UIView new];
    CGFloat width = self.view.frame.size.width - 40;
    CGFloat height = width;
    CGFloat x = 20;
    CGFloat y = 30;
    if (self.navigationController && self.navigationController.navigationBar.translucent) {
        y = y + self.navigationController.navigationBar.frame.size.height;
    }
    CGRect frame = CGRectMake(x, y, width, height);
    self.cameraView.frame = frame;
    self.cameraView.layer.cornerRadius = 7;
    self.cameraView.layer.masksToBounds = YES;
    self.cameraView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    if (![self.cameraView isDescendantOfView:self.view]) {
        [self.view addSubview:self.cameraView];
    }
}

- (void)addInfoLabel {
    self.infoLabel = [UILabel new];
    CGFloat x = self.cameraView.frame.origin.x;
    CGFloat y = self.cameraView.frame.size.height + 25;
    if (self.navigationController && self.navigationController.navigationBar.translucent) {
        y = y + self.navigationController.navigationBar.frame.size.height;
    }
    CGFloat width = self.cameraView.frame.size.width;
    CGFloat height = 30;
    self.infoLabel.frame = CGRectMake(x, y, width, height);
    self.infoLabel.numberOfLines = 0;
    if (!self.infoText) {
        self.infoLabel.text = @"Info to be added here..";
    } else {
        self.infoLabel.text = self.infoText;
    }
    self.infoLabel.textAlignment = NSTextAlignmentLeft;
    if (![self.infoLabel isDescendantOfView:self.view]) {
        [self.view addSubview:self.infoLabel];
    }
}

- (void)startStopReading {
    if (self.captureSession == nil) {
        [self initializeReader];
    }
    if (!self.isReading) {
        [self startReading];
    } else {
        [self stopReading];
    }
    self.isReading = !self.isReading;
}

- (BOOL)startReading {
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
            __weak HJQRScanner *weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf processQRCode:metaObject];
            });
        }
    }
}

- (void)processQRCode:(AVMetadataMachineReadableCodeObject *)object {
    NSLog(@"done");
    if ([self.delegate respondsToSelector:@selector(didReadQRCodeSuccessfullyWithResult:)]) {
        [self.delegate didReadQRCodeSuccessfullyWithResult:object.stringValue];
    }
    if (self.autoUpdateInfoLabelOnSuccess) {
        [self setInfoText:object.stringValue];
    }
    if (self.shouldStopOnSuccess) {
        [self stopReading];
        self.isReading = NO;
    }
}


- (void)setInfoText:(NSString *)info {
    self.infoLabel.text = info;
}


@end
