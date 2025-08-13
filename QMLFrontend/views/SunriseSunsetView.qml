import QtQuick
import "../components"
import "../animations"

Rectangle {
    id: sunriseSunsetView
    color: "transparent"
    
    // 日出日落视图内容
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "日出日落"
            font.pixelSize: 24
            font.bold: true
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // 日出日落信息区域
        Rectangle {
            width: 350
            height: 250
            color: "transparent"
            border.color: "white"
            border.width: 1
            radius: 10
            
            Column {
                anchors.centerIn: parent
                spacing: 30
                
                // 日出信息
                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Rectangle {
                        width: 60
                        height: 60
                        color: "orange"
                        radius: 30
                        
                        Text {
                            text: "🌅"
                            font.pixelSize: 30
                            anchors.centerIn: parent
                        }
                    }
                    
                    Column {
                        spacing: 5
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: "日出时间"
                            font.pixelSize: 16
                            color: "white"
                        }
                        
                        Text {
                            text: "06:30"
                            font.pixelSize: 20
                            font.bold: true
                            color: "orange"
                        }
                    }
                }
                
                // 分隔线
                Rectangle {
                    width: 200
                    height: 1
                    color: "lightgray"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                // 日落信息
                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    
                    Rectangle {
                        width: 60
                        height: 60
                        color: "red"
                        radius: 30
                        
                        Text {
                            text: "🌇"
                            font.pixelSize: 30
                            anchors.centerIn: parent
                        }
                    }
                    
                    Column {
                        spacing: 5
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Text {
                            text: "日落时间"
                            font.pixelSize: 16
                            color: "white"
                        }
                        
                        Text {
                            text: "18:45"
                            font.pixelSize: 20
                            font.bold: true
                            color: "red"
                        }
                    }
                }
                
                // 日照时长
                Text {
                    text: "日照时长: 12小时15分钟"
                    font.pixelSize: 14
                    color: "lightgray"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
    
    // 拖拽区域
    DragArea {
        anchors.fill: parent
    }
}