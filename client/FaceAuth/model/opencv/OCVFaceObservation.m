//
//  Created by Ivano Bilenchi on 15/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import "OCVFaceObservation.h"

#pragma mark - Globals

static CIContext *ciContext;

#pragma mark - Extension

@interface OCVFaceObservation ()
{
    CVPixelBufferRef _buffer;
    CGFloat _bufferWidth;
    CGFloat _bufferHeight;
}
@end

#pragma mark - Implementation

@implementation OCVFaceObservation

#pragma mark - Properties

// eyeDistance
@dynamic eyeDistance;

- (CGFloat)eyeDistance {
    CGFloat xDistance = _leftEye.x - _rightEye.x;
    CGFloat yDistance = _leftEye.y - _rightEye.y;
    return sqrt(xDistance*xDistance + yDistance*yDistance);
}

// angle
@dynamic angle;

- (CGFloat)angle {
    CGFloat angle = atan2(_leftEye.x - _rightEye.x, _rightEye.y - _leftEye.y);
    while (angle < -M_PI) angle += M_PI;
    while (angle > M_PI) angle -= M_PI;
    return angle;
}

// image
@synthesize image = _image;

- (UIImage *)image {
    if (!_image) {
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:_buffer];
        CGImageRef cgImage = [ciContext createCGImage:ciImage fromRect:ciImage.extent];
        _image = [[UIImage alloc] initWithCGImage:cgImage
                                            scale:1.0
                                      orientation:UIImageOrientationUp];
        CGImageRelease(cgImage);
    }
    return _image;
}

// Other
@synthesize boundingBox = _boundingBox;
@synthesize leftEye = _leftEye;
@synthesize rightEye = _rightEye;

#pragma mark - Lifecycle

+ (void)initialize {
    if (self == [OCVFaceObservation class]) {
        ciContext = [[CIContext alloc] init];
    }
}
         
- (instancetype)initWithBuffer:(CVPixelBufferRef)buffer boundingBox:(CGRect)boundingBox leftEye:(CGPoint)leftEye rightEye:(CGPoint)rightEye {
    if ((self = [super init])) {
        _buffer = CVPixelBufferRetain(buffer);
        _boundingBox = boundingBox;
        _leftEye = leftEye;
        _rightEye = rightEye;
        _bufferWidth = CVPixelBufferGetWidth(buffer);
        _bufferHeight = CVPixelBufferGetHeight(buffer);
    }
    return self;
}

- (void)dealloc {
    CVPixelBufferRelease(_buffer);
}

@end
