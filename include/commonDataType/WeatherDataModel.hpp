#ifndef WEATHERDATAMODEL_HPP
#define WEATHERDATAMODEL_HPP

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QJsonObject>
#include <QJsonDocument>
#include <memory>

class WeatherDataModel : public QObject {
    Q_OBJECT
    //今日天气
    Q_PROPERTY(QString cityName READ cityName WRITE setCityName NOTIFY cityNameChanged)
    Q_PROPERTY(QString temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(QString weatherIcon READ weatherIcon WRITE setWeatherIcon NOTIFY weatherIconChanged)
    Q_PROPERTY(QString weatherDescription READ weatherDescription WRITE setWeatherDescription NOTIFY weatherDescriptionChanged)
    Q_PROPERTY(QString maxMinTemp READ maxMinTemp WRITE setMaxMinTemp NOTIFY maxMinTempChanged)
    //其余三个功能页面
    Q_PROPERTY(QVariantMap weeklyForecast READ weeklyForecast WRITE setWeeklyForecast NOTIFY weeklyForecastChanged)
    Q_PROPERTY(QVariantMap detailedInfo READ detailedInfo WRITE setDetailedInfo NOTIFY detailedInfoChanged)
    Q_PROPERTY(QVariantMap sunriseInfo READ sunriseInfo WRITE setSunriseInfo NOTIFY sunriseInfoChanged)

public:
    // 构造函数，初始化 WeatherDataModel 对象
    explicit WeatherDataModel(QObject *parent = nullptr);
    ~WeatherDataModel();

//Getter  
    // 获取城市名称
    QString cityName() const { return m_cityName; }
    // 获取当前温度
    QString temperature() const { return m_temperature; }
    // 获取天气图标标识
    QString weatherIcon() const { return m_weatherIcon; }
    // 获取天气描述
    QString weatherDescription() const { return m_weatherDescription; }
    // 获取最高最低温度
    QString maxMinTemp() const { return m_maxMinTemp; }
    // 获取每周天气预报信息
    QVariantMap weeklyForecast() const { return m_weeklyForecast; }
    // 获取详细天气信息
    QVariantMap detailedInfo() const { return m_detailedInfo; }
    // 获取日出信息
    QVariantMap sunriseInfo() const { return m_sunriseInfo; }

//Setter
    // 设置城市名称
    void setCityName(const QString &cityName);
    // 设置当前温度
    void setTemperature(const QString &temperature);
    // 设置天气图标标识
    void setWeatherIcon(const QString &weatherIcon);
    // 设置天气描述
    void setWeatherDescription(const QString &weatherDescription);
    // 设置最高最低温度
    void setMaxMinTemp(const QString &maxMinTemp);
    // 设置每周天气预报信息
    void setWeeklyForecast(const QVariantMap &weeklyForecast);
    // 设置详细天气信息
    void setDetailedInfo(const QVariantMap &detailedInfo);
    // 设置日出信息
    void setSunriseInfo(const QVariantMap &sunriseInfo);

//Static Factory Method 

// 根据原始数据创建 WeatherDataModel 实例
Q_INVOKABLE static WeatherDataModel* fromRawData(const QVariantMap& rawData , QObject *parent = nullptr);
// 创建一个空的 WeatherDataModel 实例
Q_INVOKABLE static WeatherDataModel* createEmpty(QObject *parent = nullptr);


//实例方法

// 检查当前天气数据模型是否有效
Q_INVOKABLE bool isValid() const;
// 将天气数据模型转换为 QVariantMap 对象
Q_INVOKABLE QVariantMap toObject() const;
// 克隆当前的天气数据模型，返回一个新的 WeatherDataModel 实例
Q_INVOKABLE WeatherDataModel* clone(QObject * parent = nullptr)const;
// 使用新的数据更新当前的天气数据模型
Q_INVOKABLE void updateData(const QVariantMap &newData);

signals:
    void cityNameChanged();
    void temperatureChanged();
    void weatherIconChanged();
    void weatherDescriptionChanged();
    void maxMinTempChanged();
    void weeklyForecastChanged();
    void detailedInfoChanged();
    void sunriseInfoChanged();

private:
    QString m_cityName;
    QString m_temperature;
    QString m_weatherIcon;
    QString m_weatherDescription;
    QString m_maxMinTemp;
    QVariantMap m_weeklyForecast;
    QVariantMap m_detailedInfo;
    QVariantMap m_sunriseInfo;
};

#endif // WEATHERDATAMODEL_HPP