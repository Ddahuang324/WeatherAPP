// MenuItem.qml - 导航菜单项组件
import QtQuick

Rectangle {
    id: menuItem
    width: parent.width
    height: 40
    radius: 10
    
    // 可配置属性
    property string iconText: "📱"
    property string labelText: "菜单项"
    property string itemId: ""
    property bool isSelected: false
    property bool isHovered: mouseArea.containsMouse
    
    // 点击事件信号
    signal clicked()
    
    color: isSelected ? Qt.rgba(0.2, 0.4, 0.8, 0.7) : (isHovered ? Qt.rgba(0.3, 0.5, 0.7, 0.5) : Qt.rgba(0.53, 0.81, 0.98, 0.3))
    anchors.horizontalCenter: parent.horizontalCenter
    
    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }

    // 图标和文字的水平布局
    Row {
        anchors.centerIn: parent
        spacing: 8
        
        Text {
            text: menuItem.iconText
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: menuItem.labelText
            font.pixelSize: 14
            color: "#333333"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: menuItem.clicked()
    }
}