import QtQuick
import "../components"
import "../animations"
import "../views"

BaseView {
    id: temperatureTrendView
    
    // 视图标识
    viewId: "temperature_trend"
    viewName: "温度趋势"
    
    // 温度趋势组件
    TempratureTrendItem {
        id: trendItem
        anchors.centerIn: parent
        
        // 绑定数据
        currentCityName: temperatureTrendView.weatherData ? temperatureTrendView.weatherData.cityName : "暂无城市"
        recentDaysName: temperatureTrendView.weatherData && temperatureTrendView.weatherData.weeklyForecast ? 
                       temperatureTrendView.weatherData.weeklyForecast.recentDaysName : []
        recentDaysMaxMinTempreture: temperatureTrendView.weatherData && temperatureTrendView.weatherData.weeklyForecast ? 
                                   temperatureTrendView.weatherData.weeklyForecast.recentDaysMaxMinTempreture : []
        recentDaysWeatherDescriptionIcon: temperatureTrendView.weatherData && temperatureTrendView.weatherData.weeklyForecast ? 
                                         temperatureTrendView.weatherData.weeklyForecast.recentDaysWeatherDescriptionIcon : []
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
        console.log("Temperature Trend View activated")
        if (viewModel) {
            viewModel.loadWeatherData()
        }
    }
    
    // 视图失活时的处理
    function onViewDeactivated() {
        console.log("Temperature Trend View deactivated")
    }
}