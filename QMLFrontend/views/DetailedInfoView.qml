import QtQuick
import "../components"
import "../animations"

Rectangle {
    id: detailedInfoView
    color: "transparent"
    
    // 模拟后端数据
    property var weatherData: {
        "cityName": "北京",
        "humidity": "65%",
        "windSpeed": "12km/h",
        "rainfall": "0mm",
        "airQuality": "良好",
        "airPressure": "1013hPa",
        "uvIndex": "5"
    }
    
    // 详细信息视图内容
     DetailedInfoItem {
         id: detailedInfoItem
         anchors.fill: parent
         
         // 传递模拟数据到组件
         cityName: weatherData.cityName
         cityHumidity: weatherData.humidity
         cityWind: weatherData.windSpeed
         cityRain: weatherData.rainfall
         cityAirQuality: weatherData.airQuality
         cityAirPressure: weatherData.airPressure
         cityUVI: weatherData.uvIndex
     }
    
    // 拖拽区域
    DragArea {
        anchors.fill: parent
    }
}