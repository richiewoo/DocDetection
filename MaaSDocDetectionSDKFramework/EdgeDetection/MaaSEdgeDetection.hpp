//
//  MaaSEdgeDetection.hpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#ifndef MaaSEdgeDetection_hpp
#define MaaSEdgeDetection_hpp

#include "MaaSImageProcessBase.hpp"

class MaaSEdgeDetection : public MaaSImageProcessBase
{
public:
    MaaSEdgeDetection();
    
    //! Gets a sample name
    std::string getName() const;
    
    //! Returns a detailed sample description
    std::string getDescription() const;
    
    //! Processes a frame and returns output image
    bool processFrame(const cv::Mat& inputFrame, cv::Mat& output);
    
    cv::Mat edges;
    
private:
    
    cv::Mat grad_x, grad_y;
    cv::Mat abs_grad_x, abs_grad_y;
    
    cv::Mat dst;
    cv::Mat dst_norm, dst_norm_scaled;
    
    
    std::string m_algorithmName;
    
    // Canny detector options:
    int m_cannyLoThreshold;
    int m_cannyHiThreshold;
    int m_cannyAperture;
    
    // Harris detector options:
    int m_harrisBlockSize;
    int m_harrisapertureSize;
    double m_harrisK;
    int m_harrisThreshold;
};

#endif /* MaaSEdgeDetection_hpp */
