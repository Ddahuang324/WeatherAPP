#include "../../include/viewmodels/NavigationViewModel.hpp"
#include "../../include/models/AppStateManager.hpp"
#include <QDebug>
#include <QVariantMap>

NavigationViewModel::NavigationViewModel(QObject *parent)
    : QObject(parent)
    , m_currentView("today_weather")
    , m_appStateManager(nullptr)
{
     m_defaultViews << "today_weather" << "temperature_trend" << "detailed_info" << "sunrise_sunset";
      // 初始化可用视图
    initializeAvailableViews();
}
   
NavigationViewModel::~NavigationViewModel()
{
    cleanup();
}

void NavigationViewModel::initialize(QObject *stateManager)
{
    // 清理之前的连接
    if (m_appStateManager) {
        disconnect(m_appStateManager, nullptr, this, nullptr);
    }
    
    // 设置新的状态管理器
    m_appStateManager = qobject_cast<AppStateManager*>(stateManager);
    
    if (m_appStateManager) {
        // 连接状态管理器的信号
        connect(m_appStateManager, &AppStateManager::viewmodechanged,this, &NavigationViewModel::onViewModeChanged);
        
        // 同步当前视图状态
        m_currentView = m_appStateManager->currentViewMode();
        emit currentViewChanged();
        
        qDebug() << "NavigationViewModel initialized with AppStateManager";
    } else {
        qWarning() << "Failed to cast stateManager to AppStateManager";
    }
}


bool NavigationViewModel::navigateToView(const QString &viewId)
{
    if (!isValidView(viewId)) {
        qWarning() << "Invalid view ID:" << viewId;
        return false;
    }
    
    if (m_currentView != viewId) {
        m_currentView = viewId;
        
        // 通知状态管理器
        if (m_appStateManager) {
            m_appStateManager->setViewMode(viewId);
        }
        
        // 发送信号
        emit navigationRequested(viewId);
        emit viewChanged(viewId);
        emit currentViewChanged();
        
        qDebug() << "Navigated to view:" << viewId;
        return true;
    }
    
    return false;
}

QVariantMap NavigationViewModel::getCurrentViewInfo()
{
    return getViewInfo(m_currentView);
}

QVariantMap NavigationViewModel::getViewInfo(const QString &viewId)
{
    for (const QVariant &view : m_availableViews) {
        QVariantMap viewMap = view.toMap();
        if (viewMap["id"].toString() == viewId) {
            return viewMap;
        }
    }
    return QVariantMap();
}

QVariantList NavigationViewModel::getAvailableViews()
{
    return m_availableViews;
}

bool NavigationViewModel::isValidView(const QString &viewId)
{
    return !getViewInfo(viewId).isEmpty();
}

QString NavigationViewModel::getNextView()
{
    int currentIndex = getCurrentViewIndex();
    int nextIndex = (currentIndex + 1) % m_availableViews.size();
    return m_availableViews[nextIndex].toMap()["id"].toString();
}

QString NavigationViewModel::getPreviousView()
{
    int currentIndex = getCurrentViewIndex();
    int prevIndex = (currentIndex - 1 + m_availableViews.size()) % m_availableViews.size();
    return m_availableViews[prevIndex].toMap()["id"].toString();
}
bool NavigationViewModel::navigateToNext()
{
    QString nextView = getNextView();
    return navigateToView(nextView);
}

bool NavigationViewModel::navigateToPrevious()
{
    QString prevView = getPreviousView();
    return navigateToView(prevView);
}

bool NavigationViewModel::isCurrentView(const QString &viewId)
{
    return m_currentView == viewId;
}

int NavigationViewModel::getCurrentViewIndex()
{
    return findViewIndex(m_currentView);
}

bool NavigationViewModel::resetToDefault()
{
    return navigateToView("today_weather");
}

QString NavigationViewModel::getViewPath(const QString &viewId)
{
    static QMap<QString, QString> viewPaths = {
        {"today_weather", "../views/TodayWeatherView.qml"},
        {"temperature_trend", "../views/TemperatureTrendView.qml"},
        {"detailed_info", "../views/DetailedInfoView.qml"},
        {"sunrise_sunset", "../views/SunriseSunsetView.qml"}
    };
    
    return viewPaths.value(viewId, viewPaths["today_weather"]);
}

bool NavigationViewModel::addCustomView(const QVariantMap &viewInfo)
{
   if (!viewInfo.contains("id") || !viewInfo.contains("name")) {
        qWarning() << "Invalid view info provided";
        return false;
    }
    
    QString viewId = viewInfo["id"].toString();
    
    // 检查是否已存在
    if (isValidView(viewId)) {
        qWarning() << "View already exists:" << viewId;
        return false;
    }
    
    // 创建新视图信息
    QVariantMap newView;
    newView["id"] = viewId;
    newView["name"] = viewInfo["name"].toString();
    newView["icon"] = viewInfo.value("icon", "📄").toString();
    
    // 添加到可用视图列表
    m_availableViews.append(newView);
    emit availableViewsChanged();
    
    qDebug() << "Added custom view:" << viewId;
    return true;
}

bool NavigationViewModel::removeCustomView(const QString &viewId)
{
    if (!isValidView(viewId)) {
        return false;
    }
    
    // 不允许移除默认视图
    if (m_defaultViews.contains(viewId)) {
        qWarning() << "Cannot remove default view:" << viewId;
        return false;
    }
    
    // 从列表中移除
    for (int i = 0; i < m_availableViews.size(); ++i) {
        if (m_availableViews[i].toMap()["id"].toString() == viewId) {
            m_availableViews.removeAt(i);
            break;
        }
    }
    
    emit availableViewsChanged();
    
    // 如果当前视图被移除，切换到默认视图
    if (m_currentView == viewId) {
        resetToDefault();
    }
    
    qDebug() << "Removed custom view:" << viewId;
    return true;
}

void NavigationViewModel::cleanup()
{
    if (m_appStateManager) {
        disconnect(m_appStateManager, nullptr, this, nullptr);
        m_appStateManager = nullptr;
    }
}

void NavigationViewModel::onViewModeChanged(const QString &viewMode)
{
    if (m_currentView != viewMode) {
        m_currentView = viewMode;
        emit currentViewChanged();
        emit viewChanged(viewMode);
    }
}

void NavigationViewModel::initializeAvailableViews()
{
    m_availableViews.clear();
    
    // 添加默认视图
    QVariantMap todayWeather;
    todayWeather["id"] = "today_weather";
    todayWeather["name"] = "今日天气";
    todayWeather["icon"] = "☀️";
    m_availableViews.append(todayWeather);
    
    QVariantMap temperatureTrend;
    temperatureTrend["id"] = "temperature_trend";
    temperatureTrend["name"] = "温度趋势";
    temperatureTrend["icon"] = "📈";
    m_availableViews.append(temperatureTrend);
    
    QVariantMap detailedInfo;
    detailedInfo["id"] = "detailed_info";
    detailedInfo["name"] = "详细天气";
    detailedInfo["icon"] = "📅";
    m_availableViews.append(detailedInfo);
    
    QVariantMap sunriseSunset;
    sunriseSunset["id"] = "sunrise_sunset";
    sunriseSunset["name"] = "日出日落";
    sunriseSunset["icon"] = "🌅";
    m_availableViews.append(sunriseSunset);
}

int NavigationViewModel::findViewIndex(const QString &viewId) const
{
    for (int i = 0; i < m_availableViews.size(); ++i) {
        if (m_availableViews[i].toMap()["id"].toString() == viewId) {
            return i;
        }
    }
    return 0;
}
