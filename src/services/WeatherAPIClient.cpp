#include "../../include/services/WeatherAPIClient.hpp"
#include <QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>
#include <QJsonParseError>
#include <QDateTime>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QHash>
#include <QRegularExpression>
#include <QFile>
#include <QMap>
#include <QIODevice>
#include <algorithm>
#include <functional>

WeatherAPIClient::WeatherAPIClient(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_apiKey("") // 新的API不需要apiKey，所以这里留空
    , m_baseUrl("http://t.weather.itboy.net/api/weather/city/") // 修改为新的API地址
{
    // 连接网络请求完成信号
    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, &WeatherAPIClient::onNetworkReplyFinished);
    
    // 在构造函数中加载城市代码
    loadCityCodes();
}

WeatherAPIClient::~WeatherAPIClient()
{
    // 清理未完成的请求
    for (auto it = m_callbacks.begin(); it != m_callbacks.end(); ++it) {
        it.key()->deleteLater();
    }
    for (auto it = m_listCallbacks.begin(); it != m_listCallbacks.end(); ++it) {
        it.key()->deleteLater();
    }
}

void WeatherAPIClient::setApiKey(const QString &apiKey)
{
    m_apiKey = apiKey;
}

void WeatherAPIClient::setBaseUrl(const QString &baseUrl)
{
    m_baseUrl = baseUrl;
}

void WeatherAPIClient::getCurrentWeather(const QString &cityName, std::function<void(const QVariantMap&)> callback)
{
    if (!m_cityCodeMap.contains(cityName)) {
        callback(createErrorResponse("City not found", cityName));
        return;
    }
    QString cityCode = m_cityCodeMap.value(cityName);
    QString url = buildCurrentWeatherUrl(cityCode);
    sendRequest(url, callback);
}

void WeatherAPIClient::getWeeklyForecast(const QString &cityName, std::function<void(const QVariantMap&)> callback)
{
    if (!m_cityCodeMap.contains(cityName)) {
        callback(createErrorResponse("City not found", cityName));
        return;
    }
    QString cityCode = m_cityCodeMap.value(cityName);
    QString url = buildCurrentWeatherUrl(cityCode);
    
    qDebug() << "Getting weekly forecast for city:" << cityName << "with code:" << cityCode;
    qDebug() << "Weekly forecast URL:" << url;
    
    // 创建专门的回调函数来解析周预报数据
    auto weeklyCallback = [this, callback, cityName](const QVariantMap& rawData) {
        qDebug() << "Weekly forecast raw data received for" << cityName << ":" << rawData;
        
        if (rawData.contains("error")) {
            qDebug() << "Error in weekly forecast data:" << rawData["error"];
            callback(rawData);
            return;
        }
        
        // 从原始数据中提取JSON并使用parseWeeklyForecastData解析
        QJsonObject json = QJsonObject::fromVariantMap(rawData);
        QVariantMap result = parseWeeklyForecastData(json);
        qDebug() << "Parsed weekly forecast result:" << result;
        callback(result);
    };
    
    sendRequest(url, weeklyCallback);
}

void WeatherAPIClient::getDailyForecast(const QString &cityName, std::function<void(const QVariantMap&)> callback)
{
    if (!m_cityCodeMap.contains(cityName)) {
        callback(createErrorResponse("City not found", cityName));
        return;
    }
    QString cityCode = m_cityCodeMap.value(cityName);
    QString url = buildCurrentWeatherUrl(cityCode);
    
    // 创建专门的回调函数来解析日预报数据
    auto dailyCallback = [this, callback](const QVariantMap& rawData) {
        if (rawData.contains("error")) {
            callback(rawData);
            return;
        }
        
        // 从原始数据中提取JSON并使用parseDailyForecastData解析
        QJsonObject json = QJsonObject::fromVariantMap(rawData);
        QVariantMap result = parseDailyForecastData(json);
        callback(result);
    };
    
    sendRequest(url, dailyCallback);
}

void WeatherAPIClient::getDetailedWeatherInfo(const QString &cityName, std::function<void(const QVariantMap&)> callback)
{
    // 详细天气信息使用当前天气API，但包含更多字段
    getCurrentWeather(cityName, [this, callback](const QVariantMap &data) {
        if (data.contains("error")) {
            callback(data);
            return;
        }
        
        // 可以在这里添加更多详细信息的处理
        QVariantMap detailedData = data;
        detailedData["isDetailed"] = true;
        callback(detailedData);
    });
}

void WeatherAPIClient::getSunriseInfo(const QString &cityName, std::function<void(const QVariantMap&)> callback)
{
    // 日出日落信息包含在当前天气API中
    getCurrentWeather(cityName, [this, callback](const QVariantMap &data) {
        if (data.contains("error")) {
            callback(data);
            return;
        }
        
        QVariantMap sunriseData;
        sunriseData["cityName"] = data["cityName"];
        sunriseData["sunrise"] = data.value("sunrise", "");
        sunriseData["sunset"] = data.value("sunset", "");
        sunriseData["timezone"] = data.value("timezone", 0);
        callback(sunriseData);
    });
}

void WeatherAPIClient::searchCities(const QString &query, std::function<void(const QVariantList&)> callback)
{
    // 使用本地城市代码映射进行搜索
    QVariantList results;
    
    for (auto it = m_cityCodeMap.begin(); it != m_cityCodeMap.end(); ++it) {
        const QString &cityName = it.key();
        if (cityName.contains(query, Qt::CaseInsensitive)) {
            QVariantMap cityInfo;
            cityInfo["name"] = cityName;
            cityInfo["code"] = it.value();
            results.append(cityInfo);
        }
    }
    
    callback(results);
}

void WeatherAPIClient::sendRequest(const QString &url, std::function<void(const QVariantMap&)> callback)
{
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::UserAgentHeader, "WeatherApp/1.0");
    
    QNetworkReply *reply = m_networkManager->get(request);
    m_callbacks[reply] = callback;
    
    // 连接finished信号到槽函数
    connect(reply, &QNetworkReply::finished, this, &WeatherAPIClient::onNetworkReplyFinished);
    
    qDebug() << "Sending request to:" << url;
}

void WeatherAPIClient::sendRequestForList(const QString &url, std::function<void(const QVariantList&)> callback)
{
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setHeader(QNetworkRequest::UserAgentHeader, "WeatherApp/1.0");
    
    QNetworkReply *reply = m_networkManager->get(request);
    m_listCallbacks[reply] = callback;
    
    connect(reply, &QNetworkReply::finished, this, &WeatherAPIClient::onNetworkReplyFinished);
    
    qDebug() << "Sending list request to:" << url;
}

void WeatherAPIClient::onNetworkReplyFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (!reply) {
        qDebug() << "No reply object found";
        return;
    }
    
    qDebug() << "Network reply finished for URL:" << reply->url().toString();
    qDebug() << "Reply error:" << reply->error() << reply->errorString();
    
    // 处理普通回调
    if (m_callbacks.contains(reply)) {
        auto callback = m_callbacks.take(reply);
        
        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "Network error:" << reply->errorString();
            callback(createErrorResponse(reply->errorString()));
        } else {
            QByteArray data = reply->readAll();
            QJsonParseError parseError;
            QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
            
            if (parseError.error != QJsonParseError::NoError) {
                qDebug() << "JSON parse error:" << parseError.errorString();
                callback(createErrorResponse("Invalid JSON response"));
            } else {
                QJsonObject json = doc.object();
                
                // 检查API错误
                if (json.contains("cod") && json["cod"].toInt() != 200) {
                    QString errorMsg = json.value("message").toString();
                    callback(createErrorResponse(errorMsg));
                } else {
                    // 根据URL判断数据类型并解析
                    QString url = reply->url().toString();
                    QVariantMap result;
                    
                    if (url.contains("/weather")) {
                        result = parseCurrentWeatherData(json);
                    } else if (url.contains("/forecast/daily")) {
                        result = parseDailyForecastData(json);
                    } else if (url.contains("/forecast")) {
                        result = parseWeeklyForecastData(json);
                    } else {
                        result = parseCurrentWeatherData(json); // 默认解析
                    }
                    
                    callback(result);
                }
            }
        }
        reply->deleteLater();
        return;
    }
    
    // 处理列表回调
    if (m_listCallbacks.contains(reply)) {
        auto callback = m_listCallbacks.take(reply);
        
        if (reply->error() != QNetworkReply::NoError) {
            qDebug() << "Network error:" << reply->errorString();
            callback(createErrorListResponse(reply->errorString()));
        } else {
            QByteArray data = reply->readAll();
            qDebug() << "Received search response:" << data;
            
            QJsonParseError parseError;
            QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
            
            if (parseError.error != QJsonParseError::NoError) {
                qDebug() << "JSON parse error:" << parseError.errorString();
                callback(createErrorListResponse("Invalid JSON response"));
            } else {
                // OpenWeather地理编码API直接返回数组
                QJsonArray geocodesArray = doc.array();
                qDebug() << "Geocodes array:" << geocodesArray;
                
                if (geocodesArray.isEmpty()) {
                    qDebug() << "No cities found";
                    callback(createErrorListResponse("No cities found"));
                } else {
                    QVariantList result = parseCitySearchData(geocodesArray);
                    qDebug() << "Parsed search results:" << result;
                    callback(result);
                }
            }
        }
        reply->deleteLater();
        return;
    }
    
    // 如果reply不在任何回调映射中，仍然需要删除它
    reply->deleteLater();
}



QVariantMap WeatherAPIClient::parseCurrentWeatherData(const QJsonObject &json)
{
    QVariantMap result;
    QJsonObject data = json.value("data").toObject();
    QJsonObject cityInfo = json.value("cityInfo").toObject();
    QJsonArray forecast = data.value("forecast").toArray();
    QJsonObject todayForecast = forecast.at(0).toObject();
    
    result["cityName"] = cityInfo.value("city").toString();
    result["wendu"] = data.value("wendu").toString() + "°C";
    result["shidu"] = data.value("shidu").toString();
    result["pm25"] = QString::number(data.value("pm25").toDouble());
    result["quality"] = data.value("quality").toString();
    result["ganmao"] = data.value("ganmao").toString();
    result["fx"] = todayForecast.value("fx").toString();
    result["fl"] = todayForecast.value("fl").toString();
    result["type"] = todayForecast.value("type").toString();
    result["sunrise"] = todayForecast.value("sunrise").toString();
    result["sunset"] = todayForecast.value("sunset").toString();
    result["notice"] = todayForecast.value("notice").toString();

    // 为了与你现有的数据模型兼容，我们还需要填充一些字段
    result["temperature"] = result["wendu"];
    result["weatherDescription"] = result["type"];
    result["maxMinTemp"] = todayForecast.value("high").toString() + " / " + todayForecast.value("low").toString();

    // 构建detailedInfo数据结构
    QVariantMap detailedInfo;
    detailedInfo["humidity"] = result["shidu"].toString();
    detailedInfo["windSpeed"] = result["fx"].toString() + " " + result["fl"].toString(); // 风向+风力
    detailedInfo["rainfall"] = "0mm"; // API不提供当前降雨量
    detailedInfo["airQuality"] = result["quality"].toString();
    detailedInfo["airPressure"] = result["pm25"].toString() + " μg/m³"; // 使用PM2.5数据代替气压
    detailedInfo["uvIndex"] = "中等"; // 设置默认UV指数
    result["detailedInfo"] = detailedInfo;

    // 解析未来几天的预报
    QVariantList weeklyForecastList;
    for(int i = 0; i < forecast.size(); ++i) {
        QVariantMap dayForecast;
        QJsonObject forecastObj = forecast.at(i).toObject();
        dayForecast["date"] = forecastObj.value("ymd").toString();
        dayForecast["week"] = forecastObj.value("week").toString();
        dayForecast["high"] = forecastObj.value("high").toString();
        dayForecast["low"] = forecastObj.value("low").toString();
        dayForecast["type"] = forecastObj.value("type").toString();
        weeklyForecastList.append(dayForecast);
    }
    result["weeklyForecast"] = weeklyForecastList;

    return result;
}

QVariantMap WeatherAPIClient::parseWeeklyForecastData(const QJsonObject &json)
{
    QVariantMap result;
    QJsonObject data = json.value("data").toObject();
    QJsonObject cityInfo = json.value("cityInfo").toObject();
    QJsonArray forecast = data.value("forecast").toArray();
    
    result["cityName"] = cityInfo.value("city").toString();
    
    QVariantList recentDaysName;
    QVariantList recentDaysMaxMinTempreture;
    QVariantList recentDaysWeatherDescriptionIcon;
    QVariantList forecastList;
    
    // 处理预报数据（新API直接提供每日数据）
    for (int i = 0; i < forecast.size() && i < 7; ++i) {
        QJsonObject dayData = forecast.at(i).toObject();
        
        // 获取日期和星期
        QString week = dayData.value("week").toString();
        QString ymd = dayData.value("ymd").toString();
        
        // 格式化日期显示
        if (i == 0) {
            recentDaysName.append("今天");
        } else if (i == 1) {
            recentDaysName.append("明天");
        } else {
            recentDaysName.append(week);
        }
        
        // 获取温度信息
        QString high = dayData.value("high").toString();
        QString low = dayData.value("low").toString();
        recentDaysMaxMinTempreture.append(high + " / " + low);
        
        // 获取天气类型并转换为图标
        QString type = dayData.value("type").toString();
        QString weatherIcon = "🌤️"; // 默认图标
        
        if (type.contains("晴")) weatherIcon = "☀️";
        else if (type.contains("多云")) weatherIcon = "☁️";
        else if (type.contains("阴")) weatherIcon = "☁️";
        else if (type.contains("雨")) weatherIcon = "🌧️";
        else if (type.contains("雪")) weatherIcon = "❄️";
        else if (type.contains("雾")) weatherIcon = "🌫️";
        else if (type.contains("雷")) weatherIcon = "⛈️";
        
        recentDaysWeatherDescriptionIcon.append(weatherIcon);
        
        // 保留原始数据格式
        QVariantMap dayForecast;
        dayForecast["date"] = ymd;
        dayForecast["week"] = week;
        dayForecast["high"] = high;
        dayForecast["low"] = low;
        dayForecast["type"] = type;
        dayForecast["icon"] = weatherIcon;
        forecastList.append(dayForecast);
    }
    
    // 设置UI期望的数据格式
    QVariantMap weeklyForecast;
    weeklyForecast["recentDaysName"] = recentDaysName;
    weeklyForecast["recentDaysMaxMinTempreture"] = recentDaysMaxMinTempreture;
    weeklyForecast["recentDaysWeatherDescriptionIcon"] = recentDaysWeatherDescriptionIcon;
    
    result["weeklyForecast"] = weeklyForecast;
    result["forecast"] = forecastList;
    
    qDebug() << "Parsed weekly forecast with" << recentDaysName.size() << "days";
    
    return result;
}

QVariantMap WeatherAPIClient::parseDailyForecastData(const QJsonObject &json)
{
    // 新API的每日预报数据与周预报数据结构相同，直接复用解析逻辑
    QVariantMap result = parseWeeklyForecastData(json);
    
    qDebug() << "Parsed daily forecast data for city:" << result.value("cityName").toString();
    
    return result;
}

QVariantMap WeatherAPIClient::parseDetailedWeatherData(const QJsonObject &json)
{
    // 详细天气信息基于当前天气数据
    return parseCurrentWeatherData(json);
}

QVariantMap WeatherAPIClient::parseSunriseData(const QJsonObject &json)
{
    QVariantMap result;
    
    result["cityName"] = json.value("name").toString();
    
    QJsonObject sys = json.value("sys").toObject();
    qint64 sunriseTimestamp = sys.value("sunrise").toInt();
    qint64 sunsetTimestamp = sys.value("sunset").toInt();
    
    result["sunrise"] = QDateTime::fromSecsSinceEpoch(sunriseTimestamp).toString("hh:mm");
    result["sunset"] = QDateTime::fromSecsSinceEpoch(sunsetTimestamp).toString("hh:mm");
    result["timezone"] = json.value("timezone").toInt();
    
    return result;
}

QVariantList WeatherAPIClient::parseCitySearchData(const QJsonArray &json)
{
    QVariantList result;
    
    for (const QJsonValue &value : json) {
        QJsonObject geocode = value.toObject();
        QVariantMap cityData;
        
        // 解析OpenWeather地理编码API响应格式
        cityData["name"] = geocode.value("name").toString();
        cityData["cityName"] = geocode.value("name").toString(); // 添加cityName字段以保持一致性
        cityData["country"] = geocode.value("country").toString();
        cityData["state"] = geocode.value("state").toString();
        cityData["lat"] = geocode.value("lat").toDouble();
        cityData["lon"] = geocode.value("lon").toDouble();
        
        // 构建完整的城市名称用于天气查询
        QString fullName = geocode.value("name").toString();
        if (!geocode.value("state").toString().isEmpty()) {
            fullName += "," + geocode.value("state").toString();
        }
        fullName += "," + geocode.value("country").toString();
        cityData["fullName"] = fullName;
        
        result.append(cityData);
    }
    
    return result;
}

QString WeatherAPIClient::buildCurrentWeatherUrl(const QString &cityCode)
{
    // 新的API直接在URL后面拼接城市代码
    return m_baseUrl + cityCode;
}

QString WeatherAPIClient::buildForecastUrl(const QString &cityName)
{
    QUrl url(m_baseUrl + "/forecast");
    QUrlQuery query;
    query.addQueryItem("q", cityName);
    query.addQueryItem("appid", m_apiKey);
    query.addQueryItem("units", "metric"); // 使用摄氏度
    query.addQueryItem("lang", "zh_cn"); // 添加中文语言参数
    url.setQuery(query);
    
    return url.toString();
}

QString WeatherAPIClient::buildDailyForecastUrl(const QString &cityName)
{
    // 使用免费的5天预报API而不是付费的daily API
    QUrl url(m_baseUrl + "/forecast");
    QUrlQuery query;
    query.addQueryItem("q", cityName);
    query.addQueryItem("appid", m_apiKey);
    query.addQueryItem("units", "metric"); // 使用摄氏度
    query.addQueryItem("lang", "zh_cn"); // 添加中文语言参数
    url.setQuery(query);
    
    return url.toString();
}

QString WeatherAPIClient::buildGeocodingUrl(const QString &cityName)
{
    QUrl url(m_baseUrl + "/weatherInfo");
    QUrlQuery query;
    query.addQueryItem("city", cityName);
    query.addQueryItem("key", m_apiKey);
    url.setQuery(query);
    
    return url.toString();
}

QString WeatherAPIClient::buildSearchUrl(const QString &query)
{
    // 使用OpenWeather地理编码API进行城市搜索
    QUrl url("https://api.openweathermap.org/geo/1.0/direct");
    QUrlQuery urlQuery;
    urlQuery.addQueryItem("q", query);
    urlQuery.addQueryItem("appid", m_apiKey);
    urlQuery.addQueryItem("limit", "5"); // 限制返回5个结果
    url.setQuery(urlQuery);
    
    return url.toString();
}

QVariantMap WeatherAPIClient::createErrorResponse(const QString &error, const QString &cityName)
{
    QVariantMap errorData;
    errorData["error"] = error;
    if (!cityName.isEmpty()) {
        errorData["cityName"] = cityName;
    }
    return errorData;
}

QVariantList WeatherAPIClient::createErrorListResponse(const QString &error)
{
    QVariantList errorResults;
    QVariantMap errorData;
    errorData["error"] = error;
    errorResults.append(errorData);
    return errorResults;
}

QString WeatherAPIClient::translateCityName(const QString &englishName)
{
    // 常见城市中英文映射
    static QHash<QString, QString> cityNameMap = {
        {"Beijing", "北京"},
        {"Shanghai", "上海"},
        {"Guangzhou", "广州"},
        {"Shenzhen", "深圳"},
        {"Hangzhou", "杭州"},
        {"Nanjing", "南京"},
        {"Wuhan", "武汉"},
        {"Chengdu", "成都"},
        {"Xi'an", "西安"},
        {"Chongqing", "重庆"},
        {"Tianjin", "天津"},
        {"Shenyang", "沈阳"},
        {"Dalian", "大连"},
        {"Qingdao", "青岛"},
        {"Jinan", "济南"},
        {"Harbin", "哈尔滨"},
        {"Changchun", "长春"},
        {"Kunming", "昆明"},
        {"Xiamen", "厦门"},
        {"Fuzhou", "福州"},
        {"Hefei", "合肥"},
        {"Nanchang", "南昌"},
        {"Changsha", "长沙"},
        {"Zhengzhou", "郑州"},
        {"Taiyuan", "太原"},
        {"Shijiazhuang", "石家庄"},
        {"Hohhot", "呼和浩特"},
        {"Urumqi", "乌鲁木齐"},
        {"Lhasa", "拉萨"},
        {"Yinchuan", "银川"},
        {"Xining", "西宁"},
        {"Lanzhou", "兰州"},
        {"Guiyang", "贵阳"},
        {"Nanning", "南宁"},
        {"Haikou", "海口"},
        {"Sanya", "三亚"},
        // 国际城市
        {"New York", "纽约"},
        {"London", "伦敦"},
        {"Paris", "巴黎"},
        {"Tokyo", "东京"},
        {"Seoul", "首尔"},
        {"Singapore", "新加坡"},
        {"Sydney", "悉尼"},
        {"Melbourne", "墨尔本"},
        {"Toronto", "多伦多"},
        {"Vancouver", "温哥华"},
        {"Los Angeles", "洛杉矶"},
        {"San Francisco", "旧金山"},
        {"Chicago", "芝加哥"},
        {"Washington", "华盛顿"},
        {"Moscow", "莫斯科"},
        {"Berlin", "柏林"},
        {"Rome", "罗马"},
        {"Madrid", "马德里"},
        {"Amsterdam", "阿姆斯特丹"},
        {"Bangkok", "曼谷"},
        {"Mumbai", "孟买"},
        {"Dubai", "迪拜"}
    };
    
    // 如果找到映射则返回中文名，否则返回原英文名
    return cityNameMap.value(englishName, englishName);
}

void WeatherAPIClient::loadCityCodes()
{
    QFile file(":/WeatherAPP/citycode-2019-08-23.json"); // 使用正确的资源路径
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open citycode file.");
        return;
    }

    QByteArray cityData = file.readAll();
    QJsonDocument cityDoc = QJsonDocument::fromJson(cityData);
    QJsonArray cityArr = cityDoc.array();

    int loadedCount = 0;
    for (const QJsonValue &value : cityArr) {
        QJsonObject cityObj = value.toObject();
        QString cityName = cityObj["city_name"].toString();
        QString cityCode = cityObj["city_code"].toString();
        if (!cityName.isEmpty() && !cityCode.isEmpty()) {
            m_cityCodeMap[cityName] = cityCode;
            loadedCount++;
        }
    }
    qDebug() << "Loaded" << loadedCount << "cities from citycode file.";
}