//
//  TestViewController.m
//  QRReader
//
//  Created by Administrator on 8/16/17.
//  Copyright © 2017 Hussein Jaber. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()<QRReaderDelegate>

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.shouldStopOnSuccess = YES;
    self.infoLabelEnabled = YES;
    self.autoUpdateInfoLabelOnSuccess = YES;
    self.infoText = @"Please scan a QR Code";
    [self startStopReading];
}

- (void)didReadQRCodeSuccessfullyWithResult:(NSString *)result {
    
}


@end
