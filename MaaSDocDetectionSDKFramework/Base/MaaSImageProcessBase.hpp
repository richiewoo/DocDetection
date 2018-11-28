//
//  ImageProcessBase.hpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#ifndef MaaSImageProcessBase_hpp
#define MaaSImageProcessBase_hpp

#include <vector>
#include <map>
#include "MaaSParameterOptions.hpp"

typedef std::vector<MaaSParameterOption*> OptionsSection;
typedef std::map<std::string, OptionsSection> OptionsMap;

class MaaSImageProcessBase
{
public:
    //! Gets a sample name
    virtual std::string getName() const = 0;
    
    //! Returns a detailed sample description
    virtual std::string getDescription() const = 0;
    
    //! Returns true if this sample requires setting a reference image for latter use
    virtual bool isReferenceFrameRequired() const;
    
    //! Sets the reference frame for latter processing
    virtual void setReferenceFrame(const cv::Mat& reference);
    
    // Resets the reference frame
    virtual void resetReferenceFrame() const;
    
    //! Processes a frame and returns output image
    //! Edges
    virtual bool processFrame(const cv::Mat& inputFrame, cv::Mat& output);
    //! Contours
    virtual bool processFrame(const cv::Mat& inputFrame, std::vector< std::vector<cv::Point> >& output);
    //! Hough lines
    virtual bool processFrame(const cv::Mat& inputFrame, std::vector<cv::Vec2f>& output);

    //Option map to save the parameters
    const OptionsMap& getOptions() const;
    
protected:
    void registerOption(std::string name, std::string section, bool  * value);
    void registerOption(std::string name, std::string section, int   *  value, int min, int max);
    void registerOption(std::string name, std::string section, float *  value, float min, float max);
    void registerOption(std::string name, std::string section, double *  value, double min, double max);
    void registerOption(std::string name, std::string section, std::string* value, std::vector<std::string> stringEnums, int defaultValue = 0);
    
    static void getGray(const cv::Mat& input, cv::Mat& gray);
    
private:
    OptionsMap m_optionsWithSections;
};

#endif /* MaaSImageProcessBase_hpp */
