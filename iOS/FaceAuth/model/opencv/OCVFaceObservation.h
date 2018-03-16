//
//  Created by Ivano Bilenchi on 15/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN;

@interface OCVFaceObservation : NSObject

#pragma mark - Properties

@property (nonatomic, readonly) CGRect boundingBox;
@property (nonatomic, readonly) CGPoint leftEye;
@property (nonatomic, readonly) CGPoint rightEye;
@property (nonatomic, readonly) CGFloat eyeDistance;
@property (nonatomic, readonly) CGFloat angle;
@property (nonatomic, strong, readonly) UIImage *image;

#pragma mark - Lifecycle

- (instancetype)initWithBuffer:(CVPixelBufferRef)buffer
                   boundingBox:(CGRect)boundingBox
                       leftEye:(CGPoint)leftEye
                      rightEye:(CGPoint)rightEye;

@end

NS_ASSUME_NONNULL_END;
