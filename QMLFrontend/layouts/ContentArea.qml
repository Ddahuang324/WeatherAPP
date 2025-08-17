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
    
    // 视图模型依赖
    property var navigationViewModel: null
    property var weatherViewModel: null
    
    // 当前状态
    property var currentCityData: null
    property string currentViewMode: "today_weather"

    // 内容区域样式
    ContentAreaStyle {
        anchors.fill: parent
        blurSource: contentArea.backgroundSource
    }

    // 视图容器 - 支持淡入淡出动画
    Item {
        id: viewContainer
        anchors.fill: parent
        
        // 当前视图
        Loader {
            id: currentViewLoader
            anchors.fill: parent
            source: ""
            opacity: 1.0
            z: 1
            
            onLoaded: {
                if (item) {
                    item.viewModel = weatherViewModel
                    if (currentCityData && item.updateCityData) {
                        item.updateCityData(currentCityData)
                    }
                }
            }
        }
        
        // 下一个视图（用于动画过渡）
        Loader {
            id: nextViewLoader
            anchors.fill: parent
            source: ""
            visible: false
            opacity: 0.0
            z: 2
            
            onLoaded: {
                if (item) {
                    item.viewModel = weatherViewModel
                    if (currentCityData && item.updateCityData) {
                        item.updateCityData(currentCityData)
                    }
                }
            }
        }
        
        // 页面切换动画组件
        PageTransition {
            id: pageTransition
            currentView: currentViewLoader
            nextView: nextViewLoader
            
            onTransitionCompleted: {
                // 动画完成后交换视图
                currentViewLoader.source = nextViewLoader.source
                currentViewLoader.opacity = 1.0
                
                // 清理下一个视图
                nextViewLoader.source = ""
                nextViewLoader.visible = false
                nextViewLoader.opacity = 0.0
                
                console.log("Fade transition completed to:", currentViewMode)
            }
        }
    }

    // 拖拽区域（用于移动窗口）
    DragArea {
        id: dragArea
        anchors.fill: parent
    }
    
    // 监听导航变化
    Connections {
        target: navigationViewModel
        function onNavigationRequested(viewId) {
            switchView(viewId)
        }
    }
    
    // 监听天气数据变化
    Connections {
        target: weatherViewModel
        function onWeatherDataChanged(data) {
            updateCityData(data)
        }
    }
    
    // 数据更新函数
    function updateCityData(cityData) {
        currentCityData = cityData
        // 通知当前视图更新数据
        if (currentViewLoader.item && currentViewLoader.item.updateCityData) {
            currentViewLoader.item.updateCityData(cityData)
        }
        // 如果下一个视图也已加载，同样更新数据
        if (nextViewLoader.item && nextViewLoader.item.updateCityData) {
            nextViewLoader.item.updateCityData(cityData)
        }
    }
    
    // 视图切换函数（带淡入淡出动画）
    function switchView(viewName) {
        if (currentViewMode === viewName) return
        if (pageTransition.running) return // 防止动画期间重复切换
        
        var viewPath = getViewPath(viewName)
        if (!viewPath) return
        
        // 如果当前没有视图，直接加载
        if (!currentViewLoader.source) {
            currentViewMode = viewName
            currentViewLoader.source = viewPath
            return
        }
        
        // 准备下一个视图
        currentViewMode = viewName
        nextViewLoader.source = viewPath
        
        // 等待下一个视图加载完成后开始动画
        if (nextViewLoader.status === Loader.Ready) {
            pageTransition.startTransition()
        } else {
            nextViewLoader.onStatusChanged.connect(function() {
                if (nextViewLoader.status === Loader.Ready) {
                    pageTransition.startTransition()
                    nextViewLoader.onStatusChanged.disconnect(arguments.callee)
                }
            })
        }
    }
    
    // 获取视图路径
    function getViewPath(viewName) {
        if (navigationViewModel) {
            return navigationViewModel.getViewPath(viewName)
        }
        
        // 回退到硬编码路径
        var viewPaths = {
            "today_weather": "../views/TodayWeatherView.qml",
            "temperature_trend": "../views/TemperatureTrendView.qml",
            "detailed_info": "../views/DetailedInfoView.qml",
            "sunrise_sunset": "../views/SunriseSunsetView.qml"
        }
        
        return viewPaths[viewName] || viewPaths["today_weather"]
    }
    
    // 初始化
    Component.onCompleted: {
        if (navigationViewModel) {
            currentViewMode = navigationViewModel.currentView
            switchView(currentViewMode)
        }
    }
    
    // 添加便捷的动画控制函数
    function setAnimationDuration(duration) {
        pageTransition.setDuration(duration)
    }
    
    function setAnimationEasing(easingType) {
        pageTransition.setEasingType(easingType)
    }
    
    function setFadeOutDuration(duration) {
        pageTransition.setFadeOutDuration(duration)
    }
    
    function setFadeInDuration(duration) {
        pageTransition.setFadeInDuration(duration)
    }
}
