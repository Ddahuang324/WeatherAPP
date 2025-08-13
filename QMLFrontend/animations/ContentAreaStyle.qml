// ContentAreaStyle.qml - 内容区域专用样式组件
import QtQuick

Item {
    id: contentStyle
    
    // 可配置属性
    property Item blurSource: null
    property real blurRadius: 48
    property color glassColor: Qt.rgba(1.0, 1.0, 1.0, 0.05) // 极简半透明
    property color borderColor: Qt.rgba(1.0, 1.0, 1.0, 0.08)
    property real cornerRadius: 20
    property color shadowColor: Qt.rgba(0, 0, 0, 0.02)
    property real shadowSize: 30
    
    // 玻璃模糊效果
    GlassEffect {
        anchors.fill: parent
        blurSource: contentStyle.blurSource
        blurRadius: contentStyle.blurRadius
        glassColor: contentStyle.glassColor
        borderColor: contentStyle.borderColor
        cornerRadius: contentStyle.cornerRadius
    }
    
    // 边缘模糊效果
    EdgeBlurEffect {
        anchors.fill: parent
        enableLeft: true
        enableRight: true
        enableTop: true
        enableBottom: true
        topHeight: contentStyle.shadowSize
        bottomHeight: contentStyle.shadowSize
        leftWidth: contentStyle.shadowSize
        rightWidth: contentStyle.shadowSize
        shadowColor: contentStyle.shadowColor
    }
}