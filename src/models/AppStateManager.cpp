#include "../../include/models/AppStateManager.hpp"
#include "../../include/services/WeatherDataService.hpp"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

AppStateManager::AppStateManager(QObject *parent) : QObject(parent)
    ,m_initialized(false)
    ,m_currentViewMode("today_weather")
    ,m_currentCityIndex(0)
    ,m_maxCities(3)
    ,m_weatherService(std::make_unique<WeatherDataService>(this))
{
    // 连接WeatherDataService的信号
    connect(m_weatherService.get(), &WeatherDataService::dataLoaded,
            this, &AppStateManager::onWeatherDataLoaded);
    connect(m_weatherService.get(), &WeatherDataService::dataLoadError,
            this, &AppStateManager::onWeatherDataError);
}

AppStateManager::~AppStateManager() = default;

void AppStateManager::setMaxCities(int maxCities){
    if(m_maxCities != maxCities && maxCities > 0){
        m_maxCities = maxCities;
        emit maxCitiesChanged();
    
        // 限制最大城市数量
        if(m_recentCities.size() > m_maxCities){
            m_recentCities = m_recentCities.mid(0, m_maxCities);
            emit recentCitiesChanged();
            //如果当前索引超出范围，重置
            if(m_currentCityIndex >= maxCities){
                setCurrentCityIndex(0);
                if(!m_recentCities.isEmpty()){
                    setCurrentCity(m_recentCities.first().toMap());
                }
            }
        }
    }
}

// 从示例数据中加载数据
void AppStateManager::initialize(){
    if(m_initialized) return ;

    loadSampleData();
    m_initialized = true;
    qDebug() << "AppStateManager initialized";
}

//设置当前城市
void AppStateManager::setCurrentCity(const QVariantMap &cityData){
    if(cityData.isEmpty()) return;

    // 更新当前城市信息
    setCurrentCityInternal(cityData);
    // 将城市添加到最近访问的城市列表
    addToRecentCities(cityData);
    // 通知当前城市已更改
    emit currentCityChanged();
}

//设置访问的模式
void AppStateManager::setViewMode(const QString &viewMode){
    if(m_currentViewMode != viewMode){
        m_currentViewMode = viewMode;
        emit currentViewModeChanged();
        emit viewmodechanged(viewMode);
        
        if(!m_weatherData.isEmpty()){
            emit citychanged(getCurrentCityForView());
        }
    }
}

void AppStateManager::addToRecentCities(const QVariantMap &cityData)
{
    // 如果城市数据为空 或者城市数据里不包含城市名字
    if (cityData.isEmpty() || !cityData.contains("cityName")) return;

    QString cityName = cityData["cityName"].toString();
    QVariantList newCities = m_recentCities;
    
    // 检查是否已存在
    int existingIndex = -1;
    for (int i = 0; i < newCities.size(); ++i) {
        QVariantMap city = newCities[i].toMap();
        if (city["cityName"].toString() == cityName) {
            existingIndex = i;
            break;
        }
    }
    
    // 移除已存在的
    if (existingIndex >= 0) {
        newCities.removeAt(existingIndex);
    }
    
    // 添加到最前面
    newCities.prepend(cityData);
    
    // 保持最多maxCities个
    if (newCities.size() > m_maxCities) {
        newCities = newCities.mid(0, m_maxCities);
    }
    
    m_recentCities = newCities;
    setCurrentCityIndex(0);
    emit recentCitiesChanged();//通知UI更新
    emit citiesListChanged();//通知其他业务逻辑
}

// AppStateManager 类的成员函数，用于切换到指定索引的城市
void AppStateManager::switchToCity(int index){
    // 检查索引是否在有效范围内且与当前城市索引不同
    if(index >= 0 && index < m_recentCities.size() && index != m_currentCityIndex){
        // 设置当前城市索引为传入的索引值
        setCurrentCityIndex(index);
        // 更新当前城市数据为指定索引对应的城市数据
        setCurrentCityInternal(m_recentCities[index].toMap());
        // 通知外部城市已更改，传递新的城市视图数据
        emit citychanged(getCurrentCityForView());
    }
}

//切换到下一个城市
void AppStateManager::switchToNext(){
    if (!m_recentCities.isEmpty()) {
        int newIndex = (m_currentCityIndex + 1) % m_recentCities.size();
        switchToCity(newIndex);
    }
}

//切换到上一个城市
void AppStateManager::switchToPrevious(){
    if (!m_recentCities.isEmpty()) {
        int newIndex = (m_currentCityIndex - 1 + m_recentCities.size()) % m_recentCities.size();
        switchToCity(newIndex);
    }
}

//传送数据。
QVariantMap AppStateManager::getCurrentCityForView(){
    if(m_currentCity.isEmpty()) return QVariantMap();

    QVariantMap baseData = m_currentCity;
    baseData["viewMode"] = m_currentViewMode;

    QString cityName = m_currentCity["cityName"].toString();
    if(cityName.isEmpty()) return baseData;

    if(m_currentViewMode == "temperature_trend"){
        qDebug() << "getCurrentCityForView: temperature_trend mode, calling getWeeklyForecast for:" << cityName;
        baseData["weeklyForecast"] = getWeeklyForecast(cityName);//来自Service
    }else if(m_currentViewMode == "detailed_info"){
        baseData["detailedInfo"] = getDetailedInfo(cityName);//来自Service
    }else if(m_currentViewMode == "sunrise_info"){
        baseData["sunriseInfo"] = getSunriseInfo(cityName);//来自Service
    }
    return baseData;
}

QVariantMap AppStateManager::getWeeklyForecast(const QString &cityName)
{
    // 调用WeatherDataService获取每日天气预报（更准确的温度数据）
    // 注意：这是一个同步调用的包装，实际的异步调用在WeatherDataService中处理
    qDebug() << "getWeeklyForecast called for city:" << cityName;
    
    QVariantMap result;
    result["cityName"] = cityName;
    result["requestType"] = "weeklyForecast";
    
    // 触发异步请求 - 使用getDailyForecast获取更准确的每日温度数据
    // WeatherDataService会通过dataLoaded信号返回数据，已在构造函数中连接到onWeatherDataLoaded槽
    qDebug() << "Calling getDailyForecast for:" << cityName;
    m_weatherService->getDailyForecast(cityName, QJSValue());
    
    return result;
}

QVariantMap AppStateManager::getDetailedInfo(const QString &cityName)
{
    // 调用WeatherDataService获取详细天气信息
    QVariantMap result;
    result["cityName"] = cityName;
    result["requestType"] = "detailedInfo";
    
    // 触发异步请求
    m_weatherService->getDetailedWeatherInfo(cityName, QJSValue());
    
    return result;
}

QVariantMap AppStateManager::getSunriseInfo(const QString &cityName)
{
    // 调用WeatherDataService获取日出日落信息
    QVariantMap result;
    result["cityName"] = cityName;
    result["requestType"] = "sunriseInfo";
    
    // 触发异步请求
    m_weatherService->getSunriseInfo(cityName, QJSValue());
    
    return result;
}

void AppStateManager::loadSampleData()
{
    // TODO: 删除示例数据，改为从真实API加载数据
    QVariantList emptyCities;
    m_recentCities = emptyCities;
    emit recentCitiesChanged();
    emit citiesListChanged();
}

void AppStateManager::onWeatherDataLoaded(const QVariantMap &data)
{
    // 处理从WeatherDataService接收到的天气数据
    QVariantMap processedData = data;
    
    // 如果数据包含forecast数组，转换为前端期望的weeklyForecast格式
    if (data.contains("forecast") && data["forecast"].canConvert<QVariantList>()) {
        QVariantList forecastList = data["forecast"].toList();
        
        QVariantMap weeklyForecast;
        QVariantList recentDaysName;
        QVariantList recentDaysMaxMinTempreture;
        QVariantList recentDaysWeatherDescriptionIcon;
        
        for (const QVariant &item : forecastList) {
            QVariantMap dayData = item.toMap();
            
            // 添加日期名称
            recentDaysName.append(dayData.value("date", "").toString());
            
            // 添加最高最低温度
            QString tempStr = QString("%1°/%2°")
                .arg(dayData.value("maxTemp", 0).toInt())
                .arg(dayData.value("minTemp", 0).toInt());
            recentDaysMaxMinTempreture.append(tempStr);
            
            // 添加天气图标和描述
            QString iconDesc = QString("%1 %2")
                .arg(dayData.value("icon", "").toString())
                .arg(dayData.value("description", "").toString());
            recentDaysWeatherDescriptionIcon.append(iconDesc);
        }
        
        weeklyForecast["recentDaysName"] = recentDaysName;
        weeklyForecast["recentDaysMaxMinTempreture"] = recentDaysMaxMinTempreture;
        weeklyForecast["recentDaysWeatherDescriptionIcon"] = recentDaysWeatherDescriptionIcon;
        
        processedData["weeklyForecast"] = weeklyForecast;
        
        qDebug() << "Processed forecast data with" << forecastList.size() << "days";
    }
    
    m_weatherData = processedData;
    emit weatherDataChanged();
    emit weatherDataUpdated(processedData);
}

void AppStateManager::onWeatherDataError(const QString &error)
{
    // 处理天气数据加载错误
    QVariantMap errorData;
    errorData["error"] = error;
    errorData["hasError"] = true;
    
    m_weatherData = errorData;
    emit weatherDataChanged();
}

void AppStateManager::setCurrentCityInternal(const QVariantMap &cityData)
{
    if (m_currentCity != cityData) {
        m_currentCity = cityData;
        emit currentCityChanged();
    }
}
void AppStateManager::setCurrentCityIndex(int index)
{
    if (m_currentCityIndex != index) {
        m_currentCityIndex = index;
        emit currentCityIndexChanged();
    }
}