//
//  MaaSEdgeDetection.cpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#include "MaaSEdgeDetection.hpp"

MaaSEdgeDetection::MaaSEdgeDetection()
: m_algorithmName("Canny")
, m_cannyLoThreshold(5)
, m_cannyHiThreshold(500)
, m_cannyAperture(3)
, m_harrisBlockSize(2)
, m_harrisapertureSize(3)
, m_harrisK(0.04f)
, m_harrisThreshold(200)
{
    
    std::vector<std::string> algos;
    algos.push_back("Canny");
    algos.push_back("Sobel");
    algos.push_back("Schaar");
    
    registerOption("Algorithm",   "", &m_algorithmName, algos, 0);
    
    // Canny detector options
    registerOption("Threshold 1", "Canny", &m_cannyLoThreshold, 0, 256);
    registerOption("Threshold 2", "Canny", &m_cannyHiThreshold, 0, 256);
    registerOption("Aperture",    "Canny", &m_cannyAperture, 1, 3);
    
}

//! Gets a sample name
std::string MaaSEdgeDetection::getName() const
{
    return "Edge detection";
}

//! Returns a detailed description
std::string MaaSEdgeDetection::getDescription() const
{
    return "Edge detection is a fundamental tool in image processing, machine vision and computer vision, particularly in the areas of feature detection and feature extraction, which aim at identifying points in a digital image at which the image brightness changes sharply or, more formally, has discontinuities. ";
}

//! Processes a frame and returns output image
bool MaaSEdgeDetection::processFrame(const cv::Mat& inputFrame, cv::Mat& output)
{
    cv::Mat grayImage;
    
    getGray(inputFrame, grayImage);
    
    if (m_algorithmName == "Canny")
    {
        cv::Mat blurred;
        cv::Mat canny;
        // blur will enhance edge detection
        cv::medianBlur(grayImage, blurred, 7);
        
        cv::dilate(blurred, canny, cv::Mat(), cv::Point(-1,-1));
        
        cv::Canny(canny, edges, m_cannyLoThreshold, m_cannyHiThreshold, m_cannyAperture);
    }
    else if (m_algorithmName == "Sobel")
    {
        int scale = 1;
        int delta = 0;
        int ddepth = CV_16S;
        
        /// Gradient X
        cv::Sobel( grayImage, grad_x, ddepth, 1, 0, 3, scale, delta, cv::BORDER_DEFAULT );
        cv::convertScaleAbs( grad_x, abs_grad_x );
        
        /// Gradient Y
        cv::Sobel( grayImage, grad_y, ddepth, 0, 1, 3, scale, delta, cv::BORDER_DEFAULT );
        cv::convertScaleAbs( grad_y, abs_grad_y );
        
        /// Total Gradient (approximate)
        cv::addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, edges );
    }
    else if (m_algorithmName == "Schaar")
    {
        int scale = 1;
        int delta = 0;
        int ddepth = CV_16S;
        
        /// Gradient X
        cv::Scharr( grayImage, grad_x, ddepth, 1, 0, scale, delta, cv::BORDER_DEFAULT );
        cv::convertScaleAbs( grad_x, abs_grad_x );
        
        /// Gradient Y
        cv::Scharr( grayImage, grad_y, ddepth, 0, 1, scale, delta, cv::BORDER_DEFAULT );
        cv::convertScaleAbs( grad_y, abs_grad_y );
        
        /// Total Gradient (approximate)
        cv::addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, edges );
    }
    else if (m_algorithmName == "Harris")
    {
        /// Detecting corners
        cv::cornerHarris( grayImage, dst, m_harrisBlockSize, m_harrisapertureSize, m_harrisK, cv::BORDER_DEFAULT );
        
        /// Normalizing
        cv::normalize( dst, dst_norm, 0, 255, cv::NORM_MINMAX, CV_32FC1, cv::Mat() );
        cv::convertScaleAbs( dst_norm, dst_norm_scaled );
        
        //edges = dst_norm_scaled;
        /// Drawing a circle around corners
        cv::threshold(dst_norm_scaled, edges, m_harrisThreshold, 255, cv::THRESH_BINARY);
        /*
         for( int j = 0; j < dst_norm.rows ; j++ )
         {
         for( int i = 0; i < dst_norm.cols; i++ )
         {
         if( (int) dst_norm.at<float>(j,i) > m_harrisThreshold )
         {
         circle( dst_norm_scaled, cv::Point( i, j ), 5,  cv::Scalar(0), 2, 8, 0 );
         }
         }
         }*/
        
        //edges = dst_norm_scaled;
        //cv::cvtColor(dst_norm_scaled, outputFrame, cv::COLOR_GRAY2BGRA);
    }
    else
    {
        std::cerr << "Unsupported algorithm:" << m_algorithmName << std::endl;
        assert(false);
        }
    
    edges.copyTo(output);
    
    return true;
}
