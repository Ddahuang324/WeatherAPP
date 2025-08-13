import QtQuick
import "../animations"
import "../components"
import "../views"

Rectangle {
    id: contentArea
    width: parent.width
    height: parent.height
    color: "transparent"
    
    // 背景源属性
    property Item backgroundSource: null
    
    // 数据接收属性
    property var currentCityData: null
    property string currentViewMode: "today_weather"

    // 内容区域样式
    ContentAreaStyle {
        anchors.fill: parent
        blurSource: contentArea.backgroundSource
    }

    // 视图容器
    Loader {
        id: viewLoader
        anchors.fill: parent
        source: "../views/TodayWeatherView.qml" // 默认视图
    }

    // 拖拽区域（用于移动窗口）
    DragArea {
        id: dragArea
        anchors.fill: parent
    }
    
    // 数据更新函数
    function updateCityData(cityData) {
        currentCityData = cityData
        // 通知当前视图更新数据
        if (viewLoader.item && viewLoader.item.updateCityData) {
            viewLoader.item.updateCityData(cityData)
        }
    }
    
    // 视图切换函数
    function switchView(viewName) {
        currentViewMode = viewName
        if (viewName === "today_weather") {
            viewLoader.source = "../views/TodayWeatherView.qml"
        } else if (viewName === "temperature_trend") {
            viewLoader.source = "../views/TemperatureTrendView.qml"
        } else if (viewName === "detailed_info") {
            viewLoader.source = "../views/DetailedInfoView.qml"
        } else if (viewName === "sunrise_sunset") {
            viewLoader.source = "../views/SunriseSunsetView.qml"
        }
        
        // 视图加载完成后立即更新数据
        viewLoader.onLoaded.connect(function() {
            if (currentCityData && viewLoader.item && viewLoader.item.updateCityData) {
                viewLoader.item.updateCityData(currentCityData)
            }
        })
    }
}
