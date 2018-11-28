//
//  MaaSHoughLinesDetection.hpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/18/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#ifndef MaaSHoughLinesDetection_hpp
#define MaaSHoughLinesDetection_hpp

#include "MaaSImageProcessBase.hpp"

class ClusterLineCriteria
{
public:
    /**
     Criteria type, can be one of: eClusterType_Rho or eClusterType_Theta
     */
    enum Type
    {
        eClusterType_Rho,
        eClusterType_Theta
    };
    
    //! default constructor
    ClusterLineCriteria();

    ClusterLineCriteria(int type, double epsilon);
    
    int type; //!< the type of termination criteria: eClusterType_Rho, or eClusterType_Theta
    double epsilon; //!< the desired accuracy
};

class MaaSHoughLinesDetection : public MaaSImageProcessBase
{
public:
    MaaSHoughLinesDetection();
    
    //! Gets a sample name
    std::string getName() const;
    
    //! Returns a detailed sample description
    std::string getDescription() const;
    
    //! Processes a frame and returns output
    bool processFrame(const cv::Mat& inputFrame, std::vector<cv::Vec2f>& output);
    
public:
    typedef enum _eClusterType
    {
        eClusterType_Rho,
        eClusterType_Theta
    }eClusterType;
    
    bool clusterLines(const std::vector<cv::Vec2f> &lines, std::vector< std::vector<cv::Vec2f> >&clusteredLines, ClusterLineCriteria criteria, int NumOfClusters = 4);
    bool diluteLines(const std::vector<cv::Vec2f> &lines, std::vector<cv::Vec2f> &diluteLines, int maxRho);
    bool perpendicularIntersectionsFromLines(std::vector< std::vector<cv::Vec2f> > &lines, std::vector< std::vector<cv::Point2f> >& intersections);
    bool dilutePoint(std::vector< std::vector<cv::Point2f> >& intersections, std::vector<cv::Point2f>& centroidPts);
    
    std::vector<cv::Vec2f> houghLines;
    
private:
    //for lines
    double m_theta;
    double m_rho;
    int m_threshold;
    int m_thetaEpsilon;
    int m_rhoEpsilon;
    
    //for intersection
    int m_AngleEpsilon;
    int m_DisEpsilon;
};

#endif /* MaaSHoughLinesDetection_hpp */
