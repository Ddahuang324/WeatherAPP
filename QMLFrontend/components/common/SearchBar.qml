// SearchBar.qml - 搜索栏组件
import QtQuick
import QtQuick.Controls

Rectangle {
    id: searchBar
    height: 40
    radius: 10
    color: Qt.rgba(1.0, 1.0, 1.0, 0.2) // 浅白色20%透明度
    
    // 搜索事件信号
    signal searchRequested(string searchText)
    
    Row {
        anchors.fill: parent
        anchors.margins: 2
        spacing: 0

        // 搜索按钮
        Rectangle {
            id: searchButton
            width: 40
            height: parent.height
            radius: 8
            color: "transparent"
            
            // 搜索图标
            Text {
                anchors.centerIn: parent
                text: "🔍"
                font.pixelSize: 16
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    searchBar.searchRequested(searchText.text)
                }
            }
        }
        
        // 搜索文本框
        TextField {
            id: searchText
            width: parent.width - searchButton.width
            height: parent.height
            placeholderText: "搜索城市..."
            font.pointSize: 18
            
            background: Rectangle {
                radius: 8
                color: searchText.hovered ? Qt.rgba(0.2, 0.2, 0.2, 0.1) : "transparent"
            }
            
            leftPadding: 8
            rightPadding: 8
            
            // 回车键搜索
            onAccepted: {
                searchBar.searchRequested(text)
            }
        }
    }
}