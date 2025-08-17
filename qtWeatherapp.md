好的，我已经仔细分析了你的项目和参考文档。现在，我将为你生成一份详细的Markdown文件，其中包含了将参考文档中的API数据调用和解析方法，一步步应用到你的项目中的完整过程。

# 将参考文档中的天气API应用到你的项目中

本文档将指导你如何将参考文档 `QT天气工具项目-水印.pdf` 中描述的天气API，集成到你的 `WeatherAPP` 项目中。我们将重点修改API的调用方式和JSON数据的解析逻辑。

## 第一步：理解参考文档中的API

在采取行动之前，我们先从 `QT天气工具项目-水印.pdf` 中提炼出关键信息：

  * [cite\_start]**API基础URL**: `http://t.weather.itboy.net/api/weather/city/` [cite: 1892]
  * [cite\_start]**城市代码**: API通过城市代码来查询特定城市的天气，例如北京的代码是 `101010100` [cite: 1953, 1954]
  * [cite\_start]**数据来源**: 城市代码来源于项目中的 `citycode-2019-08-23.json` 文件 [cite: 1915]
  * [cite\_start]**返回数据**: API返回的是一个包含天气信息的JSON对象 [cite: 1981]

## 第二步：修改`WeatherAPIClient.cpp`以适配新的API

现在，我们需要修改你的 `WeatherAPIClient.cpp` 文件，使其能够调用新的API并解析返回的数据。

### 1\. 更新API的URL

首先，我们需要修改 `m_baseUrl` 和相关的URL构建函数。

打开 `src/services/WeatherAPIClient.cpp` 文件，找到 `WeatherAPIClient` 的构造函数，并将 `m_baseUrl` 的值修改为：

```cpp
WeatherAPIClient::WeatherAPIClient(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_apiKey("") // 新的API不需要apiKey，所以这里留空
    , m_baseUrl("http://t.weather.itboy.net/api/weather/city/") // 修改为新的API地址
{
    // ...
}
```

接下来，修改 `buildCurrentWeatherUrl` 函数，使其能够正确地拼接城市代码：

```cpp
QString WeatherAPIClient::buildCurrentWeatherUrl(const QString &cityCode)
{
    // 新的API直接在URL后面拼接城市代码
    return m_baseUrl + cityCode;
}
```

### 2\. 实现城市代码查询

你的项目中没有 `citycode-2019-08-23.json`，你需要先将这个文件添加到你的项目资源中。然后，我们可以模仿参考文档中的方法，在 `WeatherAPIClient` 中添加一个函数来根据城市名称查找城市代码。

首先，在 `WeatherAPIClient.hpp` 中添加一个新的私有成员变量和一个新的私有方法：

```cpp
private:
    // ...
    QMap<QString, QString> m_cityCodeMap;
    void loadCityCodes();
```

然后，在 `WeatherAPIClient.cpp` 的构造函数中调用这个新的加载函数：

```cpp
WeatherAPIClient::WeatherAPIClient(QObject *parent)
    : QObject(parent)
    // ...
{
    // ...
    loadCityCodes(); // 在构造函数中加载城市代码
}
```

接下来，实现 `loadCityCodes` 函数，这个函数将负责读取并解析 `citycode-2019-08-23.json` 文件：

```cpp
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

void WeatherAPIClient::loadCityCodes()
{
    QFile file(":/citycode-2019-08-23.json"); // 确保你已经将这个json文件添加到了qrc资源文件中
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning("Couldn't open citycode file.");
        return;
    }

    QByteArray cityData = file.readAll();
    QJsonDocument cityDoc = QJsonDocument::fromJson(cityData);
    QJsonArray cityArr = cityDoc.array();

    for (const QJsonValue &value : cityArr) {
        QJsonObject cityObj = value.toObject();
        QString cityName = cityObj["city_name"].toString();
        QString cityCode = cityObj["city_code"].toString();
        if (!cityName.isEmpty() && !cityCode.isEmpty()) {
            m_cityCodeMap[cityName] = cityCode;
        }
    }
}
```

最后，你需要修改 `getCurrentWeather` 函数，让它在调用API前，先通过城市名称获取城市代码：

```cpp
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
```

### 3\. 修改JSON解析逻辑

新的API返回的JSON结构与你项目中当前使用的API不同。因此，我们需要修改 `parseCurrentWeatherData` 函数。

[cite\_start]根据参考文档中的JSON结构 [cite: 1982, 1990, 1998]，更新后的 `parseCurrentWeatherData` 应该如下所示：

```cpp
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
```

## 第三步：更新`WeatherDataModel`

你的 `WeatherDataModel` 也需要进行相应的调整，以匹配新的数据结构。

打开 `include/commonDataType/WeatherDataModel.hpp` 和 `src/models/WeatherDataModel.cpp`，确保其中包含了处理新数据字段（如 `ganmao`, `notice` 等）的成员变量和方法。

例如，在 `WeatherDataModel.hpp` 中添加：

```cpp
// ...
Q_PROPERTY(QString ganmao READ ganmao WRITE setGanmao NOTIFY ganmaoChanged)
Q_PROPERTY(QString notice READ notice WRITE setNotice NOTIFY noticeChanged)
// ...

public:
// ...
    QString ganmao() const { return m_ganmao; }
    QString notice() const { return m_notice; }

    void setGanmao(const QString &ganmao);
    void setNotice(const QString &notice);
// ...

signals:
// ...
    void ganmaoChanged();
    void noticeChanged();
// ...

private:
// ...
    QString m_ganmao;
    QString m_notice;
// ...
```

然后，在 `WeatherDataModel.cpp` 中实现对应的 `set` 函数，并在 `fromRawData` 中添加赋值逻辑。

## 第四步：更新UI

最后，检查你的QML文件，确保它们现在绑定到了正确的数据字段上。例如，在显示感冒指数的地方，你应该绑定到 `weatherData.ganmao`。

完成以上步骤后，你的 `WeatherAPP` 项目应该就能够成功调用参考文档中的天气API，并正确地解析和显示天气数据了。