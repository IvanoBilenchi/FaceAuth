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

#pragma mark - Constants

static int const kBlurKernelLength = 7;
static CGFloat const kImageMaxSize = 150.0;
static CGFloat const kEyeDistanceMultiplier = 1.75;

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

static cv::Mat blur(cv::Mat mat) {
    cv::Mat result;
    
    for (int i = 1; i < kBlurKernelLength; i = i+2) {
        cv::bilateralFilter(mat, result, i, i*2, i/2);
    }
    
    return result;
}

static CGRect denormalizedRect(CGRect rect, CGSize size) {
    CGRect box = CGRectMake(rect.origin.x * size.width,
                            rect.origin.y * size.height,
                            rect.size.width * size.width,
                            rect.size.height * size.height);
    
    // Make the box square
    if (box.size.width > box.size.height) {
        box = CGRectInset(box, 0.0, (box.size.height - box.size.width) / 2.0);
    } else {
        box = CGRectInset(box, (box.size.width - box.size.height) / 2.0, 0.0);
    }
    
    return box;
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

- (cv::Mat)faceRecCVMatWithBoundingBox:(CGRect)boundingBox faceAngle:(CGFloat)faceAngle eyeDistance:(CGFloat)eyeDistance {
    UIImage *image = [[self cropped:denormalizedRect(boundingBox, self.size)] rotated:-faceAngle];
    return applyCLAHE(blur(toGray([image cvMatResized:CGSizeMake(kImageMaxSize, kImageMaxSize)
                                              clipped:CGSizeMake(kImageMaxSize * eyeDistance * kEyeDistanceMultiplier / boundingBox.size.width, kImageMaxSize)])));
}

#pragma mark - Private methods

- (cv::Mat)cvMatResized:(CGSize)size clipped:(CGSize)clippedSize {
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
    
    CGFloat centerX = (size.width - clippedSize.width) / 2.0;
    CGFloat centerY = (size.height - clippedSize.height) / 2.0;
    CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(centerX, centerY, clippedSize.width, clippedSize.height), NULL);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGPathRelease(path);
    
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
