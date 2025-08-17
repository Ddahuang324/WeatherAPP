// WindowControls.qml - 窗口控制按钮组件
import QtQuick

Row {
    id: windowControls
    spacing: Math.max(8, Math.min(20, parent.width * 0.08))
    
    // 关闭按钮
    Rectangle {
        width: 20
        height: 20
        radius: 10
        color: closeMouseArea.containsMouse ? "#ff5f57" : "#ff5f57"
        border.width: closeMouseArea.containsMouse ? 0 : 1
        border.color: Qt.rgba(0, 0, 0, 0.1)
        
        MouseArea {
            id: closeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Qt.quit()
            cursorShape: Qt.PointingHandCursor
        }
        
        // 关闭图标
        Text {
            anchors.centerIn: parent
            text: "×"
            color: closeMouseArea.containsMouse ? "white" : "transparent"
            font.pixelSize: 8
            font.bold: true
        }
    }
    
    // 最小化按钮
    Rectangle {
        width: 20
        height: 20
        radius: 10
        color: minimizeMouseArea.containsMouse ? "#ffbd2e" : "#ffbd2e"
        border.width: minimizeMouseArea.containsMouse ? 0 : 1
        border.color: Qt.rgba(0, 0, 0, 0.1)
        
        MouseArea {
            id: minimizeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Window.window.showMinimized()
            cursorShape: Qt.PointingHandCursor
        }
        
        // 最小化图标
        Rectangle {
            anchors.centerIn: parent
            width: 6
            height: 1
            color: minimizeMouseArea.containsMouse ? "white" : "transparent"
        }
    }
    
    // 最大化/还原按钮
    Rectangle {
        width: 20
        height: 20
        radius: 10
        color: maximizeMouseArea.containsMouse ? "#28ca42" : "#28ca42"
        border.width: maximizeMouseArea.containsMouse ? 0 : 1
        border.color: Qt.rgba(0, 0, 0, 0.1)
        
        MouseArea {
            id: maximizeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                if (Window.window.visibility === Window.Maximized) {
                    Window.window.showNormal()
                } else {
                    Window.window.showMaximized()
                }
            }
            cursorShape: Qt.PointingHandCursor
        }
        
        // 最大化图标
        Rectangle {
            anchors.centerIn: parent
            width: Window.window.visibility === Window.Maximized ? 4 : 6
            height: Window.window.visibility === Window.Maximized ? 4 : 6
            color: "transparent"
            border.width: 1
            border.color: maximizeMouseArea.containsMouse ? "white" : "transparent"
        }
    }
}