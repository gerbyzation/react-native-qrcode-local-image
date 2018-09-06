//
//  RCTQRCodeLocalImage.m
//  RCTQRCodeLocalImage
//
//  Created by fangyunjiang on 15/11/4.
//  Copyright (c) 2015年 remobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import "RCTQRCodeLocalImage.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation RCTQRCodeLocalImage
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(decode:(NSString *)path callback:(RCTResponseSenderBlock)callback)
{
    __block UIImage *srcImage;
    ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
    [assetLibrary assetForURL:[NSURL URLWithString: path] resultBlock:^(ALAsset *asset) {
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        srcImage = [UIImage imageWithData: data];
        
        if (nil==srcImage){
            NSLog(@"PROBLEM! IMAGE NOT LOADED\n");
            callback(@[RCTMakeError(@"IMAGE NOT LOADED!", nil, nil)]);
            return;
        }
        NSLog(@"OK - IMAGE LOADED\n");
        NSDictionary *detectorOptions = @{@"CIDetectorAccuracy": @"CIDetectorAccuracyHigh"};
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:detectorOptions];
        CIImage *image = [CIImage imageWithCGImage:srcImage.CGImage];
        NSArray *features = [detector featuresInImage:image];
        if (0==features.count) {
            NSLog(@"PROBLEM! Feature size is zero!\n");
            callback(@[RCTMakeError(@"Feature size is zero!", nil, nil)]);
            return;
        }
        
        CIQRCodeFeature *feature = [features firstObject];
        
        NSString *result = feature.messageString;
        NSLog(@"result: %@", result);
        
        if (result) {
            callback(@[[NSNull null], result]);
        } else {
            callback(@[RCTMakeError(@"QR Parse failed!", nil, nil)]);
            return;
        }
    } failureBlock:^(NSError *error) {
        callback(@[RCTMakeError(@"QR Parse failed!", nil, nil)]);
        return;
    }] ;
}
@end
