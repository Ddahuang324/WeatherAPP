import QtQuick
import "../components"
import "../animations"
import "../views"

BaseView {
    id: todayWeatherView
    
    // 视图标识
    viewId: "today_weather"
    viewName: "今日天气"
    
    // 今日天气组件
    TodaysWeatherItem {
        id: weatherItem
        anchors.fill: parent
        anchors.margins: 20
        
        // 绑定数据
        cityName: todayWeatherView.weatherData ? todayWeatherView.weatherData.cityName : "暂无城市"
        currentTempreture: todayWeatherView.weatherData ? todayWeatherView.weatherData.temperature : "--°C"
        weatherDescriptionIcon: todayWeatherView.weatherData ? todayWeatherView.weatherData.weatherIcon : "🌤️"
        weatherDescription: todayWeatherView.weatherData ? todayWeatherView.weatherData.weatherDescription : "未知"
        maxMinTempreture: todayWeatherView.weatherData ? todayWeatherView.weatherData.maxMinTemp : "--°C / --°C"
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
        console.log("Today Weather View activated")
        if (viewModel) {
            viewModel.loadWeatherData()
        }
    }
    
    // 视图失活时的处理
    function onViewDeactivated() {
        console.log("Today Weather View deactivated")
    }
}