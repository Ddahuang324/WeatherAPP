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
    
    // 视图模型依赖
    property var navigationViewModel: null
    property var weatherViewModel: null

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
            if (weatherViewModel) {
                // 直接调用搜索，结果将通过weatherDataChanged信号处理
                weatherViewModel.searchCities(searchText)
            }
        }
    }

    // 功能项
    NavigationMenu {
        id: functionItems
        anchors.bottom: parent.bottom
        anchors.left: parent.left 
        anchors.right: parent.right 
        anchors.bottomMargin: 100
        
        // 当前选中的视图
        currentView: navigationViewModel ? navigationViewModel.currentView : "today_weather"
        
        onMenuItemClicked: function(itemId) {
            console.log("点击菜单项:", itemId)
            if (navigationViewModel) {
                navigationViewModel.navigateToView(itemId)
            }
        }
    }

    // 拖拽区域（用于移动窗口）
    DragArea {
        id: dragArea
        anchors.fill: parent
        anchors.topMargin: 100 // 避免与窗口控制按钮和搜索栏冲突
        anchors.bottomMargin: 200  // 避免与功能按钮区域冲突
    }
    
    // 监听导航变化
    Connections {
        target: navigationViewModel
        function onViewChanged(viewId) {
            console.log("SideBar: 视图已切换到", viewId)
        }
    }
    
    // 监听搜索结果
    Connections {
        target: weatherViewModel
        onSearchResultsReady: {
            console.log("搜索结果数量:", results.length)
            if (results.length > 0) {
                var firstResult = results[0]
                // 检查是否是错误信息
                if (firstResult.error) {
                    console.log("搜索错误:", firstResult.error)
                    return
                }
                
                // 检查城市数据是否有效
                if (firstResult.fullName || firstResult.name) {
                    console.log("第一个城市的完整名称:", firstResult.fullName || firstResult.name)
                    // 使用第一个搜索结果获取天气信息
                    weatherViewModel.loadCityWeather(firstResult.fullName || firstResult.name)
                } else {
                    console.log("城市数据无效")
                }
            } else {
                console.log("未找到搜索结果")
            }
        }
    }
}