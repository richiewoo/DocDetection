//
//  MaaSImageProcessBase.cpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#include "MaaSImageProcessBase.hpp"
#include "cvneon.h"

const OptionsMap& MaaSImageProcessBase::MaaSImageProcessBase::getOptions() const
{
    return m_optionsWithSections;
}

void MaaSImageProcessBase::registerOption(std::string name, std::string section, bool  * value)
{
    MaaSParameterOption * opt = new BooleanOption(name, section, value);
    m_optionsWithSections[section].push_back(opt);
}

void MaaSImageProcessBase::registerOption(std::string name, std::string section, int   *  value, int min, int max)
{
    MaaSParameterOption * opt = new Int32Option(name, section, value, min, max);
    m_optionsWithSections[section].push_back(opt);
    
    *value = std::max(min, std::max(min, *value));
}

void MaaSImageProcessBase::registerOption(std::string name, std::string section, float *  value, float min, float max)
{
    MaaSParameterOption * opt = new FloatOption(name, section, value, min, max);
    m_optionsWithSections[section].push_back(opt);
    
    *value = std::max(min, std::max(min, *value));
}

void MaaSImageProcessBase::registerOption(std::string name, std::string section, double *  value, double min, double max)
{
    MaaSParameterOption * opt = new DoubleOption(name, section, value, min, max);
    m_optionsWithSections[section].push_back(opt);
    
    *value = std::max(min, std::max(min, *value));
}

void MaaSImageProcessBase::registerOption(std::string name, std::string section, std::string* value, std::vector<std::string> stringEnums, int defaultValue)
{
    MaaSParameterOption * opt = new StringEnumOption(name, section, value, stringEnums, defaultValue);
    m_optionsWithSections[section].push_back(opt);
    
    *value = stringEnums[defaultValue]; // Assign default value just in case
}

bool MaaSImageProcessBase::processFrame(const cv::Mat& inputFrame, cv::Mat& output)
{
    return false;
}
bool MaaSImageProcessBase::processFrame(const cv::Mat& inputFrame, std::vector< std::vector<cv::Point> >& output)
{
    return false;
}

bool MaaSImageProcessBase::processFrame(const cv::Mat& inputFrame, std::vector<cv::Vec2f>& output)
{
    return false;
}

void MaaSImageProcessBase::getGray(const cv::Mat& input, cv::Mat& gray)
{
    const int numChannes = input.channels();
    
    if (numChannes == 4)
    {
#if TARGET_IPHONE_SIMULATOR
        cv::cvtColor(input, gray, cv::COLOR_BGRA2GRAY);
#else
        cv::neon_cvtColorBGRA2GRAY(input, gray);
#endif
        
    }
    else if (numChannes == 3)
    {
        cv::cvtColor(input, gray, cv::COLOR_BGR2GRAY);
    }
    else if (numChannes == 1)
    {
        gray = input;
    }
}

//! Returns true if this sample requires setting a reference image for latter use
bool MaaSImageProcessBase::isReferenceFrameRequired() const
{
    return false;
}

//! Sets the reference frame for latter processing
void MaaSImageProcessBase::setReferenceFrame(const cv::Mat& reference)
{
    // Does nothing. Override this method if you need to
}

// Resets the reference frame
void MaaSImageProcessBase::resetReferenceFrame() const
{
    // Does nothing. Override this method if you need to
}
