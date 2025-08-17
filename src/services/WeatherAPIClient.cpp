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
#include <algorithm>
#include <functional>

WeatherAPIClient::WeatherAPIClient(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_apiKey("98385aa2f0f513f6868cb258a62a227c") // OpenWeather API密钥
    , m_baseUrl("https://api.openweathermap.org/data/2.5") // OpenWeather API
{
    // 连接网络请求完成信号
    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, &WeatherAPIClient::onNetworkReplyFinished);
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
    if (m_apiKey.isEmpty()) {
        callback(createErrorResponse("API key not set", cityName));
        return;
    }
    
    QString url = buildCurrentWeatherUrl(cityName);
    sendRequest(url, callback);
}

void WeatherAPIClient::getWeeklyForecast(const QString &cityName, std::function<void(const QVariantMap&)> callback)
{
    if (m_apiKey.isEmpty()) {
        callback(createErrorResponse("API key not set", cityName));
        return;
    }
    
    QString url = buildForecastUrl(cityName);
    sendRequest(url, callback);
}

void WeatherAPIClient::getDailyForecast(const QString &cityName, std::function<void(const QVariantMap&)> callback)
{
    if (m_apiKey.isEmpty()) {
        callback(createErrorResponse("API key not set", cityName));
        return;
    }
    
    QString url = buildDailyForecastUrl(cityName);
    sendRequest(url, callback);
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
    if (m_apiKey.isEmpty()) {
        callback(createErrorListResponse("API key not set"));
        return;
    }
    
    QString url = buildSearchUrl(query);
    sendRequestForList(url, callback);
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
    
    // 城市名称中文映射
    QString originalCityName = json.value("name").toString();
    QString chineseCityName = translateCityName(originalCityName);
    
    result["cityName"] = chineseCityName;
    result["country"] = json.value("sys").toObject().value("country").toString();
    
    QJsonObject main = json.value("main").toObject();
    double currentTemp = main.value("temp").toDouble();
    double maxTemp = main.value("temp_max").toDouble();
    double minTemp = main.value("temp_min").toDouble();
    
    result["temperature"] = QString::number(qRound(currentTemp)) + "°C"; // OpenWeather已经是摄氏度
    result["maxMinTemp"] = QString::number(qRound(maxTemp)) + "°C / " + QString::number(qRound(minTemp)) + "°C";
    result["humidity"] = main.value("humidity").toInt();
    result["pressure"] = main.value("pressure").toInt();
    result["feelsLike"] = qRound(main.value("feels_like").toDouble());
    
    QJsonArray weatherArray = json.value("weather").toArray();
    if (!weatherArray.isEmpty()) {
        QJsonObject weather = weatherArray.first().toObject();
        QString originalDescription = weather.value("description").toString();
        
        // 将OpenWeather图标代码转换为emoji
        QString iconCode = weather.value("icon").toString();
        QString weatherIcon = "🌤️"; // 默认图标
        QString chineseDescription = "未知"; // 默认中文描述
        
        if (iconCode.startsWith("01")) {
            weatherIcon = "☀️"; // 晴天
            chineseDescription = "晴";
        }
        else if (iconCode.startsWith("02")) {
            weatherIcon = "⛅"; // 少云
            chineseDescription = "少云";
        }
        else if (iconCode.startsWith("03") || iconCode.startsWith("04")) {
            weatherIcon = "☁️"; // 多云
            chineseDescription = "多云";
        }
        else if (iconCode.startsWith("09") || iconCode.startsWith("10")) {
            weatherIcon = "🌧️"; // 雨
            chineseDescription = "雨";
        }
        else if (iconCode.startsWith("11")) {
            weatherIcon = "⛈️"; // 雷雨
            chineseDescription = "雷雨";
        }
        else if (iconCode.startsWith("13")) {
            weatherIcon = "❄️"; // 雪
            chineseDescription = "雪";
        }
        else if (iconCode.startsWith("50")) {
            weatherIcon = "🌫️"; // 雾
            chineseDescription = "雾";
        }
        
        // 优先使用API返回的中文描述，如果为空或英文则使用映射的中文描述
        QString finalDescription = originalDescription;
        if (originalDescription.isEmpty() || originalDescription.contains(QRegularExpression("[a-zA-Z]")) || originalDescription == "unknown") {
            finalDescription = chineseDescription;
        }
        
        result["weatherDescription"] = finalDescription;
        result["weatherIcon"] = weatherIcon;
        result["main"] = weather.value("main").toString();
    }
    
    QJsonObject wind = json.value("wind").toObject();
    result["windSpeed"] = wind.value("speed").toDouble();
    result["windDirection"] = wind.value("deg").toInt();
    
    QJsonObject sys = json.value("sys").toObject();
    result["sunrise"] = QDateTime::fromSecsSinceEpoch(sys.value("sunrise").toInt()).toString("hh:mm");
    result["sunset"] = QDateTime::fromSecsSinceEpoch(sys.value("sunset").toInt()).toString("hh:mm");
    
    result["visibility"] = json.value("visibility").toInt() / 1000; // 转换为公里
    result["timezone"] = json.value("timezone").toInt();
    
    // 添加调试日志
    qDebug() << "Parsed weather data:" << result;
    
    return result;
}

QVariantMap WeatherAPIClient::parseWeeklyForecastData(const QJsonObject &json)
{
    QVariantMap result;
    
    QJsonObject city = json.value("city").toObject();
    result["cityName"] = city.value("name").toString();
    result["country"] = city.value("country").toString();
    
    QVariantList forecast;
    QVariantList recentDaysName;
    QVariantList recentDaysMaxMinTempreture;
    QVariantList recentDaysWeatherDescriptionIcon;
    
    QJsonArray list = json.value("list").toArray();
    
    // 按日期分组数据（OpenWeather API返回每3小时的数据）
    QMap<QString, QList<QJsonObject>> dailyData;
    
    for (const QJsonValue &value : list) {
        QJsonObject item = value.toObject();
        qint64 timestamp = item.value("dt").toInt();
        QDateTime dateTime = QDateTime::fromSecsSinceEpoch(timestamp);
        QString dateKey = dateTime.toString("yyyy-MM-dd");
        
        dailyData[dateKey].append(item);
    }
    
    // 处理每一天的数据
    QStringList sortedDates = dailyData.keys();
    std::sort(sortedDates.begin(), sortedDates.end());
    
    for (const QString &date : sortedDates) {
        if (recentDaysName.size() >= 7) break; // 限制为7天
        
        const QList<QJsonObject> &dayItems = dailyData[date];
        if (dayItems.isEmpty()) continue;
        
        // 计算当天的最高最低温度
        double minTemp = 1000, maxTemp = -1000;
        QString weatherIcon = "☀️";
        QString weatherDescription = "晴";
        
        for (const QJsonObject &item : dayItems) {
            QJsonObject main = item.value("main").toObject();
            double temp = main.value("temp").toDouble();
            minTemp = qMin(minTemp, temp);
            maxTemp = qMax(maxTemp, temp);
            
            // 使用中午时段的天气图标和描述
            qint64 timestamp = item.value("dt").toInt();
            QDateTime dateTime = QDateTime::fromSecsSinceEpoch(timestamp);
            int hour = dateTime.time().hour();
            if (hour >= 12 && hour <= 15) {
                QJsonArray weatherArray = item.value("weather").toArray();
                if (!weatherArray.isEmpty()) {
                    QJsonObject weather = weatherArray.first().toObject();
                    weatherDescription = weather.value("description").toString();
                    QString iconCode = weather.value("icon").toString();
                    
                    // 将OpenWeather图标代码转换为emoji
                    if (iconCode.startsWith("01")) weatherIcon = "☀️"; // 晴天
                    else if (iconCode.startsWith("02")) weatherIcon = "⛅"; // 少云
                    else if (iconCode.startsWith("03") || iconCode.startsWith("04")) weatherIcon = "☁️"; // 多云
                    else if (iconCode.startsWith("09") || iconCode.startsWith("10")) weatherIcon = "🌧️"; // 雨
                    else if (iconCode.startsWith("11")) weatherIcon = "⛈️"; // 雷雨
                    else if (iconCode.startsWith("13")) weatherIcon = "❄️"; // 雪
                    else if (iconCode.startsWith("50")) weatherIcon = "🌫️"; // 雾
                    else weatherIcon = "🌤️"; // 默认
                }
            }
        }
        
        // 格式化日期显示
        QDateTime dateTime = QDateTime::fromString(date, "yyyy-MM-dd");
        QString displayDate = dateTime.toString("MM-dd");
        
        // 添加到UI期望的数组格式
        recentDaysName.append(displayDate);
        recentDaysMaxMinTempreture.append(QString("%1°C / %2°C")
                                         .arg(qRound(maxTemp))
                                         .arg(qRound(minTemp)));
        recentDaysWeatherDescriptionIcon.append(weatherIcon);
        
        // 保留原始forecast格式以备其他用途
        QVariantMap dayData;
        dayData["date"] = date;
        dayData["tempMin"] = qRound(minTemp);
        dayData["tempMax"] = qRound(maxTemp);
        dayData["description"] = weatherDescription;
        dayData["icon"] = weatherIcon;
        forecast.append(dayData);
    }
    
    // 设置UI期望的数据格式
    QVariantMap weeklyForecast;
    weeklyForecast["recentDaysName"] = recentDaysName;
    weeklyForecast["recentDaysMaxMinTempreture"] = recentDaysMaxMinTempreture;
    weeklyForecast["recentDaysWeatherDescriptionIcon"] = recentDaysWeatherDescriptionIcon;
    
    result["weeklyForecast"] = weeklyForecast;
    result["forecast"] = forecast; // 保留原始数据
    
    return result;
}

QVariantMap WeatherAPIClient::parseDailyForecastData(const QJsonObject &json)
{
    QVariantMap result;
    
    QJsonObject city = json.value("city").toObject();
    result["cityName"] = city.value("name").toString();
    result["country"] = city.value("country").toString();
    
    QVariantList forecast;
    QVariantList recentDaysName;
    QVariantList recentDaysMaxMinTempreture;
    QVariantList recentDaysWeatherDescriptionIcon;
    
    QJsonArray list = json.value("list").toArray();
    
    // 用于按日期分组数据（5天预报API返回每3小时的数据）
    QMap<QString, QList<QJsonObject>> dailyData;
    
    // 按日期分组所有数据点
    for (const QJsonValue &value : list) {
        QJsonObject item = value.toObject();
        qint64 timestamp = item.value("dt").toInt();
        QDateTime dateTime = QDateTime::fromSecsSinceEpoch(timestamp);
        QString dateKey = dateTime.toString("yyyy-MM-dd");
        
        dailyData[dateKey].append(item);
    }
    
    // 处理每一天的数据
    QStringList sortedDates = dailyData.keys();
    std::sort(sortedDates.begin(), sortedDates.end());
    
    for (const QString &dateKey : sortedDates) {
        if (recentDaysName.size() >= 5) break; // 限制为5天（API限制）
        
        const QList<QJsonObject> &dayItems = dailyData[dateKey];
        if (dayItems.isEmpty()) continue;
        
        // 计算当天的最高最低温度
        double minTemp = std::numeric_limits<double>::max();
        double maxTemp = std::numeric_limits<double>::lowest();
        QString weatherIcon = "☀️";
        QString weatherDescription = "晴";
        
        // 遍历当天所有时间点的数据
        for (const QJsonObject &item : dayItems) {
            QJsonObject main = item.value("main").toObject();
            double temp = main.value("temp").toDouble();
            minTemp = std::min(minTemp, temp);
            maxTemp = std::max(maxTemp, temp);
            
            // 使用中午时段的天气信息作为代表
            qint64 timestamp = item.value("dt").toInt();
            QDateTime dateTime = QDateTime::fromSecsSinceEpoch(timestamp);
            int hour = dateTime.time().hour();
            if (hour >= 11 && hour <= 14) { // 中午时段
                QJsonArray weatherArray = item.value("weather").toArray();
                if (!weatherArray.isEmpty()) {
                    QJsonObject weather = weatherArray.first().toObject();
                    weatherDescription = weather.value("description").toString();
                    QString iconCode = weather.value("icon").toString();
                    
                    // 将OpenWeather图标代码转换为emoji
                    if (iconCode.startsWith("01")) weatherIcon = "☀️"; // 晴天
                    else if (iconCode.startsWith("02")) weatherIcon = "⛅"; // 少云
                    else if (iconCode.startsWith("03") || iconCode.startsWith("04")) weatherIcon = "☁️"; // 多云
                    else if (iconCode.startsWith("09") || iconCode.startsWith("10")) weatherIcon = "🌧️"; // 雨
                    else if (iconCode.startsWith("11")) weatherIcon = "⛈️"; // 雷雨
                    else if (iconCode.startsWith("13")) weatherIcon = "❄️"; // 雪
                    else if (iconCode.startsWith("50")) weatherIcon = "🌫️"; // 雾
                    else weatherIcon = "🌤️"; // 默认
                }
            }
        }
        
        // 格式化日期显示
        QDateTime dateTime = QDateTime::fromString(dateKey, "yyyy-MM-dd");
        QString displayDate = dateTime.toString("MM-dd");
        
        // 添加到UI期望的数组格式
        recentDaysName.append(displayDate);
        recentDaysMaxMinTempreture.append(QString("%1°C / %2°C")
                                         .arg(qRound(maxTemp))
                                         .arg(qRound(minTemp)));
        recentDaysWeatherDescriptionIcon.append(weatherIcon);
        
        // 保留原始forecast格式以备其他用途
        QVariantMap dayData;
        dayData["date"] = dateKey;
        dayData["tempMin"] = qRound(minTemp);
        dayData["tempMax"] = qRound(maxTemp);
        dayData["description"] = weatherDescription;
        dayData["icon"] = weatherIcon;
        forecast.append(dayData);
    }
    
    // 设置UI期望的数据格式
    QVariantMap weeklyForecast;
    weeklyForecast["recentDaysName"] = recentDaysName;
    weeklyForecast["recentDaysMaxMinTempreture"] = recentDaysMaxMinTempreture;
    weeklyForecast["recentDaysWeatherDescriptionIcon"] = recentDaysWeatherDescriptionIcon;
    
    result["weeklyForecast"] = weeklyForecast;
    result["forecast"] = forecast; // 保留原始数据
    
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

QString WeatherAPIClient::buildCurrentWeatherUrl(const QString &cityName)
{
    QUrl url(m_baseUrl + "/weather");
    QUrlQuery query;
    query.addQueryItem("q", cityName);
    query.addQueryItem("appid", m_apiKey);
    query.addQueryItem("units", "metric"); // 使用摄氏度
    query.addQueryItem("lang", "zh_cn"); // 添加中文语言参数
    url.setQuery(query);
    
    return url.toString();
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