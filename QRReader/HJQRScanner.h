//
//  ViewController.h
//  QRReader
//
//  Created by Administrator on 8/16/17.
//  Copyright © 2017 Hussein Jaber. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QRReaderDelegate <NSObject>
@required
- (void)didReadQRCodeSuccessfullyWithResult:(NSString *)result;

@end

@interface HJQRScanner : UIViewController

@property (nonatomic) BOOL autoUpdateInfoLabelOnSuccess;

/**
 Indicates if a label appears below the camera view.
 */
@property (nonatomic) BOOL infoLabelEnabled;

/**
 Indicates whether the camera should stop on successful captures.
 */
@property (nonatomic) BOOL shouldStopOnSuccess;

@property (weak, nonatomic) id<QRReaderDelegate> delegate;

@property (strong, nonatomic) NSString *infoText;
/**
 Starts reading if reader is off, stops if reading.
 */
- (void)startStopReading;

@end

