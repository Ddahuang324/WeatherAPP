#ifndef WEATHERAPICLIENT_HPP
#define WEATHERAPICLIENT_HPP

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QVariantMap>
#include <QVariantList>
#include <QTimer>
#include <QMap>
#include <functional>

class WeatherAPIClient : public QObject
{
    Q_OBJECT

public:
    explicit WeatherAPIClient(QObject *parent = nullptr);
    ~WeatherAPIClient();

    // 获取城市当前天气
    void getCurrentWeather(const QString &cityName, std::function<void(const QVariantMap&)> callback);
    
    // 获取城市7天天气预报
    void getWeeklyForecast(const QString &cityName, std::function<void(const QVariantMap&)> callback);
    
    // 获取城市每日天气预报（使用Daily Forecast API）
    void getDailyForecast(const QString &cityName, std::function<void(const QVariantMap&)> callback);
    
    // 获取城市详细天气信息
    void getDetailedWeatherInfo(const QString &cityName, std::function<void(const QVariantMap&)> callback);
    
    // 获取日出日落信息
    void getSunriseInfo(const QString &cityName, std::function<void(const QVariantMap&)> callback);
    
    // 搜索城市
    void searchCities(const QString &query, std::function<void(const QVariantList&)> callback);
    
    // 设置API密钥
    void setApiKey(const QString &apiKey);
    
    // 设置API基础URL
    void setBaseUrl(const QString &baseUrl);

private slots:
    void onNetworkReplyFinished();

private:
    // 发送HTTP GET请求
    void sendRequest(const QString &url, std::function<void(const QVariantMap&)> callback);
    void sendRequestForList(const QString &url, std::function<void(const QVariantList&)> callback);
    
    // 解析天气数据
    QVariantMap parseCurrentWeatherData(const QJsonObject &json);
    QVariantMap parseWeeklyForecastData(const QJsonObject &json);
    QVariantMap parseDailyForecastData(const QJsonObject &json);
    QVariantMap parseDetailedWeatherData(const QJsonObject &json);
    QVariantMap parseSunriseData(const QJsonObject &json);
    QVariantList parseCitySearchData(const QJsonArray &json);
    
    // 构建API URL
    QString buildCurrentWeatherUrl(const QString &cityName);
    QString buildForecastUrl(const QString &cityName);
    QString buildDailyForecastUrl(const QString &cityName);
    QString buildGeocodingUrl(const QString &cityName);
    QString buildSearchUrl(const QString &query);
    
    // 错误处理
    QVariantMap createErrorResponse(const QString &error, const QString &cityName = "");
    QVariantList createErrorListResponse(const QString &error);
    
    // 城市名称翻译
    QString translateCityName(const QString &englishName);
    
    // 城市代码加载
    void loadCityCodes();
    
    // 网络管理
    QNetworkAccessManager *m_networkManager;
    
    // API配置
    QString m_apiKey;
    QString m_baseUrl;
    
    // 城市代码映射
    QMap<QString, QString> m_cityCodeMap;
    
    // 请求回调映射
    QHash<QNetworkReply*, std::function<void(const QVariantMap&)>> m_callbacks;
    QHash<QNetworkReply*, std::function<void(const QVariantList&)>> m_listCallbacks;
};

#endif // WEATHERAPICLIENT_HPP