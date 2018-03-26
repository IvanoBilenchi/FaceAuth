//
//  Created by Ivano Bilenchi on 26/03/18.
//  Copyright © 2018 Ivano Bilenchi. All rights reserved.
//

#import "OCVFaceObservation.h"
namespace cv { class Mat; }

@interface OCVFaceObservation (OpenCV)

/// @return Preprocessed OpenCV matrix, suitable for face identification.
- (cv::Mat)processedCVMat;

@end
