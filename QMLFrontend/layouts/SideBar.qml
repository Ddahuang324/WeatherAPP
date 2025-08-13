// SideBar.qml
import QtQuick
import QtQuick.Controls
import "../animations"
import "../components"

Rectangle {
    id: sidebar
    width: Math.max(150, Math.min(250, parent.width * 0.15))
    height: parent.height
    color: "transparent" // 自身透明
    
    // 背景源属性
    property Item backgroundSource: null

    // 侧边栏样式
    SidebarStyle {
        anchors.fill: parent
        blurSource: sidebar.backgroundSource
    }

    // 窗口控制按钮区域
    WindowControls {
        id: windowControls
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 20
        z: 10
    }
    
    // 搜索栏区域
    SearchBar {
        id: searchArea
        anchors.top: windowControls.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 50
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        
        onSearchRequested: function(searchText) {
            console.log("搜索:", searchText)
            // TODO: 实现搜索功能
        }
    }

    // 功能项
    NavigationMenu {
        id: functionItems
        anchors.bottom: parent.bottom
        anchors.left: parent.left 
        anchors.right: parent.right 
        anchors.bottomMargin: 100
        
        onMenuItemClicked: function(itemId) {
            console.log("点击菜单项:", itemId)
            // 通知父组件切换视图
            sidebar.viewChangeRequested(itemId)
        }
    }

    // 视图切换请求信号
    signal viewChangeRequested(string viewName)


    // 拖拽区域（用于移动窗口）
    DragArea {
        id: dragArea
        anchors.fill: parent
        anchors.topMargin: 100 // 避免与窗口控制按钮和搜索栏冲突
        anchors.bottomMargin: 200  // 避免与功能按钮区域冲突
    }

}