// RecentCitiesPagerStyle.qml - 最近城市分页器专用样式组件
import QtQuick

Item {
    id: pagerStyle
    
    // 可配置属性
    property Item blurSource: null
    property real blurRadius: 32
    property color glassColor: Qt.rgba(1.0, 1.0, 1.0, 0.02) // 更加极简的半透明
    property color borderColor: Qt.rgba(1.0, 1.0, 1.0, 0.04)
    property real cornerRadius: 20
    property color shadowColor: Qt.rgba(0, 0, 0, 0.02)
    property real shadowSize: 40
    
    // 玻璃模糊效果
    GlassEffect {
        anchors.fill: parent
        blurSource: pagerStyle.blurSource
        blurRadius: pagerStyle.blurRadius
        glassColor: pagerStyle.glassColor
        borderColor: pagerStyle.borderColor
        cornerRadius: pagerStyle.cornerRadius
    }
    
    // 边缘模糊效果
    EdgeBlurEffect {
        anchors.fill: parent
        enableLeft: true
        enableTop: true
        enableBottom: true
        enableRight: true
        topHeight: pagerStyle.shadowSize
        bottomHeight: pagerStyle.shadowSize
        leftWidth: pagerStyle.shadowSize
        rightWidth: pagerStyle.shadowSize
        shadowColor: pagerStyle.shadowColor
    }
}