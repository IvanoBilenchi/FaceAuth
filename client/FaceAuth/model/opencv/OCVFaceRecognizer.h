//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCVFaceObservation;

NS_ASSUME_NONNULL_BEGIN;

@interface OCVFaceRecognizer : NSObject

#pragma mark - Manipulation

+ (UIImage *)processedImageFromObservation:(OCVFaceObservation *)observation;

#pragma mark - Training

@property (nonatomic, readonly) NSUInteger numberOfTrainingSamples;
@property (nonatomic, copy, readonly, nullable) UIImage *lastTrainingImage;

- (void)addFaceObservation:(OCVFaceObservation *)observation;
- (void)train;

#pragma mark - Prediction

@property (nonatomic, copy, readonly, nullable) UIImage *lastPredictedImage;

- (BOOL)predict:(OCVFaceObservation *)observation;
- (double)confidenceOfPrediction:(OCVFaceObservation *)observation;

#pragma mark - Serialization

- (void)serializeModelToFileAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END;
