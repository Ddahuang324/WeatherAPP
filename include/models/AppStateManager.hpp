#ifndef APPSTATEMANAGER_HPP
#define APPSTATEMANAGER_HPP

#include <QObject>
#include <QVariantMap>
#include <QString>
#include <QVariantList>
#include <QQmlEngine>
#include <QtQml>
#include <memory>

class WeatherDataService;

class AppStateManager : public QObject{
    Q_OBJECT

    // 定义当前城市的属性，只读并且在更改时发出通知
    Q_PROPERTY(QVariantMap currentCity READ currentCity NOTIFY currentCityChanged)
    // 定义当前视图模式的属性，只读并且在更改时发出通知
    Q_PROPERTY(QString currentViewMode READ currentViewMode NOTIFY currentViewModeChanged)
    // 定义最近城市的列表属性，只读并且在更改时发出通知
    Q_PROPERTY(QVariantList recentCities READ recentCities NOTIFY recentCitiesChanged)
    // 定义当前城市索引的属性，只读并且在更改时发出通知
    Q_PROPERTY(int currentCityIndex READ currentCityIndex NOTIFY currentCityIndexChanged)
    // 定义最大城市数的属性，可读写并且在更改时发出通知
    Q_PROPERTY(int maxCities READ maxCities WRITE setMaxCities NOTIFY maxCitiesChanged)
    // 定义天气数据的属性，只读并且在更改时发出通知
    Q_PROPERTY(QVariantMap weatherData READ weatherData NOTIFY weatherDataChanged)

public:
    explicit AppStateManager(QObject *parent = nullptr);
    ~AppStateManager();


    // 返回当前城市的详细信息
    QVariantMap currentCity() const { return m_currentCity; }
    // 返回当前视图模式
    QString currentViewMode() const { return m_currentViewMode; }
    // 返回最近访问的城市列表
    QVariantList recentCities() const { return m_recentCities; }
    // 返回当前城市在最近访问城市列表中的索引
    int currentCityIndex() const { return m_currentCityIndex; }
    // 返回允许保存的最大城市数量
    int maxCities() const { return m_maxCities; }
    // 返回当前城市的天气数据
    QVariantMap weatherData() const { return m_weatherData; }

    // 设置允许的最大城市数量
    void setMaxCities(int maxCities);

    // 初始化应用程序状态
    Q_INVOKABLE void initialize();
    // 设置当前城市的数据
    Q_INVOKABLE void setCurrentCity(const QVariantMap &cityData);
    // 设置视图模式
    Q_INVOKABLE void setViewMode(const QString &viewMode);
    // 将城市添加到最近访问的城市列表
    Q_INVOKABLE void addToRecentCities(const QVariantMap &cityData);
    // 根据索引切换到指定城市
    Q_INVOKABLE void switchToCity(int index);
    // 切换到下一个城市
    Q_INVOKABLE void switchToNext();
    // 切换到上一个城市
    Q_INVOKABLE void switchToPrevious();
    // 获取当前城市的视图数据
    Q_INVOKABLE QVariantMap getCurrentCityForView();
    // 获取指定城市的周天气预报
    Q_INVOKABLE QVariantMap getWeeklyForecast(const QString &cityName);
    // 获取指定城市的详细信息
    Q_INVOKABLE QVariantMap getDetailedInfo(const QString &cityName);
    // 获取指定城市的日出信息
    Q_INVOKABLE QVariantMap getSunriseInfo(const QString &cityName);
    // 加载示例数据
    Q_INVOKABLE void loadSampleData();

signals:
    // 当当前城市发生变化时发出通知
    void currentCityChanged();
    // 当当前视图模式发生变化时发出通知
    void currentViewModeChanged();
    // 当最近访问的城市列表发生变化时发出通知
    void recentCitiesChanged();
    // 当当前城市索引发生变化时发出通知
    void currentCityIndexChanged();
    // 当最大城市数发生变化时发出通知
    void maxCitiesChanged();
    // 当天气数据发生变化时发出通知
    void weatherDataChanged();


    // 当城市信息发生变化时调用此函数
    void citychanged(const QVariantMap &cityData);
    // 当视图模式发生变化时调用此函数
    void viewmodechanged(const QString &viewMode);
    // 当城市列表发生变化时调用此函数
    void citiesListChanged();
    // 当天气数据更新时调用此函数
    void weatherDataUpdated(const QVariantMap &data);

private slots:
    // 处理WeatherDataService的信号
    void onWeatherDataLoaded(const QVariantMap &data);
    void onWeatherDataError(const QString &error);

private:

    bool m_initialized;
    QVariantMap m_currentCity;
    QString m_currentViewMode;
    QVariantList m_recentCities;
    int m_currentCityIndex;
    int m_maxCities;
    QVariantMap m_weatherData;
    
    std::unique_ptr<WeatherDataService> m_weatherService;
    
    void setCurrentCityInternal(const QVariantMap &cityData);
    void setCurrentCityIndex(int index);

};

#endif // APPSTATEMANAGER_HPP