#include "../../include/commonDataType/WeatherDataModel.hpp"
#include <QDebug>
#include <QtCore/qcontainerfwd.h>

WeatherDataModel::WeatherDataModel(QObject *parent) : QObject(parent)
    , m_cityName("")
    , m_temperature("--°C")
    , m_weatherIcon("🌤️")
    , m_weatherDescription("未知")
    , m_maxMinTemp("--°C / --°C")
    , m_ganmao("")
    , m_notice("")
{
    // 初始化数据
}

WeatherDataModel::~WeatherDataModel() = default;

void WeatherDataModel::setCityName(const QString &cityName){
    if(m_cityName != cityName){
        m_cityName = cityName;
        emit cityNameChanged();
    }
}

void WeatherDataModel::setTemperature(const QString &temperature){
    if(m_temperature != temperature){
        m_temperature = temperature;
        emit temperatureChanged();
    }
}

void WeatherDataModel::setWeatherIcon(const QString &weatherIcon)
{
    if (m_weatherIcon != weatherIcon) {
        m_weatherIcon = weatherIcon;
        emit weatherIconChanged();
    }
}

void WeatherDataModel::setWeatherDescription(const QString &weatherDescription)
{
    if (m_weatherDescription != weatherDescription) {
        m_weatherDescription = weatherDescription;
        emit weatherDescriptionChanged();
    }
}

void WeatherDataModel::setMaxMinTemp(const QString &maxMinTemp)
{
    if (m_maxMinTemp != maxMinTemp) {
        m_maxMinTemp = maxMinTemp;
        emit maxMinTempChanged();
    }
}

void WeatherDataModel::setWeeklyForecast(const QVariantMap &weeklyForecast)
{
    if (m_weeklyForecast != weeklyForecast) {
        m_weeklyForecast = weeklyForecast;
        emit weeklyForecastChanged();
    }
}

void WeatherDataModel::setDetailedInfo(const QVariantMap &detailedInfo)
{
    if (m_detailedInfo != detailedInfo) {
        m_detailedInfo = detailedInfo;
        emit detailedInfoChanged();
    }
}

void WeatherDataModel::setSunriseInfo(const QVariantMap &sunriseInfo)
{
    if (m_sunriseInfo != sunriseInfo) {
        m_sunriseInfo = sunriseInfo;
        emit sunriseInfoChanged();
    }
}

void WeatherDataModel::setGanmao(const QString &ganmao)
{
    if (m_ganmao != ganmao) {
        m_ganmao = ganmao;
        emit ganmaoChanged();
    }
}

void WeatherDataModel::setNotice(const QString &notice)
{
    if (m_notice != notice) {
        m_notice = notice;
        emit noticeChanged();
    }
}

WeatherDataModel* WeatherDataModel::fromRawData(const QVariantMap& rawData, QObject *parent){
    if(rawData.isEmpty()){
        return createEmpty(parent);
    }
    
    auto model = new WeatherDataModel(parent);
    //填入数据
    // 设置城市名称
    model->setCityName(rawData.value("cityName" , "").toString());
    // 设置当前温度
    model->setTemperature(rawData.value("temperature", "--°C").toString());
    // 设置天气图标
    model->setWeatherIcon(rawData.value("weatherIcon", "🌤️").toString());
    // 设置天气描述
    model->setWeatherDescription(rawData.value("weatherDescription", "未知").toString());
    // 设置最高和最低温度
    model->setMaxMinTemp(rawData.value("maxMinTemp", "--°C / --°C").toString());
    // 设置每周天气预报
    QVariantMap weeklyForecastMap;
    QVariantList weeklyForecastList = rawData.value("weeklyForecast").toList();
    
    // 提取数据到对应的数组
    QVariantList recentDaysName;
    QVariantList recentDaysMaxMinTempreture;
    QVariantList recentDaysWeatherDescriptionIcon;
    
    for (int i = 0; i < weeklyForecastList.size(); ++i) {
        QVariantMap dayData = weeklyForecastList[i].toMap();
        recentDaysName.append(dayData.value("week", "").toString());
        QString maxMinTemp = dayData.value("high", "").toString() + " / " + dayData.value("low", "").toString();
        recentDaysMaxMinTempreture.append(maxMinTemp);
        recentDaysWeatherDescriptionIcon.append(dayData.value("type", "").toString());
        weeklyForecastMap[QString::number(i)] = dayData;
    }
    
    // 添加处理后的数组到weeklyForecastMap
    weeklyForecastMap["recentDaysName"] = recentDaysName;
    weeklyForecastMap["recentDaysMaxMinTempreture"] = recentDaysMaxMinTempreture;
    weeklyForecastMap["recentDaysWeatherDescriptionIcon"] = recentDaysWeatherDescriptionIcon;
    
    model->setWeeklyForecast(weeklyForecastMap);
    // 设置详细天气信息
    model->setDetailedInfo(rawData.value("detailedInfo").toMap());
    // 设置日出信息
    model->setSunriseInfo(rawData.value("sunriseInfo").toMap());
    // 设置感冒指数
    model->setGanmao(rawData.value("ganmao", "").toString());
    // 设置注意事项
    model->setNotice(rawData.value("notice", "").toString());

    return model;  
}

WeatherDataModel* WeatherDataModel::createEmpty(QObject *parent){
   auto model = new WeatherDataModel(parent);
   
    model->setCityName("暂无城市");
    model->setTemperature("--°C");
    model->setWeatherIcon("🌤️");
    model->setWeatherDescription("未知");
    model->setMaxMinTemp("--°C / --°C");
    
    return model;
}

bool WeatherDataModel::isValid() const{
    return !m_cityName.isEmpty() && m_temperature != "--°C" && m_weatherIcon != "🌤️" && m_weatherDescription != "未知" && m_maxMinTemp != "--°C / --°C";
}

QVariantMap WeatherDataModel::toObject() const{
    QVariantMap obj;
    // 将天气数据填充到 JSON 对象中
        obj["cityName"] = m_cityName;
        obj["temperature"] = m_temperature;
        obj["weatherIcon"] = m_weatherIcon;
        obj["weatherDescription"] = m_weatherDescription;
        obj["maxMinTemp"] = m_maxMinTemp;
        obj["weeklyForecast"] = m_weeklyForecast;
        obj["detailedInfo"] = m_detailedInfo;
        obj["sunriseInfo"] = m_sunriseInfo;
        obj["ganmao"] = m_ganmao;
        obj["notice"] = m_notice;
        
        // 返回填充好的 JSON 对象
        return obj;
}

WeatherDataModel* WeatherDataModel::clone(QObject * parent) const{
    return fromRawData(toObject(), parent);
}

void WeatherDataModel::updateData(const QVariantMap &newData){
     if (newData.isEmpty()) return;
    
    if (newData.contains("cityName")) {
        setCityName(newData["cityName"].toString());
    }
    if (newData.contains("temperature")) {
        setTemperature(newData["temperature"].toString());
    }
    if (newData.contains("weatherIcon")) {
        setWeatherIcon(newData["weatherIcon"].toString());
    }
    if (newData.contains("weatherDescription")) {
        setWeatherDescription(newData["weatherDescription"].toString());
    }
    if (newData.contains("maxMinTemp")) {
        setMaxMinTemp(newData["maxMinTemp"].toString());
    }
    if (newData.contains("weeklyForecast")) {
        setWeeklyForecast(newData["weeklyForecast"].toMap());
    }
    if (newData.contains("detailedInfo")) {
        setDetailedInfo(newData["detailedInfo"].toMap());
    }
    if (newData.contains("sunriseInfo")) {
        setSunriseInfo(newData["sunriseInfo"].toMap());
    }
    if (newData.contains("ganmao")) {
        setGanmao(newData["ganmao"].toString());
    }
    if (newData.contains("notice")) {
        setNotice(newData["notice"].toString());
    }
}

