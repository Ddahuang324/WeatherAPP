import QtQuick
import QtQuick.Controls
import "../components" as Components
import "../animations"

Rectangle{
    color: "transparent"
    
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