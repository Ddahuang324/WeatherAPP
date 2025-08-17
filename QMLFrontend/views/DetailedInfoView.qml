import QtQuick
import "../components"
import "../animations"
import "../views"

BaseView {
    id: detailedInfoView
    
    // 视图标识
    viewId: "detailed_info"
    viewName: "详细信息"
    
    // 详细信息组件
    DetailedInfoItem {
        id: detailItem
        anchors.centerIn: parent
        
        // 绑定数据
        cityName: detailedInfoView.weatherData ? detailedInfoView.weatherData.cityName : "暂无城市"
        cityHumidity: detailedInfoView.weatherData && detailedInfoView.weatherData.detailedInfo ? 
                 detailedInfoView.weatherData.detailedInfo.humidity : "--"
        cityWind: detailedInfoView.weatherData && detailedInfoView.weatherData.detailedInfo ? 
                  detailedInfoView.weatherData.detailedInfo.windSpeed : "--"
        cityRain: detailedInfoView.weatherData && detailedInfoView.weatherData.detailedInfo ? 
                 detailedInfoView.weatherData.detailedInfo.rainfall : "--"
        cityAirQuality: detailedInfoView.weatherData && detailedInfoView.weatherData.detailedInfo ? 
                   detailedInfoView.weatherData.detailedInfo.airQuality : "--"
        cityAirPressure: detailedInfoView.weatherData && detailedInfoView.weatherData.detailedInfo ? 
                    detailedInfoView.weatherData.detailedInfo.airPressure : "--"
        cityUVI: detailedInfoView.weatherData && detailedInfoView.weatherData.detailedInfo ? 
                detailedInfoView.weatherData.detailedInfo.uvIndex : "--"
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
        console.log("Detailed Info View activated")
        if (viewModel) {
            viewModel.loadWeatherData()
        }
    }
    
    // 视图失活时的处理
    function onViewDeactivated() {
        console.log("Detailed Info View deactivated")
    }
}