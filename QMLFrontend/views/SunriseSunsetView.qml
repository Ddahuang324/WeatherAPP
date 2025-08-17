import QtQuick
import "../components"
import "../animations"
import "../views"

BaseView {
    id: sunriseSunsetView
    
    // 视图标识
    viewId: "sunrise_sunset"
    viewName: "日出日落"
    
    // 当前时间属性
    property string currentTime: getCurrentTime()
    
    // 使用新的日出日落组件
    SunsetSunriseitem {
        anchors.centerIn: parent
        sunriseTime: sunriseSunsetView.weatherData && sunriseSunsetView.weatherData.sunriseInfo ? 
                    sunriseSunsetView.weatherData.sunriseInfo.sunrise : "--:--"
        sunsetTime: sunriseSunsetView.weatherData && sunriseSunsetView.weatherData.sunriseInfo ? 
                   sunriseSunsetView.weatherData.sunriseInfo.sunset : "--:--"
        currentTime: sunriseSunsetView.currentTime
    }
    
    // 定时器更新当前时间
    Timer {
        interval: 60000 // 每分钟更新一次
        running: true
        repeat: true
        onTriggered: {
            currentTime = getCurrentTime()
        }
    }
    
    // 获取当前时间
    function getCurrentTime() {
        var now = new Date()
        return now.getHours().toString().padStart(2, '0') + ":" + now.getMinutes().toString().padStart(2, '0')
    }
    
    // 重写数据更新函数
    function updateCityData(data) {
        weatherData = data
        if (data) {
            setLoading(false)
            setError("")
        }
    }
    
    // 视图激活时的处理
    function onViewActivated() {
        console.log("Sunrise Sunset View activated")
        currentTime = getCurrentTime() // 激活时立即更新时间
        if (viewModel) {
            viewModel.loadWeatherData()
        }
    }
    
    // 视图失活时的处理
    function onViewDeactivated() {
        console.log("Sunrise Sunset View deactivated")
    }
}