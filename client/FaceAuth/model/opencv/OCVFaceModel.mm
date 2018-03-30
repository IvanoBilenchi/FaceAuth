//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#ifdef __cplusplus
#undef NO
#import <opencv2/opencv.hpp>
#import <opencv2/face.hpp>
#endif

#import "OCVFaceModel.h"
#import "OCVFaceObservation.h"
#import "OCVFaceObservation+OpenCV.h"
#import "UIImage+OCVUtils.h"

#pragma mark - Constants

static double const kRecognitionThreshold = 15.0;

#pragma mark - Extension

@interface OCVFaceModel ()
{
    cv::Ptr<cv::face::FaceRecognizer> _faceClassifier;
    std::vector<cv::Mat> _trainingImages;
    cv::Mat _lastPredictedImage;
}
@end

#pragma mark - Implementation

@implementation OCVFaceModel

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _faceClassifier = cv::face::LBPHFaceRecognizer::create();
    }
    return self;
}

#pragma mark - Manipulation

+ (UIImage *)processedImageFromObservation:(OCVFaceObservation *)observation {
    return [UIImage imageFromCVMat:[observation processedCVMat]];
}

#pragma mark - Training

- (NSUInteger)numberOfTrainingSamples { return _trainingImages.size(); }

- (UIImage *)lastTrainingImage {
    return _trainingImages.empty() ? nil : [UIImage imageFromCVMat:_trainingImages.back()];
}

- (void)addFaceObservation:(OCVFaceObservation *)observation {
    _trainingImages.push_back([observation processedCVMat]);
}

- (void)discardLastFaceObservation {
    if (_trainingImages.size()) _trainingImages.pop_back();
}

- (void)train {
    std::vector<int> labels;
    for (int i = 0; i < _trainingImages.size(); ++i) labels.push_back(0);
    _faceClassifier->train(_trainingImages, labels);
}

#pragma mark - Prediction

- (UIImage *)lastPredictedImage {
    return _lastPredictedImage.empty() ? nil : [UIImage imageFromCVMat:_lastPredictedImage];
}

- (double)confidenceOfPrediction:(OCVFaceObservation *)observation {
    int label; double confidence;
    _lastPredictedImage = [observation processedCVMat];
    _faceClassifier->predict(_lastPredictedImage, label, confidence);
    return label == 0 ? confidence : DBL_MAX;
}

- (BOOL)predict:(OCVFaceObservation *)observation {
    return [self confidenceOfPrediction:observation] < kRecognitionThreshold;
}

#pragma mark - Serialization

- (void)serializeModelToFileAtPath:(NSString *)path {
    _faceClassifier->write(path.UTF8String);
}

@end
