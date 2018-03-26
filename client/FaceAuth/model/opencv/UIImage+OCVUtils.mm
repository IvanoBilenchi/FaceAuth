//
//  Created by Ivano Bilenchi on 26/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import "UIImage+OCVUtils.h"

#ifdef __cplusplus
#undef NO
#import <opencv2/opencv.hpp>
#endif

@implementation UIImage (OCVUtils)

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

- (cv::Mat)cvMatResized:(CGSize)size {
    cv::Mat cvMat(size.height, size.width, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    CGContextRef ctx = CGBitmapContextCreate(cvMat.data,                            // Pointer to  data
                                             size.width,                            // Width of bitmap
                                             size.height,                           // Height of bitmap
                                             8,                                     // Bits per component
                                             cvMat.step[0],                         // Bytes per row
                                             CGImageGetColorSpace(self.CGImage),    // Colorspace
                                             kCGImageAlphaNoneSkipLast |
                                             kCGBitmapByteOrderDefault);            // Bitmap info flags
    
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetAllowsAntialiasing(ctx, YES);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    
    CGRect drawRect = CGRectMake(0.0, 0.0, size.width, size.height);
    CGContextDrawImage(ctx, drawRect, self.CGImage);
    CGContextRelease(ctx);
    
    return cvMat;
}

- (UIImage *)cropped:(CGRect)rect {
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage* cropped = [UIImage imageWithCGImage:croppedImageRef];
    CGImageRelease(croppedImageRef);
    return cropped;
}

- (UIImage *)rotated:(CGFloat)angle {
    CGImageRef cgImage = self.CGImage;
    CGFloat largestSize = MAX(self.size.width, self.size.height);
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             (size_t)largestSize,
                                             (size_t)largestSize,
                                             CGImageGetBitsPerComponent(cgImage),
                                             0,
                                             CGImageGetColorSpace(cgImage),
                                             CGImageGetBitmapInfo(cgImage));
    
    CGRect drawRect = CGRectMake(largestSize - self.size.width,
                                 largestSize - self.size.height,
                                 self.size.width,
                                 self.size.height);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, largestSize / 2.0, largestSize / 2.0);
    transform = CGAffineTransformRotate(transform, angle);
    transform = CGAffineTransformTranslate(transform, largestSize / -2.0, largestSize / -2.0);
    
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, drawRect, cgImage);
    
    cgImage = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    
    drawRect = CGRectApplyAffineTransform(drawRect, transform);
    CGImageRef croppedImage = CGImageCreateWithImageInRect(cgImage, drawRect);
    CGImageRelease(cgImage);
    
    UIImage *image = [UIImage imageWithCGImage:croppedImage];
    CGImageRelease(croppedImage);
    
    return image;
}

@end
