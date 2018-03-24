//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#ifdef __cplusplus
#undef NO
#import <opencv2/opencv.hpp>
#import <opencv2/face.hpp>
#endif

#import "OCVFaceRecognizer.h"
#import "OCVFaceObservation.h"
#import "UIImage+OpenCV.h"

#pragma mark - Constants

static double const kRecognitionThreshold = 15.0;

#pragma mark - Extension

@interface OCVFaceRecognizer ()
{
    cv::Ptr<cv::face::FaceRecognizer> _faceClassifier;
    std::vector<cv::Mat> _trainingImages;
    cv::Mat _lastPredictedImage;
}
@end

#pragma mark - Implementation

@implementation OCVFaceRecognizer

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _faceClassifier = cv::face::LBPHFaceRecognizer::create();
    }
    return self;
}

#pragma mark - Manipulation

+ (cv::Mat)processedMatFromObservation:(OCVFaceObservation *)observation {
    return [observation.image faceRecCVMatWithBoundingBox:observation.boundingBox
                                                faceAngle:observation.angle
                                              eyeDistance:observation.eyeDistance];
}

+ (UIImage *)processedImageFromObservation:(OCVFaceObservation *)observation {
    return [UIImage imageFromCVMat:[self processedMatFromObservation:observation]];
}

#pragma mark - Training

- (NSUInteger)numberOfTrainingSamples { return _trainingImages.size(); }

- (UIImage *)lastTrainingImage {
    return _trainingImages.empty() ? nil : [UIImage imageFromCVMat:_trainingImages.back()];
}

- (void)addFaceObservation:(OCVFaceObservation *)observation {
    _trainingImages.push_back([[self class] processedMatFromObservation:observation]);
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
    _lastPredictedImage = [[self class] processedMatFromObservation:observation];
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
