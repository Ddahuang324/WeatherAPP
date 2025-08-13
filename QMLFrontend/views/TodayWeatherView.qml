import QtQuick
import QtQuick.Controls
import "../components" as Components
import "../animations"

Rectangle{
    color: "transparent"
    
    // 添加数据更新函数
    function updateCityData(cityData) {
        if (cityData) {
            todaysWeatherItem.cityName = cityData.cityName || "暂无城市"
            todaysWeatherItem.currentTempreture = cityData.temperature || "--°C"
            todaysWeatherItem.weatherDescriptionIcon = cityData.weatherIcon || "🌤️"
            todaysWeatherItem.weatherDescription = cityData.weatherDescription || "未知"
            todaysWeatherItem.maxMinTempreture = cityData.maxMinTemp || "--°C / --°C"
        }
    }
    
    Column {
        id: todayWeatherColumn
        anchors.fill: parent
        spacing: 20

        //城市天气
        Components.TodaysWeatherItem {
            id: todaysWeatherItem
            cityName: "北京"
            currentTempreture: "25°C"
            weatherDescriptionIcon: "☀️"
            weatherDescription: "晴"
            maxMinTempreture: "25°C / 20°C"
        }
    }
}