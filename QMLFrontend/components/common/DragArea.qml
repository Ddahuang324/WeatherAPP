// DragArea.qml - 窗口拖拽区域组件
import QtQuick

MouseArea {
    id: dragArea
    
    property point lastMousePos: Qt.point(0, 0)
    property bool enableDrag: true
    
    onPressed: function(mouse) {
        if (enableDrag) {
            lastMousePos = Qt.point(mouse.x, mouse.y)
        }
    }
    
    onPositionChanged: function(mouse) {
        if (pressed && enableDrag) {
            var deltaX = mouse.x - lastMousePos.x
            var deltaY = mouse.y - lastMousePos.y
            dragArea.Window.window.x += deltaX
            dragArea.Window.window.y += deltaY
        }
    }
    
    // 设置鼠标样式
    cursorShape: enableDrag ? (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : Qt.ArrowCursor
    
    // 防止与其他交互元素冲突
    propagateComposedEvents: true
    
    onClicked: function(mouse) {
        mouse.accepted = false
    }
}