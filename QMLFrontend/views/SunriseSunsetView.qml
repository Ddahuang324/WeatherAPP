import QtQuick
import "../components"
import "../animations"

Rectangle {
    id: sunriseSunsetView
    color: "transparent"
    
    // 使用新的日出日落组件
    SunsetSunriseitem {
        anchors.centerIn: parent
        sunriseTime: "06:30"
        sunsetTime: "18:45"
        currentTime: "12:30"
    }
    
    // 拖拽区域
    DragArea {
        anchors.fill: parent
    }
}