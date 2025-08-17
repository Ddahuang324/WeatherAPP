import QtQuick
import QtQuick.Controls
import "../" as Components


Rectangle {
    id : todayWeatherItem
    width : parent.width
    height : 100
    radius : 10
    color : "transparent"

    property string cityName : "北京"
    property string currentTempreture : "25°C"
    property string weatherDescriptionIcon : "☀️"
    property string weatherDescription : "晴"
    property string maxMinTempreture : "25°C / 20°C"

    //主要内容区域 - 参考温度趋势布局
    Column{
        width: parent.width - 40
        height: parent.height - 40
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        spacing: 20

        //复用组件：城市名称
        Components.CityNameLabel{
            id:cityNameComponent
            cityName : todayWeatherItem.cityName
            fontSize : 50
            font.bold : true
            anchors.left: undefined
            anchors.top: undefined
        }

        //当前温度
        Text{
            id:currentTempretureText
            text : todayWeatherItem.currentTempreture
            font.pixelSize : 170
            font.bold : true
            color: Qt.rgba(1, 1, 1, 0.8)
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        //当前最高/最低气温
        Text{
            id: maxMinTempretureText
            text : todayWeatherItem.maxMinTempreture
            font.pixelSize : 70
            font.bold : true
            color : "white"
            anchors.horizontalCenter : parent.horizontalCenter
        }
        
        //天气状况
        Row{
            id: weatherDescriptionRow
            anchors.horizontalCenter : parent.horizontalCenter
            spacing: 10
            //Icon
            Text{
                text : todayWeatherItem.weatherDescriptionIcon
                font.pixelSize : 60
                font.bold : true
            }
            //文本描述
            Text{
                text : todayWeatherItem.weatherDescription
                font.pixelSize : 70
                font.bold : true
                color: Qt.rgba(1, 1, 1, 0.8)
            }
        }
    }
}

