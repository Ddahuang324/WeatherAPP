import QtQuick
import "../components"
import "../animations"

Rectangle {
    id: sunriseSunsetView
    color: "transparent"
    
    // 数据属性
    property string cityName: "北京"
    property string sunriseTime: "06:30"
    property string sunsetTime: "18:45"
    property string currentTime: "12:30"
    
    // 添加数据更新函数
    function updateCityData(cityData) {
        if (cityData && cityData.sunriseInfo) {
            cityName = cityData.cityName || "暂无城市"
            sunriseTime = cityData.sunriseInfo.sunrise || "--:--"
            sunsetTime = cityData.sunriseInfo.sunset || "--:--"
            // currentTime 可以从系统时间获取或从数据中获取
            var now = new Date()
            currentTime = now.getHours().toString().padStart(2, '0') + ":" + now.getMinutes().toString().padStart(2, '0')
        } else if (cityData) {
            cityName = cityData.cityName || "暂无城市"
        }
    }
    
    // 使用新的日出日落组件
    SunsetSunriseitem {
        anchors.centerIn: parent
        sunriseTime: sunriseSunsetView.sunriseTime
        sunsetTime: sunriseSunsetView.sunsetTime
        currentTime: sunriseSunsetView.currentTime
    }
    
    // 拖拽区域
    DragArea {
        anchors.fill: parent
    }
}