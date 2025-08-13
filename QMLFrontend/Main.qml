import QtQuick
import QtQuick.Layouts
import "layouts"

Window {
    id: window
    width: 1080
    height: 800
    visible: true
    title: qsTr("Weather App")
    flags: Qt.Window | Qt.FramelessWindowHint
    minimumHeight : 600
    minimumWidth :800
    
    // 背景项，用于模糊效果的源
    Rectangle {
        id: backgroundItem
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#38bdf8" } // 对应 sky-400
            GradientStop { position: 1.0; color: "#3b82f6" } // 对应 blue-500
        }
    }
    Row {
        
        anchors.fill: parent
        
        // 左侧边栏
        SideBar {
            id: sidebar
            height:parent.height
            backgroundSource: backgroundItem
            
            // 连接视图切换信号
            onViewChangeRequested: function(viewName) {
                contentArea.switchView(viewName)
                // 同步视图模式到分页器
                recentCitiesPager.citiesManager.setViewMode(viewName)
            }
        }
        
        // 右侧内容区域
        ColumnLayout {
            width: parent.width - sidebar.width
            height: parent.height
            spacing: 0
            
            // 上方内容区域
            ContentArea {
                id: contentArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                backgroundSource: backgroundItem
            }
            
            // 下方最近城市分页器
            RecentCitiesPager {
                id: recentCitiesPager
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                backgroundSource: backgroundItem
                
                // 连接城市数据变化到ContentArea
                onCityChanged: function(cityData) {
                    contentArea.updateCityData(cityData)
                }
            }
        }
    }
}
