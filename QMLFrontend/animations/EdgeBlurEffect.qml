// EdgeBlurEffect.qml - 边缘模糊阴影效果组件
import QtQuick

Item {
    id: edgeBlurEffect
    
    // 可配置属性
    property bool enableTop: true
    property bool enableBottom: true
    property bool enableLeft: true
    property bool enableRight: true
    
    property real topHeight: 40
    property real bottomHeight: 40
    property real leftWidth: 40
    property real rightWidth: 40
    
    property color shadowColor: Qt.rgba(0, 0, 0, 0.1)
    property real shadowOpacity: 1.0
    
    // 上边缘模糊效果
    Rectangle {
        visible: edgeBlurEffect.enableTop
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: edgeBlurEffect.topHeight
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(edgeBlurEffect.shadowColor.r, edgeBlurEffect.shadowColor.g, edgeBlurEffect.shadowColor.b, edgeBlurEffect.shadowColor.a * edgeBlurEffect.shadowOpacity) }
            GradientStop { position: 1.0; color: Qt.rgba(edgeBlurEffect.shadowColor.r, edgeBlurEffect.shadowColor.g, edgeBlurEffect.shadowColor.b, 0) }
        }
    }
    
    // 下边缘模糊效果
    Rectangle {
        visible: edgeBlurEffect.enableBottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: edgeBlurEffect.bottomHeight
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(edgeBlurEffect.shadowColor.r, edgeBlurEffect.shadowColor.g, edgeBlurEffect.shadowColor.b, 0) }
            GradientStop { position: 1.0; color: Qt.rgba(edgeBlurEffect.shadowColor.r, edgeBlurEffect.shadowColor.g, edgeBlurEffect.shadowColor.b, edgeBlurEffect.shadowColor.a * edgeBlurEffect.shadowOpacity) }
        }
    }
    
    // 左边缘模糊效果
    Rectangle {
        visible: edgeBlurEffect.enableLeft
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: edgeBlurEffect.leftWidth
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(edgeBlurEffect.shadowColor.r, edgeBlurEffect.shadowColor.g, edgeBlurEffect.shadowColor.b, edgeBlurEffect.shadowColor.a * edgeBlurEffect.shadowOpacity) }
            GradientStop { position: 1.0; color: Qt.rgba(edgeBlurEffect.shadowColor.r, edgeBlurEffect.shadowColor.g, edgeBlurEffect.shadowColor.b, 0) }
        }
    }
    
    // 右边缘模糊效果
    Rectangle {
        visible: edgeBlurEffect.enableRight
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: edgeBlurEffect.rightWidth
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(edgeBlurEffect.shadowColor.r, edgeBlurEffect.shadowColor.g, edgeBlurEffect.shadowColor.b, 0) }
            GradientStop { position: 1.0; color: Qt.rgba(edgeBlurEffect.shadowColor.r, edgeBlurEffect.shadowColor.g, edgeBlurEffect.shadowColor.b, edgeBlurEffect.shadowColor.a * edgeBlurEffect.shadowOpacity) }
        }
    }
}