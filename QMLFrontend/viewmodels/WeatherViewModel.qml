// WeatherViewModel.qml - 天气视图模型
import QtQuick
import "../models"
import "../services"

QtObject {
    id: weatherViewModel
    
    // 依赖注入
    property var appStateManager: null
    property var weatherDataService: WeatherDataService {}
    
    // 视图状态
    property bool isLoading: false
    property string errorMessage: ""
    property var currentWeatherData: null
    
    // 信号
    signal weatherDataChanged(var data)
    signal loadingStateChanged(bool loading)
    signal errorOccurred(string error)
    
    // 初始化
    function initialize(stateManager) {
        appStateManager = stateManager
        
        // 监听状态管理器的变化
        if (appStateManager) {
            appStateManager.cityChanged.connect(onCityChanged)
            appStateManager.viewModeChanged.connect(onViewModeChanged)
        }
        
        // 监听数据服务的信号
        weatherDataService.dataLoaded.connect(onDataLoaded)
        weatherDataService.dataLoadError.connect(onDataLoadError)
    }
    
    // 加载城市天气数据
    function loadCityWeather(cityName) {
        if (!cityName) return
        
        setLoading(true)
        clearError()
        
        weatherDataService.getCityWeather(cityName, function(data) {
            var weatherModel = WeatherDataModel.fromRawData(data)
            currentWeatherData = weatherModel
            weatherDataChanged(weatherModel)
            setLoading(false)
        })
    }
    
    // 搜索城市
    function searchCities(query, callback) {
        weatherDataService.searchCities(query, callback)
    }
    
    // 添加城市到最近访问
    function addCityToRecent(cityData) {
        if (appStateManager && cityData) {
            appStateManager.addToRecentCities(cityData)
        }
    }
    
    // 切换视图模式
    function switchViewMode(viewMode) {
        if (appStateManager) {
            appStateManager.setViewMode(viewMode)
        }
    }
    
    // 切换到下一个城市
    function switchToNextCity() {
        if (appStateManager) {
            appStateManager.switchToNext()
        }
    }
    
    // 切换到上一个城市
    function switchToPreviousCity() {
        if (appStateManager) {
            appStateManager.switchToPrevious()
        }
    }
    
    // 切换到指定城市
    function switchToCity(index) {
        if (appStateManager) {
            appStateManager.switchToCity(index)
        }
    }
    
    // 获取当前城市数据
    function getCurrentCityData() {
        return appStateManager ? appStateManager.getCurrentCityForView() : null
    }
    
    // 获取最近城市列表
    function getRecentCities() {
        return appStateManager ? appStateManager.recentCities : []
    }
    
    // 获取当前城市索引
    function getCurrentCityIndex() {
        return appStateManager ? appStateManager.currentCityIndex : 0
    }
    
    // 获取最大城市数量
    function getMaxCities() {
        return appStateManager ? appStateManager.maxCities : 3
    }
    
    // 私有方法：设置加载状态
    function setLoading(loading) {
        if (isLoading !== loading) {
            isLoading = loading
            loadingStateChanged(loading)
        }
    }
    
    // 私有方法：设置错误信息
    function setError(error) {
        errorMessage = error
        errorOccurred(error)
    }
    
    // 私有方法：清除错误
    function clearError() {
        if (errorMessage !== "") {
            errorMessage = ""
        }
    }
    
    // 事件处理：城市变化
    function onCityChanged(cityData) {
        currentWeatherData = cityData
        weatherDataChanged(cityData)
    }
    
    // 事件处理：视图模式变化
    function onViewModeChanged(viewMode) {
        // 视图模式变化时，重新获取当前城市数据
        var cityData = getCurrentCityData()
        if (cityData) {
            currentWeatherData = cityData
            weatherDataChanged(cityData)
        }
    }
    
    // 事件处理：数据加载完成
    function onDataLoaded(data) {
        setLoading(false)
        clearError()
    }
    
    // 事件处理：数据加载错误
    function onDataLoadError(error) {
        setLoading(false)
        setError(error)
    }
    
    // 验证数据
    function validateWeatherData(data) {
        return data && data.cityName && data.temperature
    }
    
    // 格式化温度显示
    function formatTemperature(temp) {
        if (!temp) return "--°C"
        return temp.toString().includes("°C") ? temp : temp + "°C"
    }
    
    // 格式化天气描述
    function formatWeatherDescription(desc) {
        return desc || "未知"
    }
    
    // 清理资源
    function cleanup() {
        if (appStateManager) {
            appStateManager.cityChanged.disconnect(onCityChanged)
            appStateManager.viewModeChanged.disconnect(onViewModeChanged)
        }
        
        weatherDataService.dataLoaded.disconnect(onDataLoaded)
        weatherDataService.dataLoadError.disconnect(onDataLoadError)
    }
}