// RecentCitiesManager.qml - 最近城市UI管理器（重构后）
import QtQuick
import "../../animations"

Rectangle {
    id: citiesManager
    width: parent.width
    height: 60
    color: "transparent"
    
    // 视图模型依赖
    property var weatherViewModel: null
    property var navigationViewModel: null
    
    // UI状态属性
    property int currentIndex: 0
    
    // 信号
    signal cityChanged(string cityName)
    signal indexChanged(int newIndex)
    signal currentCityChanged(var cityData)
    
    // 监听currentIndex变化
    onCurrentIndexChanged: {
        indexChanged(currentIndex)
    }
    
    // 背景样式
    GlassEffect {
        anchors.fill: parent
        opacity: 0.3
        cornerRadius: 15
    }
    
    // 主要内容区域
    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 15
        
        // 城市显示卡片
        CityDisplayCard {
            id: cityCard
            width: parent.width - 100
            height: parent.height
            
            cityName: weatherViewModel && weatherViewModel.currentCityData ? 
                     weatherViewModel.currentCityData.cityName : ""
            temperature: weatherViewModel && weatherViewModel.currentCityData ? 
                        weatherViewModel.currentCityData.temperature : "--°C"
            weatherIcon: weatherViewModel && weatherViewModel.currentCityData ? 
                        weatherViewModel.currentCityData.weatherIcon : ""
            weatherDescription: weatherViewModel && weatherViewModel.currentCityData ? 
                               weatherViewModel.currentCityData.weatherDescription : "未知"
            maxMinTemp: weatherViewModel && weatherViewModel.currentCityData ? 
                       weatherViewModel.currentCityData.maxMinTemp : "--°C / --°C"
        }
        
        // 分页指示器和导航
        Column {
            width: 80
            height: parent.height
            spacing: 10
            
            // 分页指示器
            PageIndicator {
                id: pageIndicator
                anchors.horizontalCenter: parent.horizontalCenter
                totalPages: weatherViewModel ? weatherViewModel.getRecentCities().length : 0
                currentPage: currentIndex
                
                onPageClicked: function(pageIndex) {
                    if (weatherViewModel && pageIndex < weatherViewModel.getRecentCities().length) {
                        currentIndex = pageIndex
                        var cityName = weatherViewModel.getRecentCities()[pageIndex].name
                        weatherViewModel.switchToCity(pageIndex)
                        cityChanged(cityName)
                    }
                }
            }
            
            // 导航按钮
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                
                // 上一个城市按钮
                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: "#4A90E2"
                    visible: weatherViewModel && weatherViewModel.getRecentCities() && weatherViewModel.getRecentCities().length > 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: "white"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (weatherViewModel && weatherViewModel.recentCities.length > 0) {
                                var newIndex = (currentIndex - 1 + weatherViewModel.recentCities.length) % weatherViewModel.recentCities.length
                                currentIndex = newIndex
                                var cityName = weatherViewModel.recentCities[newIndex].name
                                weatherViewModel.switchToCity(cityName)
                                cityChanged(cityName)
                            }
                        }
                    }
                }
                
                // 下一个城市按钮
                Rectangle {
                    width: 30
                    height: 30
                    radius: 15
                    color: "#4A90E2"
                    visible: weatherViewModel && weatherViewModel.recentCities && weatherViewModel.recentCities.length > 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: "white"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (weatherViewModel && weatherViewModel.getRecentCities().length > 0) {
                                var newIndex = (currentIndex + 1) % weatherViewModel.getRecentCities().length
                                currentIndex = newIndex
                                var cityName = weatherViewModel.getRecentCities()[newIndex].name
                                weatherViewModel.switchToCity(newIndex)
                                cityChanged(cityName)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 监听最近城市列表变化
    Connections {
        target: weatherViewModel
        function onRecentCitiesChanged() {
            updateCurrentIndex()
        }
    }
    
    // 监听当前城市变化
    Connections {
        target: weatherViewModel
        function onCurrentCityChanged() {
            updateCurrentIndex()
        }
    }
    
    // 更新当前索引
    function updateCurrentIndex() {
        if (!weatherViewModel || !weatherViewModel.currentCityData) return
        
        var currentCityName = weatherViewModel.currentCityData.cityName
        var recentCities = weatherViewModel.getRecentCities()
        for (var i = 0; i < recentCities.length; i++) {
            if (recentCities[i].name === currentCityName) {
                currentIndex = i
                break
            }
        }
    }
    
    // 切换到下一个城市（键盘导航支持）
    function switchToNext() {
        if (weatherViewModel && weatherViewModel.getRecentCities().length > 0) {
            var newIndex = (currentIndex + 1) % weatherViewModel.getRecentCities().length
            currentIndex = newIndex
            var cityName = weatherViewModel.getRecentCities()[newIndex].name
            weatherViewModel.switchToCity(newIndex)
            cityChanged(cityName)
        }
    }
    
    // 切换到上一个城市（键盘导航支持）
    function switchToPrevious() {
        if (weatherViewModel && weatherViewModel.getRecentCities().length > 0) {
            var newIndex = (currentIndex - 1 + weatherViewModel.getRecentCities().length) % weatherViewModel.getRecentCities().length
            currentIndex = newIndex
            var cityName = weatherViewModel.getRecentCities()[newIndex].name
            weatherViewModel.switchToCity(newIndex)
            cityChanged(cityName)
        }
    }
    
    // 初始化
    Component.onCompleted: {
        updateCurrentIndex()
    }
}