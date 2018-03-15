//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//  Sources:
//  https://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html
//

#import "UIImage+OpenCV.h"

#ifdef __cplusplus
#undef NO
#import <opencv2/opencv.hpp>
#endif

#pragma mark - Filters

static cv::Mat toGray(cv::Mat mat) {
    cv::Mat grayMat;
    
    if (mat.channels() == 1) {
        grayMat = mat;
    } else {
        grayMat = cv::Mat(mat.rows, mat.cols, CV_8UC1);
        cv::cvtColor(mat, grayMat, cv::COLOR_BGR2GRAY);
    }
    
    return grayMat;
}

static cv::Mat applyCLAHE(cv::Mat mat) {
    cv::Mat result;
    cv::Ptr<cv::CLAHE> clahe = cv::createCLAHE();
    clahe->setClipLimit(4);
    clahe->apply(mat, result);
    return result;
}

#pragma mark - Category

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

- (cv::Mat)cvMatResizedToSize:(CGSize)size {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    cv::Mat cvMat(size.height, size.width, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    size.width,                 // Width of bitmap
                                                    size.height,                // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    if (!CGSizeEqualToSize(size, self.size)) {
        CGContextSetInterpolationQuality(contextRef, kCGInterpolationHigh);
    }
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, size.width, size.height), self.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)cvMat { return [self cvMatResizedToSize:self.size]; }

- (cv::Mat)cvMatPreprocessed {
    return applyCLAHE(toGray([self cvMatResizedToSize:CGSizeMake(400.0, 400.0)]));
}

@end
