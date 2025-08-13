import QtQuick
import QtQuick.Controls

Label {
    id: cityNameLabel
    
    // 可配置的属性
    property string cityName: "北京"
    property int fontSize: 30
    property bool isBold: true
    property color textColor: "white"
    property int leftMargin: 40
    property int topMargin: 20
    
    // 基本属性设置
    text: cityName
    font.pixelSize: fontSize
    font.bold: isBold
    color: textColor
    
    // 默认定位（可以被父组件覆盖）
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.leftMargin: leftMargin
    anchors.topMargin: topMargin
}