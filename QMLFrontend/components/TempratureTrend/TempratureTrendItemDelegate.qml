import QtQuick
import QtQuick.Controls

Rectangle {
    id: delegate
    width: 500
    height: 80
    radius: 8
    color: "transparent"
    border.color: Qt.rgba(1, 1, 1, 0.2)
    border.width: 1
    
    property string cityName: ""  // 这里实际存储的是日期信息
    property string maxMinTempreture: ""
    property string weatherDescriptionIcon: ""
    
    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15
        
        // 天气图标
        Rectangle {
            width: 50
            height: 50
            radius: 25
            color: Qt.rgba(1, 1, 1, 0.1)
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                anchors.centerIn: parent
                text: weatherDescriptionIcon || "☀️"
                font.pixelSize: 24
            }
        }
        
        // 日期和温度信息
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5
            
            Text {
                text: cityName || "未知日期"
                font.pixelSize: 16
                font.bold: true
                color: "white"
            }
            
            Text {
                text: maxMinTempreture || "--°C / --°C"
                font.pixelSize: 14
                color: Qt.rgba(1, 1, 1, 0.7)
            }
        }
    }
    
    // 鼠标悬停效果
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            delegate.color = Qt.rgba(1, 1, 1, 0.1)
        }
        
        onExited: {
            delegate.color = "transparent"
        }
        
        onClicked: {
            console.log("Clicked on:", cityName)
        }
    }
}