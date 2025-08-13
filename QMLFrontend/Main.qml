import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import "layouts"
import "models"
import "viewmodels"
import "services"

ApplicationWindow {
    id: window
    width: 1080
    height: 800
    visible: true
    title: qsTr("Weather App")
    flags: Qt.Window | Qt.FramelessWindowHint
    minimumHeight : 600
    minimumWidth :800
    
    // 全局状态管理器
    AppStateManager {
        id: appStateManager
    }
    
    // 天气视图模型
    WeatherViewModel {
        id: weatherViewModel
        Component.onCompleted: {
            initialize(appStateManager)
        }
    }
    
    // 导航视图模型
    NavigationViewModel {
        id: navigationViewModel
        Component.onCompleted: {
            initialize(appStateManager)
        }
    }
    
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
            height: parent.height
            backgroundSource: backgroundItem
            
            // 使用导航视图模型
            navigationViewModel: navigationViewModel
            weatherViewModel: weatherViewModel
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
                
                // 使用视图模型
                navigationViewModel: navigationViewModel
                weatherViewModel: weatherViewModel
            }
            
            // 下方最近城市分页器
            RecentCitiesPager {
                id: recentCitiesPager
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                backgroundSource: backgroundItem
                
                // 传递weatherViewModel给城市管理器
                Component.onCompleted: {
                    citiesManager.weatherViewModel = weatherViewModel
                }
            }
        }
    }
    
    // 全局键盘事件处理
    Keys.onPressed: function(event) {
        switch(event.key) {
            case Qt.Key_Left:
                weatherViewModel.switchToPreviousCity()
                event.accepted = true
                break
            case Qt.Key_Right:
                weatherViewModel.switchToNextCity()
                event.accepted = true
                break
            case Qt.Key_Up:
                navigationViewModel.navigateToPrevious()
                event.accepted = true
                break
            case Qt.Key_Down:
                navigationViewModel.navigateToNext()
                event.accepted = true
                break
        }
    }
}
