#ifndef WEATHERVIEWMODEL_HPP
#define WEATHERVIEWMODEL_HPP

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>
#include <QJSValue>
#include <QQmlEngine>
#include <memory>

// 前向声明
class WeatherDataService;
class AppStateManager;

class WeatherViewModel : public QObject{
    Q_OBJECT

    // 定义是否正在加载的属性，只读，通过isLoading方法访问，当isLoading状态改变时触发isLoadingChanged信号
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    // 定义错误信息的属性，只读，通过errorMessage方法访问，当错误信息改变时触发errorMessageChanged信号
    Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
    // 定义当前天气数据的属性，只读，通过currentWeatherData方法访问，当天气数据改变时触发currentWeatherDataChanged信号
    Q_PROPERTY(QVariantMap currentWeatherData READ currentWeatherData NOTIFY currentWeatherDataChanged)

public:
    explicit WeatherViewModel(QObject *parent = nullptr);
    ~WeatherViewModel();

    // 返回当前是否正在加载天气数据
    bool isLoading() const { return m_isLoading; }
    // 返回错误信息，如果有的话
    QString errorMessage() const { return m_errorMessage; }
    // 返回当前的天气数据，以 QVariantMap 格式
    QVariantMap currentWeatherData() const { return m_currentWeatherData; }

     // Public methods
        // 初始化函数，用于设置状态管理器
        Q_INVOKABLE void initialize(QObject *stateManager);
        // 加载指定城市的天气信息
        Q_INVOKABLE void loadCityWeather(const QString &cityName);
        // 根据查询字符串搜索城市，并在找到结果时调用回调函数
        Q_INVOKABLE void searchCities(const QString &query, const QJSValue &callback = QJSValue());
        // 将城市数据添加到最近访问的城市列表中
        Q_INVOKABLE void addCityToRecent(const QVariantMap &cityData);
        // 切换视图模式
        Q_INVOKABLE void switchViewMode(const QString &viewMode);
        // 切换到下一个城市
        Q_INVOKABLE void switchToNextCity();
        // 切换到上一个城市
        Q_INVOKABLE void switchToPreviousCity();
        // 根据索引切换到指定城市
        Q_INVOKABLE void switchToCity(int index);
        // 获取当前城市的数据
        Q_INVOKABLE QVariantMap getCurrentCityData();
        // 获取最近访问的城市列表
        Q_INVOKABLE QVariantList getRecentCities();
        // 获取当前城市在列表中的索引
        Q_INVOKABLE int getCurrentCityIndex();
        // 获取可管理的最大城市数量
        Q_INVOKABLE int getMaxCities();
        // 格式化温度字符串
        Q_INVOKABLE QString formatTemperature(const QString &temp);
        // 格式化天气描述字符串
        Q_INVOKABLE QString formatWeatherDescription(const QString &desc);
        // 验证天气数据的有效性
        Q_INVOKABLE bool validateWeatherData(const QVariantMap &data);
        // 清理函数，用于释放资源
        Q_INVOKABLE void cleanup();

signals:
    void isLoadingChanged();
    void errorMessageChanged();
    void currentWeatherDataChanged();
    
    void weatherDataChanged(const QVariantMap &data);
    void loadingStateChanged(bool loading);
    void errorOccurred(const QString &error);
    void searchResultsReady(const QVariantList &results);

private slots:
    void onCityChanged(const QVariantMap &cityData);
    void onViewModeChanged(const QString &viewMode);
    void onDataLoaded(const QVariantMap &data);
    void onDataLoadError(const QString &error);
    void onSearchResultsReady(const QVariantList &results);

private:
    bool m_isLoading;
    QString m_errorMessage;
    QVariantMap m_currentWeatherData;
    
    AppStateManager* m_appStateManager;
    std::unique_ptr<WeatherDataService> m_weatherDataService;
    
    void setLoading(bool loading);
    void setError(const QString &error);
    void clearError();

};


#endif // WEATHERVIEWMODEL_HPP
