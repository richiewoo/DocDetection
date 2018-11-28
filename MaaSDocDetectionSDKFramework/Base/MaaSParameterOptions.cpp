//
//  MaaSParameterOptions_hpp.cpp
//  MaaSDocDetectionSDKFramework
//
//  Created by Xinbo Wu on 9/17/18.
//  Copyright © 2018 Xinbo Wu. All rights reserved.
//

#include "MaaSParameterOptions.hpp"

MaaSParameterOption::MaaSParameterOption(const std::string& name, const std::string& section)
: m_name(name)
, m_section(section)
{
    
}

/*
 * Boolean
 */
BooleanOption::BooleanOption(const std::string& name, const std::string& section, bool* value)
: MaaSParameterOption(name, section)
, m_value(value)
, m_default(*value)
{
    
}

OptionType BooleanOption::getType()
{
    return OptionTypeBoolean;
}


bool BooleanOption::getValue() const
{
    return *m_value;
}

bool BooleanOption::setValue(bool value)
{
    bool changed = *m_value != value;
    *m_value = value;
    
    return changed;
}

/*
 * Int32
 */
Int32Option::Int32Option(const std::string& name, const std::string& section, int* value, int min, int max)
: MaaSParameterOption(name, section)
, m_value(value)
, m_min(min)
, m_max(max)
, m_default(*value)
{
    
}

OptionType Int32Option::getType()
{
    return OptionTypeInt32;
}

int Int32Option::getValue() const
{
    return *m_value;
}

bool Int32Option::setValue(int v)
{
    v = std::max(m_min, std::min(v, m_max));
    bool changed = *m_value != v;
    *m_value = v;
    
    return changed;
}

int Int32Option::getMaxValue() const
{
    return m_max;
    
}

int Int32Option::getMinValue() const
{
    return m_min;
    
}

/*
 * Float
 */
FloatOption::FloatOption(const std::string& name, const std::string& section, float* value, float min, float max)
: MaaSParameterOption(name, section)
, m_value(value)
, m_min(min)
, m_max(max)
, m_default(*value)
{
    
}

OptionType FloatOption::getType()
{
    return OptionTypeFloat;
}

float FloatOption::getValue() const
{
    return *m_value;
}

bool FloatOption::setValue(float v)
{
    v = std::max(m_min, std::min(v, m_max));
    bool changed = *m_value != v;
    *m_value = v;
    return changed;
}

float FloatOption::getMaxValue() const
{
    return m_max;
    
}
float FloatOption::getMinValue() const
{
    return m_min;
    
}

/*
 * Double
 */
DoubleOption::DoubleOption(const std::string& name, const std::string& section, double* value, double min, double max)
: MaaSParameterOption(name, section)
, m_value(value)
, m_min(min)
, m_max(max)
, m_default(*value)
{
    
}

OptionType DoubleOption::getType()
{
    return OptionTypeDouble;
}

double DoubleOption::getValue() const
{
    return *m_value;
}

bool DoubleOption::setValue(double v)
{
    v = std::max(m_min, std::min(v, m_max));
    bool changed = *m_value != v;
    *m_value = v;
    return changed;
}

double DoubleOption::getMaxValue() const
{
    return m_max;
    
}
double DoubleOption::getMinValue() const
{
    return m_min;
    
}

/*
 * String
 */
StringEnumOption::StringEnumOption(const std::string& name, const std::string& section, std::string* value, std::vector<std::string> stringEnums, size_t defaultValue)
: MaaSParameterOption(name, section)
, m_value(value)
, m_stringEnums(stringEnums)
, m_defaultValue(defaultValue)
{
    auto i = std::find(stringEnums.begin(), stringEnums.end(), *value);
    if ( stringEnums.end() != i)
    {
        m_index = std::distance(stringEnums.begin(), i);
    }
    else
    {
        m_index = defaultValue;
    }
    
    *m_value = getValue();
}

OptionType StringEnumOption::getType()
{
    return OptionTypeString;
}

size_t StringEnumOption::getValueIndex() const
{
    return m_index;
}

std::string StringEnumOption::getValue() const
{
    return m_stringEnums[m_index];
}

bool StringEnumOption::setValue(size_t newIndex)
{
    bool changed = newIndex != m_index;
    
    m_index = newIndex;
    *m_value = getValue();
    
    return changed;
}
