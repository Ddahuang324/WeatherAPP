#include "../../include/services/WeatherDataService.hpp"
#include "../../include/services/WeatherAPIClient.hpp"
#include <QTimer>
#include <QDebug>
#include <QJSValue>
#include <QJSEngine>
#include <QQmlEngine>
#include <QQmlContext>

WeatherDataService::WeatherDataService(QObject *parent) : QObject(parent)
    , m_apiClient(new WeatherAPIClient(this))
{
    // 设置API密钥 - 在实际应用中应该从配置文件或环境变量读取
    // m_apiClient->setApiKey("your_openweathermap_api_key_here");
}

WeatherDataService::~WeatherDataService() = default;



void WeatherDataService::callLater(std::function<void()> func, int delayMs){
    QTimer::singleShot(delayMs, this, func);
}//- 在指定的延迟时间后执行传入的函数


// WeatherDataService 类中的方法，用于获取指定城市的天气数据
void WeatherDataService::getCityWeather(const QString &cityName,const QJSValue &callback){
    qDebug() << "WeatherDataService::getCityWeather called for city:" << cityName;
    
    if (!validateCityName(cityName)) {
        qDebug() << "Invalid city name:" << cityName;
        QVariantMap errorData;
        errorData["cityName"] = cityName;
        errorData["error"] = "Invalid city name";
        
        // 使用安全的回调处理
        QTimer::singleShot(0, this, [this, callback, errorData]() {
            try {
                QQmlEngine* engine = qmlEngine(this);
                if (!engine) {
                    engine = qmlContext(this) ? qmlContext(this)->engine() : nullptr;
                }
                
                if (engine && callback.isCallable()) {
                    QJSValueList args;
                    args << engine->toScriptValue(errorData);
                    const_cast<QJSValue&>(callback).call(args);
                } else if (callback.isCallable()) {
                    qDebug() << "QML engine is null, attempting direct callback";
                    const_cast<QJSValue&>(callback).call(QJSValueList() << QJSValue());
                }
            } catch (const std::exception& e) {
                qDebug() << "Exception in getCityWeather callback:" << e.what();
            } catch (...) {
                qDebug() << "Unknown exception in getCityWeather callback";
            }
        });
        
        qDebug() << "Emitting dataLoaded with error data:" << errorData;
        emit dataLoaded(errorData);
        return;
    }
    
    qDebug() << "Requesting weather data from API client for city:" << cityName;
    // 使用WeatherAPIClient获取真实天气数据
    m_apiClient->getCurrentWeather(cityName, [this, callback, cityName](const QVariantMap &data) {
        qDebug() << "WeatherDataService received API response for city:" << cityName << "Data:" << data;
        
        // 构建正确的数据结构
        QVariantMap processedData = data;
        
        // 由于API已经在parseCurrentWeatherData中构建了detailedInfo，这里不需要重复构建
        // 直接使用API返回的detailedInfo数据
        if (!data.contains("detailedInfo")) {
            // 如果API没有返回detailedInfo，则构建一个默认的
            QVariantMap detailedInfo;
            detailedInfo["humidity"] = data.value("shidu", "--").toString();
            detailedInfo["windSpeed"] = data.value("fl", "--").toString();
            detailedInfo["rainfall"] = "0mm";
            detailedInfo["airQuality"] = data.value("quality", "--").toString();
            detailedInfo["airPressure"] = "--hPa";
            detailedInfo["uvIndex"] = "--";
            processedData["detailedInfo"] = detailedInfo;
        }
        
        // 构建sunriseInfo结构
        QVariantMap sunriseInfo;
        sunriseInfo["sunrise"] = data.value("sunrise", "--:--");
        sunriseInfo["sunset"] = data.value("sunset", "--:--");
        sunriseInfo["timezone"] = data.value("timezone", 0);
        processedData["sunriseInfo"] = sunriseInfo;
        
        qDebug() << "Processed data with detailedInfo and sunriseInfo:" << processedData;
        
        // 使用安全的回调处理
        QTimer::singleShot(0, this, [this, callback, processedData]() {
            try {
                QQmlEngine* engine = qmlEngine(this);
                if (!engine) {
                    engine = qmlContext(this) ? qmlContext(this)->engine() : nullptr;
                }
                
                if (engine && callback.isCallable()) {
                    QJSValueList args;
                    args << engine->toScriptValue(processedData);
                    const_cast<QJSValue&>(callback).call(args);
                } else if (callback.isCallable()) {
                    qDebug() << "QML engine is null, attempting direct callback";
                    const_cast<QJSValue&>(callback).call(QJSValueList() << QJSValue());
                }
            } catch (const std::exception& e) {
                qDebug() << "Exception in getCityWeather callback:" << e.what();
            } catch (...) {
                qDebug() << "Unknown exception in getCityWeather callback";
            }
        });
        
        qDebug() << "Emitting dataLoaded with processed weather data:" << processedData;
        emit dataLoaded(processedData);
    });
}

// 获取指定城市的周天气预报
void WeatherDataService::getWeeklyForecast(const QString &cityName, const QJSValue &callback) {
    if (!validateCityName(cityName)) {
        QVariantMap errorData;
        errorData["cityName"] = cityName;
        errorData["error"] = "Invalid city name";
        
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(errorData);
            const_cast<QJSValue&>(callback).call(args);
        }
        return;
    }
    
    // 使用WeatherAPIClient获取周天气预报
    m_apiClient->getWeeklyForecast(cityName, [this, callback](const QVariantMap &data) {
        // 发出dataLoaded信号，让AppStateManager能够接收到数据
        emit dataLoaded(data);
        
        // 如果有回调函数，也调用它
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(data);
            const_cast<QJSValue&>(callback).call(args);
        }
    });
}

// 获取指定城市的每日天气预报
void WeatherDataService::getDailyForecast(const QString &cityName, const QJSValue &callback) {
    if (!validateCityName(cityName)) {
        QVariantMap errorData;
        errorData["cityName"] = cityName;
        errorData["error"] = "Invalid city name";
        
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(errorData);
            const_cast<QJSValue&>(callback).call(args);
        }
        return;
    }
    
    // 使用WeatherAPIClient获取每日天气预报
    m_apiClient->getDailyForecast(cityName, [this, callback](const QVariantMap &data) {
        // 发出dataLoaded信号，让AppStateManager能够接收到数据
        emit dataLoaded(data);
        
        // 如果有回调函数，也调用它
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(data);
            const_cast<QJSValue&>(callback).call(args);
        }
    });
}
// 获取指定城市的详细天气信息
void WeatherDataService::getDetailedWeatherInfo(const QString &cityName, const QJSValue &callback) {
    if (!validateCityName(cityName)) {
        QVariantMap errorData;
        errorData["cityName"] = cityName;
        errorData["error"] = "Invalid city name";
        
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(errorData);
            const_cast<QJSValue&>(callback).call(args);
        }
        return;
    }
    
    // 使用WeatherAPIClient获取详细天气信息
    m_apiClient->getDetailedWeatherInfo(cityName, [this, callback](const QVariantMap &data) {
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(data);
            const_cast<QJSValue&>(callback).call(args);
        }
    });
}

// 获取指定城市的日出信息
void WeatherDataService::getSunriseInfo(const QString &cityName, const QJSValue &callback) {
    if (!validateCityName(cityName)) {
        QVariantMap errorData;
        errorData["cityName"] = cityName;
        errorData["error"] = "Invalid city name";
        
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(errorData);
            const_cast<QJSValue&>(callback).call(args);
        }
        return;
    }
    
    // 使用WeatherAPIClient获取日出日落信息
    m_apiClient->getSunriseInfo(cityName, [this, callback](const QVariantMap &data) {
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(data);
            const_cast<QJSValue&>(callback).call(args);
        }
    });
}

// 根据查询字符串搜索城市
void WeatherDataService::searchCities(const QString &query, const QJSValue &callback) {
    if (query.trimmed().isEmpty()) {
        QVariantList errorResults;
        QVariantMap errorData;
        errorData["error"] = "Empty search query";
        errorResults.append(errorData);
        
        if (callback.isCallable()) {
            QJSValueList args;
            args << qmlEngine(this)->toScriptValue(errorResults);
            const_cast<QJSValue&>(callback).call(args);
        }
        return;
    }
    
    // 使用WeatherAPIClient搜索城市
    m_apiClient->searchCities(query, [this, callback](const QVariantList &results) {
        // 总是发射信号，无论是否有回调
        emit searchResultsReady(results);
        
        if (callback.isCallable()) {
            // 尝试多种方式获取QML引擎
            QQmlEngine *engine = qmlEngine(this);
            if (!engine) {
                // 尝试从QML上下文获取引擎
                QQmlContext *context = qmlContext(this);
                if (context) {
                    engine = context->engine();
                }
            }
            
            if (!engine) {
                qDebug() << "QML engine is null, but signal already emitted";
                return;
            }
            
            try {
                QJSValueList args;
                args << engine->toScriptValue(results);
                
                // 使用QTimer::singleShot来确保在主线程中执行回调
                QTimer::singleShot(0, this, [callback, args]() mutable {
                    try {
                        if (callback.isCallable()) {
                            const_cast<QJSValue&>(callback).call(args);
                        }
                    } catch (const std::exception &e) {
                        qDebug() << "Exception in callback execution:" << e.what();
                    } catch (...) {
                        qDebug() << "Unknown exception in callback execution";
                    }
                });
            } catch (const std::exception &e) {
                qDebug() << "Exception in search callback:" << e.what();
            } catch (...) {
                qDebug() << "Unknown exception in search callback";
            }
        }
    });
}











bool WeatherDataService::validateCityName(const QString &cityName){
    return !cityName.trimmed().isEmpty();
}
