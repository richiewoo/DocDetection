//
//  MaaSParameterOptions_hpp.hpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/17/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#ifndef MaaSParameterOptions_hpp
#define MaaSParameterOptions_hpp

#include <string>

typedef enum _OptionType{
    OptionTypeBoolean,
    OptionTypeInt32,
    OptionTypeFloat,
    OptionTypeDouble,
    OptionTypeString
} OptionType;

class MaaSParameterOption {
    
public:
    const std::string getName() const { return m_name; }
    
    virtual OptionType getType() = 0;
    
protected:
    MaaSParameterOption(const std::string& name, const std::string& section);
    
    std::string m_name;
    std::string m_section;
};

class BooleanOption: public MaaSParameterOption {
    
public:
    BooleanOption(const std::string& name, const std::string& section, bool* value);
    
    virtual OptionType getType() override;
    
    bool getValue() const;
    bool setValue(bool value);
    
private:
    bool * m_value;
    bool   m_default;
};

class Int32Option : public MaaSParameterOption
{
    
public:
    Int32Option(const std::string& name, const std::string& section, int* value, int min, int max);
    
    virtual OptionType getType() override;
    
    int getValue() const;
    bool setValue(int v);
    
    int getMaxValue() const;
    int getMinValue() const;
    
private:
    int * m_value;
    int   m_min;
    int   m_max;
    int   m_default;
};

class FloatOption : public MaaSParameterOption
{
public:
    FloatOption(const std::string& name, const std::string& section, float* value, float min, float max);
    
    virtual OptionType getType() override;
    
    float getValue() const;
    bool setValue(float v);
    
    float getMaxValue() const;
    float getMinValue() const;
    
private:
    float * m_value;
    float   m_min;
    float   m_max;
    float   m_default;
};

class DoubleOption : public MaaSParameterOption
{
public:
    DoubleOption(const std::string& name, const std::string& section, double* value, double min, double max);
    
    virtual OptionType getType() override;
    
    double getValue() const;
    bool setValue(double v);
    
    double getMaxValue() const;
    double getMinValue() const;
    
private:
    double * m_value;
    double   m_min;
    double   m_max;
    double   m_default;
};

class StringEnumOption : public MaaSParameterOption
{
public:
    StringEnumOption(const std::string& name,
                     const std::string& section,
                     std::string* value,
                     std::vector<std::string> stringEnums,
                     size_t defaultValue = 0);
    
    virtual OptionType getType() override;
    
    size_t getValueIndex() const;
    std::string getValue() const;
    bool setValue(size_t newIndex);
    
    const std::vector<std::string>& getEnums() const { return m_stringEnums; }
    
private:
    size_t m_index;
    
    std::string* m_value;
    std::vector<std::string> m_stringEnums;
    size_t m_defaultValue;
    
};

#endif /* ImageProcessOptions_hpp */
