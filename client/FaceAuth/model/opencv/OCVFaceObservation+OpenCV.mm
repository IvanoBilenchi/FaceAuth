//
//  Created by Ivano Bilenchi on 26/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import "OCVFaceObservation+OpenCV.h"
#import "UIImage+OCVUtils.h"

#ifdef __cplusplus
#undef NO
#import <opencv2/opencv.hpp>
#endif

#pragma mark - Constants

static int const kBlurKernelLength = 3;
static CGFloat const kImageMaxSize = 300.0;
static CGFloat const kEyeDistanceMultiplier = 1.8;
static CGFloat const kEyeRotationMultiplier = 1.6;

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
    cv::bilateralFilter(mat, result, kBlurKernelLength, 50, 50);
    return result;
}

static cv::Mat maskedToEllpise(cv::Mat mat, int hSize) {
    cv::Mat mask(mat.rows, mat.cols, CV_8UC1, cv::Scalar(0, 0, 0));
    cv::Point ellipseCenter = cv::Point(mat.cols / 2, mat.rows / 2);
    cv::Size ellipseSize = cv::Size(hSize / 2, mat.rows / 2);
    
    cv::ellipse(mask, ellipseCenter, ellipseSize, 0.0, 0.0, 360.0,
                cv::Scalar(255, 255, 255), -1, 8);
    
    cv::Mat result;
    cv::bitwise_and(mat, mask, result);
    
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

#pragma mark - Implementation

@implementation OCVFaceObservation (OpenCV)

- (cv::Mat)processedCVMat {
    UIImage *image = self.image;
    
    // Crop
    image = [image cropped:denormalizedRect(self.boundingBox, image.size)];
    
    // Align
    image = [image rotated:-(self.angle * kEyeRotationMultiplier)];
    
    // Resize
    cv::Mat mat = [image cvMatResized:CGSizeMake(kImageMaxSize, kImageMaxSize)];
    
    // To grayscale
    mat = toGray(mat);
    
    // Blur
    mat = blur(mat);
    
    // Normalize histogram
    mat = applyCLAHE(mat);
    
    // Remove background noise
    CGFloat boundingWidth = self.boundingBox.size.width;
    int hSize = (int)(kImageMaxSize * self.eyeDistance * kEyeDistanceMultiplier / boundingWidth);
    mat = maskedToEllpise(mat, hSize);
    
    return mat;
}

@end
