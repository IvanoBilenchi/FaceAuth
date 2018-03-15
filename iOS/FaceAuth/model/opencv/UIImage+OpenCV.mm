//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//  Adapted from: https://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html
//

#import "UIImage+OpenCV.h"

#ifdef __cplusplus
#undef NO
#import <opencv2/opencv.hpp>
#endif

@implementation UIImage (OpenCV)

+ (UIImage *)imageFromCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // BytesPerRow
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,    // Bitmap info
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault                       // Intent
                                        );
    
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (cv::Mat)cvMat {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)cvMatGray {
    cv::Mat cvMat = [self cvMat];
    cv::Mat grayMat;
    
    if (cvMat.channels() == 1) {
        grayMat = cvMat;
    } else {
        grayMat = cv::Mat(cvMat.rows, cvMat.cols, CV_8UC1);
        cv::cvtColor(cvMat, grayMat, cv::COLOR_BGR2GRAY);
    }
    
    return grayMat;
}

@end
