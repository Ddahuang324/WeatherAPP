// AppStateManager.qml - 全局状态管理器
import QtQuick

QtObject {
    id: appStateManager
    
    // 单例模式
    property bool _initialized: false
    
    // 当前状态
    property var currentCity: null
    property string currentViewMode: "today_weather"
    property var recentCities: []
    property int currentCityIndex: 0
    property int maxCities: 3
    
    // 天气数据
    property var weatherData: ({})
    
    // 信号
    signal cityChanged(var cityData)
    signal viewModeChanged(string viewMode)
    signal citiesListChanged()
    signal weatherDataUpdated(var data)
    
    // 初始化
    function initialize() {
        if (_initialized) return
        
        // 加载示例数据
        loadSampleData()
        _initialized = true
        console.log("AppStateManager initialized")
    }
    
    // 设置当前城市
    function setCurrentCity(cityData) {
        if (!cityData) return
        
        currentCity = cityData
        addToRecentCities(cityData)
        cityChanged(getCurrentCityForView())
    }
    
    // 切换视图模式
    function setViewMode(viewMode) {
        if (currentViewMode !== viewMode) {
            currentViewMode = viewMode
            viewModeChanged(viewMode)
            // 重新发送当前城市数据以适应新视图
            if (currentCity) {
                cityChanged(getCurrentCityForView())
            }
        }
    }
    
    // 添加城市到最近访问列表
    function addToRecentCities(cityData) {
        if (!cityData || !cityData.cityName) return
        
        var newCities = recentCities.slice()
        
        // 检查是否已存在
        var existingIndex = -1
        for (var i = 0; i < newCities.length; i++) {
            if (newCities[i].cityName === cityData.cityName) {
                existingIndex = i
                break
            }
        }
        
        // 移除已存在的
        if (existingIndex >= 0) {
            newCities.splice(existingIndex, 1)
        }
        
        // 添加到最前面
        newCities.unshift(cityData)
        
        // 保持最多maxCities个
        if (newCities.length > maxCities) {
            newCities = newCities.slice(0, maxCities)
        }
        
        recentCities = newCities
        currentCityIndex = 0
        citiesListChanged()
    }
    
    // 切换到指定索引的城市
    function switchToCity(index) {
        if (index >= 0 && index < recentCities.length && index !== currentCityIndex) {
            currentCityIndex = index
            currentCity = recentCities[index]
            cityChanged(getCurrentCityForView())
        }
    }
    
    // 切换到下一个城市
    function switchToNext() {
        if (recentCities.length > 0) {
            var newIndex = (currentCityIndex + 1) % recentCities.length
            switchToCity(newIndex)
        }
    }
    
    // 切换到上一个城市
    function switchToPrevious() {
        if (recentCities.length > 0) {
            var newIndex = (currentCityIndex - 1 + recentCities.length) % recentCities.length
            switchToCity(newIndex)
        }
    }
    
    // 获取当前视图模式下的城市数据
    function getCurrentCityForView() {
        if (!currentCity) return null
        
        var baseData = JSON.parse(JSON.stringify(currentCity))
        baseData.viewMode = currentViewMode
        
        // 根据视图模式添加额外数据
        switch(currentViewMode) {
            case "temperature_trend":
                baseData.weeklyForecast = getWeeklyForecast(currentCity.cityName)
                break
            case "detailed_info":
                baseData.detailedInfo = getDetailedInfo(currentCity.cityName)
                break
            case "sunrise_sunset":
                baseData.sunriseInfo = getSunriseInfo(currentCity.cityName)
                break
        }
        
        return baseData
    }
    
    // 获取周天气预报数据（模拟）
    function getWeeklyForecast(cityName) {
        return {
            recentDaysName: ["今天", "明天", "后天", "周四", "周五", "周六", "周日"],
            recentDaysMaxMinTempreture: [
                "22°C / 12°C", "25°C / 15°C", "20°C / 10°C",
                "18°C / 8°C", "23°C / 13°C", "26°C / 16°C", "24°C / 14°C"
            ],
            recentDaysWeatherDescriptionIcon: ["☀️", "⛅", "🌧️", "☀️", "🌤️", "☀️", "⛅"]
        }
    }
    
    // 获取详细信息数据（模拟）
    function getDetailedInfo(cityName) {
        return {
            humidity: "65%",
            windSpeed: "12km/h",
            rainfall: "0mm",
            airQuality: "良好",
            airPressure: "1013hPa",
            uvIndex: "5"
        }
    }
    
    // 获取日出日落信息（模拟）
    function getSunriseInfo(cityName) {
        return {
            sunrise: "06:30",
            sunset: "18:45",
            dayLength: "12小时15分钟"
        }
    }
    
    // 加载示例数据
    function loadSampleData() {
        var sampleCities = [
            {
                cityName: "北京",
                temperature: "25°C",
                weatherIcon: "☀️",
                weatherDescription: "晴",
                maxMinTemp: "28°C / 18°C"
            },
            {
                cityName: "上海",
                temperature: "22°C",
                weatherIcon: "🌤️",
                weatherDescription: "多云",
                maxMinTemp: "25°C / 19°C"
            },
            {
                cityName: "广州",
                temperature: "28°C",
                weatherIcon: "🌦️",
                weatherDescription: "小雨",
                maxMinTemp: "30°C / 24°C"
            }
        ]
        
        recentCities = sampleCities
        currentCityIndex = 0
        currentCity = sampleCities[0]
        citiesListChanged()
    }
    
    // 组件完成时初始化
    Component.onCompleted: {
        initialize()
    }
}