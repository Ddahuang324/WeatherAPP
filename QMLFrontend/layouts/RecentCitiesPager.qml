// RecentCitiesPager.qml
import QtQuick
import "../animations"
import "../components"

Rectangle {
    id: recentCitiesPager
    width: parent.width
    height: 90
    color: "transparent" // 自身必须透明，才能看到后面的模糊效果
    
    // 背景源属性
    property Item backgroundSource: null
    
    // 分页器样式
    RecentCitiesPagerStyle {
        anchors.fill: parent
        blurSource: recentCitiesPager.backgroundSource
    }

    // 拖拽区域（用于移动窗口）
    DragArea {
        id: dragArea
        anchors.fill: parent
    }
}