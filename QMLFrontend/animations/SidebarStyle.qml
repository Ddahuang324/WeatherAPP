// SidebarStyle.qml - 侧边栏专用样式组件
import QtQuick

Item {
    id: sidebarStyle
    
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
        blurSource: sidebarStyle.blurSource
        blurRadius: sidebarStyle.blurRadius
        glassColor: sidebarStyle.glassColor
        borderColor: sidebarStyle.borderColor
        cornerRadius: sidebarStyle.cornerRadius
    }
    
    // 边缘模糊效果
    EdgeBlurEffect {
        anchors.fill: parent
        enableLeft: false // 侧边栏左边不需要阴影
        enableTop: true
        enableBottom: true
        enableRight: true
        topHeight: sidebarStyle.shadowSize
        bottomHeight: sidebarStyle.shadowSize
        rightWidth: sidebarStyle.shadowSize
        shadowColor: sidebarStyle.shadowColor
    }
}