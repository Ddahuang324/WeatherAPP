#include "../../include/viewmodels/WeatherViewModel.hpp"
#include "../../include/models/AppStateManager.hpp"
#include "../../include/services/WeatherDataService.hpp"
#include "../../include/commonDataType/WeatherDataModel.hpp"
#include <QDebug>
#include <QtCore/qcontainerfwd.h>
#include <QtCore/qobject.h>
#include <QtQml/qjsvalue.h>

WeatherViewModel::WeatherViewModel(QObject *parent) : QObject(parent)
    ,m_isLoading(false)
    ,m_appStateManager(nullptr)
    ,m_weatherDataService(std::make_unique<WeatherDataService>(this))
{
    connect(m_weatherDataService.get(), &WeatherDataService::dataLoaded, this, &WeatherViewModel::onDataLoaded);
    connect(m_weatherDataService.get(), &WeatherDataService::dataLoadError,this, &WeatherViewModel::onDataLoadError);//目前还没实现，等接入API后再实现
    connect(m_weatherDataService.get(), &WeatherDataService::searchResultsReady, this, &WeatherViewModel::onSearchResultsReady);
}

WeatherViewModel::~WeatherViewModel()
{
    cleanup();
}
// WeatherViewModel类的成员函数，用于初始化视图模型
void WeatherViewModel::initialize(QObject *stateManager)
{
    m_appStateManager = qobject_cast<AppStateManager*>(stateManager);

    if(m_appStateManager){
        // 连接城市改变信号到处理函数onCityChanged
        connect(m_appStateManager, &AppStateManager::citychanged , this, &WeatherViewModel::onCityChanged);
        // 连接视图模式改变信号到处理函数onViewModeChanged
        connect(m_appStateManager, &AppStateManager::viewmodechanged, this, &WeatherViewModel::onViewModeChanged);
    }
}

void WeatherViewModel::loadCityWeather(const QString &cityName){
    if(cityName.isEmpty()) return;
    setLoading(true);
    clearError();

    // 不使用回调，直接通过信号机制处理数据
    m_weatherDataService->getCityWeather(cityName, QJSValue());
}

void WeatherViewModel::loadWeatherData() {
    // 获取当前城市数据
    QVariantMap currentCity = getCurrentCityData();
    if (currentCity.isEmpty()) {
        qDebug() << "No current city data available";
        return;
    }
    
    QString cityName = currentCity.value("cityName", "").toString();
    if (cityName.isEmpty()) {
        qDebug() << "Current city name is empty";
        return;
    }
    
    qDebug() << "WeatherViewModel::loadWeatherData() - Loading weather data for city:" << cityName;
    setLoading(true);
    clearError();
    
    // 获取当前天气数据
    qDebug() << "WeatherViewModel::loadWeatherData() - Calling getCityWeather for:" << cityName;
    m_weatherDataService->getCityWeather(cityName, QJSValue());
    
    // 获取周预报数据
    qDebug() << "WeatherViewModel::loadWeatherData() - Calling getWeeklyForecast for:" << cityName;
    m_weatherDataService->getWeeklyForecast(cityName, QJSValue());
}

// WeatherViewModel 类的成员函数，用于根据查询条件搜索城市信息
void WeatherViewModel::searchCities(const QString &query , const QJSValue &callback){
    if (callback.isCallable()) {
        m_weatherDataService->searchCities(query, callback);
    } else {
        // 如果没有提供callback，直接调用搜索，结果将通过信号处理
        m_weatherDataService->searchCities(query, QJSValue());
    }
}

void WeatherViewModel::addCityToRecent(const QVariantMap &cityData){
    // 如果应用状态管理器存在且城市数据不为空，则将城市数据添加到最近城市列表
    if(m_appStateManager && !cityData.isEmpty()){
        m_appStateManager->addToRecentCities(cityData);
    }
}

void WeatherViewModel::switchViewMode(const QString &viewMode){
    // 如果应用状态管理器存在，则设置当前视图模式为viewMode
    if(m_appStateManager){
        m_appStateManager->setViewMode(viewMode);
    }
}

void WeatherViewModel::switchToNextCity()
{
    // 如果应用状态管理器存在，则切换到下一个城市
    if (m_appStateManager) {
        m_appStateManager->switchToNext();
    }
}

void WeatherViewModel::switchToPreviousCity()
{
    // 如果应用状态管理器存在，则切换到上一个城市
    if (m_appStateManager) {
        m_appStateManager->switchToPrevious();
    }
}

void WeatherViewModel::switchToCity(int index)
{
    // 如果应用状态管理器存在，则切换到指定索引的城市
    if (m_appStateManager) {
        m_appStateManager->switchToCity(index);
    }
}

QVariantMap WeatherViewModel::getCurrentCityData(){
    // 返回当前城市的数据，如果应用状态管理器不存在则返回空的QVariantMap
    return m_appStateManager ? m_appStateManager->getCurrentCityForView() : QVariantMap();//发送信号，让AppStateManager更新当前城市数据
}

QVariantList WeatherViewModel::getRecentCities(){
    // 返回最近访问过的城市列表，如果应用状态管理器不存在则返回空的QVariantList
    return m_appStateManager ? m_appStateManager->recentCities() : QVariantList();
}

int WeatherViewModel::getCurrentCityIndex(){
    // 返回当前城市在列表中的索引，如果应用状态管理器不存在则返回0
    return m_appStateManager ? m_appStateManager->currentCityIndex() : 0;
}

int WeatherViewModel::getMaxCities()
{
    // 返回最大城市数量，如果应用状态管理器不存在则返回3
    return m_appStateManager ? m_appStateManager->maxCities() : 3;
}

QString WeatherViewModel::formatTemperature(const QString &temp)
{
    if (temp.isEmpty()) return "--°C";
    return temp.contains("°C") ? temp : temp + "°C";
}

QString WeatherViewModel::formatWeatherDescription(const QString &desc)
{
    return desc.isEmpty() ? "未知" : desc;
}

bool WeatherViewModel::validateWeatherData(const QVariantMap &data)
{
    return !data.isEmpty() && 
           data.contains("cityName") && 
           data.contains("temperature") &&
           !data["cityName"].toString().isEmpty() &&
           data["temperature"].toString() != "--°C";
}

void WeatherViewModel::cleanup()
{
    if (m_appStateManager) {
        disconnect(m_appStateManager, nullptr, this, nullptr);
    }
    
    if (m_weatherDataService) {
        disconnect(m_weatherDataService.get(), nullptr, this, nullptr);
    }
}

void WeatherViewModel::setLoading(bool loading)
{
    if (m_isLoading != loading) {
        m_isLoading = loading;
        emit isLoadingChanged();
        emit loadingStateChanged(loading);
    }
}

void WeatherViewModel::setError(const QString &error)
{
    if (m_errorMessage != error) {
        m_errorMessage = error;
        emit errorMessageChanged();
        emit errorOccurred(error);
    }
}

void WeatherViewModel::clearError()
{
    if (!m_errorMessage.isEmpty()) {
        m_errorMessage.clear();
        emit errorMessageChanged();
    }
}

void WeatherViewModel::onCityChanged(const QVariantMap &cityData)
{
    m_currentWeatherData = cityData;
    emit currentWeatherDataChanged();
    emit weatherDataChanged(cityData);
}

void WeatherViewModel::onViewModeChanged(const QString &viewMode)
{
    // 视图模式变化时，重新获取当前城市数据
    QVariantMap cityData = getCurrentCityData();
    if (!cityData.isEmpty()) {
        m_currentWeatherData = cityData;
        emit currentWeatherDataChanged();
        emit weatherDataChanged(cityData);
    }
}


void WeatherViewModel::onDataLoaded(const QVariantMap &data)
{
    qDebug() << "WeatherViewModel::onDataLoaded called with data:" << data;
    qDebug() << "Current m_currentWeatherData before update:" << m_currentWeatherData;
    
    setLoading(false);
    clearError();
    
    // 创建WeatherDataModel并更新当前数据
    auto weatherModel = WeatherDataModel::fromRawData(data, this);
    if (weatherModel) {
        m_currentWeatherData = weatherModel->toObject();
        qDebug() << "New m_currentWeatherData after update:" << m_currentWeatherData;
        emit currentWeatherDataChanged();
        emit weatherDataChanged(m_currentWeatherData);
        qDebug() << "Weather data updated successfully, signals emitted";
    } else {
        qDebug() << "Failed to create weather model from data";
    }
}

void WeatherViewModel::onDataLoadError(const QString &error)
{
    setLoading(false);
    setError(error);
}

void WeatherViewModel::onSearchResultsReady(const QVariantList &results)
{
    qDebug() << "Search results received in ViewModel:" << results;
    // 发出专门的搜索结果信号
    emit searchResultsReady(results);
}
