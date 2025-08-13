// GradientBackground.qml - 渐变背景效果组件
import QtQuick

Rectangle {
    id: gradientBackground
    
    // 可配置属性
    property color startColor: "#38bdf8"  // sky-400
    property color endColor: "#3b82f6"    // blue-500
    property int gradientOrientation: Gradient.Vertical
    property real cornerRadius: 20
    property bool enableTexture: false
    property color textureColor: Qt.rgba(1, 1, 1, 0.02)
    property real textureOpacity: 0.5
    
    color: "transparent"
    radius: cornerRadius
    
    gradient: Gradient {
        orientation: gradientBackground.gradientOrientation
        GradientStop { position: 0.0; color: gradientBackground.startColor }
        GradientStop { position: 1.0; color: gradientBackground.endColor }
    }
    
    // 可选纹理覆盖层
    Rectangle {
        visible: gradientBackground.enableTexture
        anchors.fill: parent
        color: "transparent"
        radius: gradientBackground.cornerRadius
        
        // 微妙的噪点效果
        Rectangle {
            anchors.fill: parent
            color: gradientBackground.textureColor
            opacity: gradientBackground.textureOpacity
            radius: gradientBackground.cornerRadius
        }
    }
}