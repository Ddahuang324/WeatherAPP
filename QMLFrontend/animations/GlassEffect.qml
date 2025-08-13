// GlassEffect.qml - 玻璃模糊效果组件
import QtQuick
import QtQuick.Effects

Item {
    id: glassEffect
    
    // 可配置属性
    property real blurRadius: 32
    property real blurIntensity: 1.0
    property alias glassColor: glassLayer.color
    property alias borderColor: glassLayer.border.color
    property alias borderWidth: glassLayer.border.width
    property alias cornerRadius: glassLayer.radius
    property Item blurSource: null
    
    // 默认值
    property real defaultBlurRadius: 32
    property real defaultBlurIntensity: 1.0
    property color defaultGlassColor: Qt.rgba(1.0, 1.0, 1.0, 0.02) // 改为透明白色
    property color defaultBorderColor: Qt.rgba(1.0, 1.0, 1.0, 0.2)
    property real defaultBorderWidth: 1
    property real defaultCornerRadius: 20
    
    // 背景模糊效果
    MultiEffect {
        id: multiEffect
        anchors.fill: parent
        source: glassEffect.blurSource
        blur: glassEffect.blurIntensity
        blurMax: glassEffect.blurRadius
    }
    
    // 玻璃着色层
    Rectangle {
        id: glassLayer
        anchors.fill: parent
        color: "transparent"
        border.width: glassEffect.borderWidth || glassEffect.defaultBorderWidth
        border.color: glassEffect.borderColor || glassEffect.defaultBorderColor
        radius: glassEffect.cornerRadius || glassEffect.defaultCornerRadius
    }
}