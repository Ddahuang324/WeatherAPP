// NavigationViewModel.qml - 导航视图模型
import QtQuick

QtObject {
    id: navigationViewModel
    
    // 依赖注入
    property var appStateManager: null
    
    // 导航状态
    property string currentView: "today_weather"
    property var availableViews: [
        { id: "today_weather", name: "今日天气", icon: "☀️" },
        { id: "temperature_trend", name: "温度趋势", icon: "📈" },
        { id: "detailed_info", name: "详细天气", icon: "📅" },
        { id: "sunrise_sunset", name: "日出日落", icon: "🌅" }
    ]
    
    // 信号
    signal viewChanged(string viewId)
    signal navigationRequested(string viewId)
    
    // 初始化
    function initialize(stateManager) {
        appStateManager = stateManager
        
        if (appStateManager) {
            appStateManager.viewModeChanged.connect(onViewModeChanged)
            currentView = appStateManager.currentViewMode
        }
    }
    
    // 导航到指定视图
    function navigateToView(viewId) {
        if (!isValidView(viewId)) {
            console.warn("Invalid view ID:", viewId)
            return false
        }
        
        if (currentView !== viewId) {
            currentView = viewId
            
            // 通知状态管理器
            if (appStateManager) {
                appStateManager.setViewMode(viewId)
            }
            
            // 发送导航信号
            navigationRequested(viewId)
            viewChanged(viewId)
            
            console.log("Navigated to view:", viewId)
            return true
        }
        
        return false
    }
    
    // 获取当前视图信息
    function getCurrentViewInfo() {
        return getViewInfo(currentView)
    }
    
    // 获取指定视图信息
    function getViewInfo(viewId) {
        for (var i = 0; i < availableViews.length; i++) {
            if (availableViews[i].id === viewId) {
                return availableViews[i]
            }
        }
        return null
    }
    
    // 获取所有可用视图
    function getAvailableViews() {
        return availableViews
    }
    
    // 验证视图ID是否有效
    function isValidView(viewId) {
        return getViewInfo(viewId) !== null
    }
    
    // 获取下一个视图
    function getNextView() {
        var currentIndex = getCurrentViewIndex()
        var nextIndex = (currentIndex + 1) % availableViews.length
        return availableViews[nextIndex].id
    }
    
    // 获取上一个视图
    function getPreviousView() {
        var currentIndex = getCurrentViewIndex()
        var prevIndex = (currentIndex - 1 + availableViews.length) % availableViews.length
        return availableViews[prevIndex].id
    }
    
    // 导航到下一个视图
    function navigateToNext() {
        var nextView = getNextView()
        return navigateToView(nextView)
    }
    
    // 导航到上一个视图
    function navigateToPrevious() {
        var prevView = getPreviousView()
        return navigateToView(prevView)
    }
    
    // 检查是否为当前视图
    function isCurrentView(viewId) {
        return currentView === viewId
    }
    
    // 获取当前视图索引
    function getCurrentViewIndex() {
        for (var i = 0; i < availableViews.length; i++) {
            if (availableViews[i].id === currentView) {
                return i
            }
        }
        return 0
    }
    
    // 重置到默认视图
    function resetToDefault() {
        return navigateToView("today_weather")
    }
    
    // 获取视图路径
    function getViewPath(viewId) {
        var viewPaths = {
            "today_weather": "../views/TodayWeatherView.qml",
            "temperature_trend": "../views/TemperatureTrendView.qml",
            "detailed_info": "../views/DetailedInfoView.qml",
            "sunrise_sunset": "../views/SunriseSunsetView.qml"
        }
        
        return viewPaths[viewId] || viewPaths["today_weather"]
    }
    
    // 事件处理：视图模式变化
    function onViewModeChanged(viewMode) {
        if (currentView !== viewMode) {
            currentView = viewMode
            viewChanged(viewMode)
        }
    }
    
    // 添加自定义视图
    function addCustomView(viewInfo) {
        if (!viewInfo || !viewInfo.id || !viewInfo.name) {
            console.warn("Invalid view info provided")
            return false
        }
        
        // 检查是否已存在
        if (isValidView(viewInfo.id)) {
            console.warn("View already exists:", viewInfo.id)
            return false
        }
        
        var newViews = availableViews.slice()
        newViews.push({
            id: viewInfo.id,
            name: viewInfo.name,
            icon: viewInfo.icon || "📄"
        })
        
        availableViews = newViews
        console.log("Added custom view:", viewInfo.id)
        return true
    }
    
    // 移除自定义视图
    function removeCustomView(viewId) {
        if (!isValidView(viewId)) {
            return false
        }
        
        // 不允许移除默认视图
        var defaultViews = ["today_weather", "temperature_trend", "detailed_info", "sunrise_sunset"]
        if (defaultViews.includes(viewId)) {
            console.warn("Cannot remove default view:", viewId)
            return false
        }
        
        var newViews = availableViews.filter(function(view) {
            return view.id !== viewId
        })
        
        availableViews = newViews
        
        // 如果当前视图被移除，切换到默认视图
        if (currentView === viewId) {
            resetToDefault()
        }
        
        console.log("Removed custom view:", viewId)
        return true
    }
    
    // 清理资源
    function cleanup() {
        if (appStateManager) {
            appStateManager.viewModeChanged.disconnect(onViewModeChanged)
        }
    }
}