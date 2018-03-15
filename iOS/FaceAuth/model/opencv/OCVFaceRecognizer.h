//
//  Created by Ivano Bilenchi on 14/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OCVFaceRecognizer : NSObject

#pragma mark - Training

- (UIImage *)lastTrainingImage;
- (void)addImage:(UIImage *)image;
- (void)train;

#pragma mark - Prediction

- (UIImage *)lastPredictedImage;
- (BOOL)predict:(UIImage *)image;
- (double)confidenceOfPrediction:(UIImage *)image;

#pragma mark - Serialization

- (void)serializeModelToFileAtPath:(NSString *)path;

@end
