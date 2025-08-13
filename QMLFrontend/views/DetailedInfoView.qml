import QtQuick
import "../components"
import "../animations"

Rectangle {
    id: detailedInfoView
    color: "transparent"
    
    // 数据属性
    property var weatherData: {
        "cityName": "北京",
        "humidity": "65%",
        "windSpeed": "12km/h",
        "rainfall": "0mm",
        "airQuality": "良好",
        "airPressure": "1013hPa",
        "uvIndex": "5"
    }
    
    // 添加数据更新函数
    function updateCityData(cityData) {
        if (cityData && cityData.detailedInfo) {
            weatherData = {
                "cityName": cityData.cityName || "暂无城市",
                "humidity": cityData.detailedInfo.humidity || "--",
                "windSpeed": cityData.detailedInfo.windSpeed || "--",
                "rainfall": cityData.detailedInfo.rainfall || "--",
                "airQuality": cityData.detailedInfo.airQuality || "--",
                "airPressure": cityData.detailedInfo.airPressure || "--",
                "uvIndex": cityData.detailedInfo.uvIndex || "--"
            }
        } else if (cityData) {
            weatherData.cityName = cityData.cityName || "暂无城市"
        }
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