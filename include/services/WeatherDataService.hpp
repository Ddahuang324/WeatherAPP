#ifndef WEATHERDATASERVICE_HPP
#define WEATHERDATASERVICE_HPP

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QTimer>
#include <QRandomGenerator>
#include <QJSValue>
#include <functional>

class WeatherAPIClient;

class WeatherDataService : public QObject
{
    Q_OBJECT

public:
    explicit WeatherDataService(QObject *parent = nullptr);
    ~WeatherDataService();
    

    // 获取指定城市的天气信息
    Q_INVOKABLE void getCityWeather(const QString& cityName, const QJSValue &callback = QJSValue());
    // 获取指定城市的周天气预报
    Q_INVOKABLE void getWeeklyForecast(const QString &cityName, const QJSValue &callback = QJSValue());
    // 获取指定城市的每日天气预报
    Q_INVOKABLE void getDailyForecast(const QString &cityName, const QJSValue &callback = QJSValue());
    // 获取指定城市的详细天气信息
    Q_INVOKABLE void getDetailedWeatherInfo(const QString &cityName, const QJSValue &callback = QJSValue());
    // 获取指定城市的日出信息
    Q_INVOKABLE void getSunriseInfo(const QString &cityName,  const QJSValue &callback = QJSValue());
    // 根据查询字符串搜索城市
    Q_INVOKABLE void searchCities(const QString &query, const QJSValue &callback = QJSValue());



    Q_INVOKABLE bool validateCityName(const QString &cityName);

signals:
    // 当天气数据加载完成时调用此方法，传入天气数据的 QVariantMap 对象
    void dataLoaded(const QVariantMap &weatherData);
    // 当天气数据加载出错时调用此方法，传入错误信息的 QString 对象
    void dataLoadError(const QString &error);
    // 当搜索结果准备好时发出此信号
    void searchResultsReady(const QVariantList &results);

private:
    // 延迟调用指定函数的方法，传入函数对象和延迟时间（默认为100毫秒）
    void callLater(std::function<void()> func , int delayMs = 100);
    
    // API客户端
    WeatherAPIClient *m_apiClient;
};


#endif // WEATHERDATASERVICE_HPP