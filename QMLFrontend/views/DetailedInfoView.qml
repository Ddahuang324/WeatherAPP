import QtQuick
import "../components"
import "../animations"

Rectangle {
    id: weeklyForecastView
    color: "transparent"
    
    // 一周预报视图内容
    Column {
        anchors.centerIn: parent
        spacing: 20
        
        Text {
            text: "一周预报"
            font.pixelSize: 24
            font.bold: true
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // 预报列表区域
        Rectangle {
            width: 450
            height: 300
            color: "transparent"
            border.color: "white"
            border.width: 1
            radius: 10
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10
                
                // 表头
                Row {
                    width: parent.width
                    spacing: 10
                    
                    Text {
                        text: "日期"
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                        width: 80
                    }
                    
                    Text {
                        text: "天气"
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                        width: 100
                    }
                    
                    Text {
                        text: "最高/最低温"
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                        width: 120
                    }
                }
                
                // 分隔线
                Rectangle {
                    width: parent.width
                    height: 1
                    color: "lightgray"
                }
                
                // 天气数据
                Repeater {
                    model: [
                        {"day": "今天", "weather": "晴天", "temp": "25°/15°"},
                        {"day": "明天", "weather": "多云", "temp": "23°/13°"},
                        {"day": "后天", "weather": "小雨", "temp": "20°/12°"},
                        {"day": "周四", "weather": "阴天", "temp": "22°/14°"},
                        {"day": "周五", "weather": "晴天", "temp": "26°/16°"},
                        {"day": "周六", "weather": "多云", "temp": "24°/15°"},
                        {"day": "周日", "weather": "晴天", "temp": "27°/17°"}
                    ]
                    
                    Row {
                        width: parent.width
                        spacing: 10
                        
                        Text {
                            text: modelData.day
                            font.pixelSize: 12
                            color: "white"
                            width: 80
                        }
                        
                        Text {
                            text: modelData.weather
                            font.pixelSize: 12
                            color: "lightblue"
                            width: 100
                        }
                        
                        Text {
                            text: modelData.temp
                            font.pixelSize: 12
                            color: "white"
                            width: 120
                        }
                    }
                }
            }
        }
    }
    
    // 拖拽区域
    DragArea {
        anchors.fill: parent
    }
}