import QtQuick
import QtQuick.Controls

Rectangle {
    id: detailedInfoLabel
    
    // 可配置属性
    property string labelText: "标签"
    property string valueText: "值"
    property string iconText: "📊"
    property int fontSize: 60
    property color textColor: "white"
    property color valueColor: "lightblue"
    property color backgroundColor: Qt.rgba(1.0, 1.0, 1.0, 0.1)
    property color borderColor: Qt.rgba(1.0, 1.0, 1.0, 0.2)
    property real cornerRadius: 10
    
    // 默认尺寸
    width: 80
    height: 80
    
    color: backgroundColor
    radius: cornerRadius
    border.color: borderColor
    border.width: 1
    
    Column {
        anchors.centerIn: parent
        spacing: 5
        
        // 图标
        Text {
            text: detailedInfoLabel.iconText
            font.pixelSize: 50
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // 标签文字
        Text {
            text: detailedInfoLabel.labelText
            font.pixelSize: detailedInfoLabel.fontSize - 2
            color: detailedInfoLabel.textColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
        
        // 数值
        Text {
            text: detailedInfoLabel.valueText
            font.pixelSize: detailedInfoLabel.fontSize
            font.bold: true
            color: detailedInfoLabel.valueColor
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}