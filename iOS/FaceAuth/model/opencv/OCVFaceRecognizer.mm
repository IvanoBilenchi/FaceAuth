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
#import "UIImage+OpenCV.h"

#pragma mark - Extension

@interface OCVFaceRecognizer ()
{
    cv::Ptr<cv::face::FaceRecognizer> _faceClassifier;
    NSMutableArray<UIImage *> *_images;
}
@end

#pragma mark - Implementation

@implementation OCVFaceRecognizer

#pragma mark - Properties

@synthesize images = _images;

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _faceClassifier = cv::face::LBPHFaceRecognizer::create();
        _images = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Public methods

- (void)addImage:(UIImage *)image {
    [_images addObject:image];
}

- (void)train {
    std::vector<int> labels;
    for (int i = 0; i < _images.count; ++i) labels.push_back(0);
    _faceClassifier->train([self imagesVector], labels);
}

- (BOOL)predict:(UIImage *)image {
    double confidence; int label;
    _faceClassifier->predict([image cvMatGray], label, confidence);
    return label == 0 && confidence < 10.0;
}

- (void)serializeModelToFileAtPath:(NSString *)path {
    _faceClassifier->write(path.UTF8String);
}

#pragma mark - Private methods

- (std::vector<cv::Mat>)imagesVector {
    std::vector<cv::Mat> images;
    
    for (UIImage *image in _images) {
        images.push_back([image cvMatGray]);
    }
    
    return images;
}

@end
