//
//  MaaSCroppedImage.cpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 10/2/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#include "MaaSCroppedImage.hpp"


MaaSCroppedImage::MaaSCroppedImage()
{
   
}

//! Gets a sample name
std::string MaaSCroppedImage::getName() const
{
    return "Cropping image";
}

//! Returns a detailed description
std::string MaaSCroppedImage::getDescription() const
{
    return " ";
}

bool MaaSCroppedImage::processFrame(const cv::Mat& inputFrame, const std::vector<cv::Point>pts, cv::Mat& outputFrame)
{
    if (pts.size() != 4) {
        inputFrame.copyTo(outputFrame);
        return true;
    }
    
    cv::Point2f dst[4] = {
        cv::Point2f(0.0, 0.0),
        cv::Point2f(0.0, inputFrame.rows-1),
        cv::Point2f(inputFrame.cols-1, inputFrame.rows-1),
        cv::Point2f(inputFrame.cols-1, 0.0),
    };
    
    cv::Point2f src[4];
    for (int i = 0; i < 4; i ++) {
        cv::Point2f dstPt = dst[i];
        float minDis = sqrt(powf((pts[0].x - dstPt.x), 2) + powf((pts[0].y - dstPt.y), 2));
        cv::Point2f orderedPt = pts[0];
        for (int j = 1; j < 4; j++) {
            cv::Point2f srcPt = pts[j];
            float dis = sqrt(powf((srcPt.x - dstPt.x), 2) + powf((srcPt.y - dstPt.y), 2));
            if ((dis - minDis) < 0.0) {
                minDis = dis;
                orderedPt = srcPt;
            }
        }
        
        src[i] = orderedPt;
    }
    
    cv::Mat m = cv::getPerspectiveTransform(src, dst);
    cv::warpPerspective(inputFrame, outputFrame, m, cv::Size(inputFrame.cols, inputFrame.rows));
    
    return true;
}
