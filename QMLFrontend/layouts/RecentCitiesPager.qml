// RecentCitiesPager.qml
import QtQuick
import "../animations"
import "../components"

Rectangle {
    id: recentCitiesPager
    width: parent.width
    height: 90
    color: "transparent" // 自身必须透明，才能看到后面的模糊效果
    
    // 背景源属性
    property Item backgroundSource: null
    
    // 对外接口
    property alias citiesManager: citiesManager
    
    // 信号
    signal cityChanged(var cityData)
    signal cityClicked(var cityData)
    
    // 城市数据管理器
    RecentCitiesManager {
        id: citiesManager
        
        onCurrentCityChanged: function(cityData) {
            recentCitiesPager.cityChanged(cityData);
        }
        
        onIndexChanged: function(newIndex) {
            pageIndicator.currentPage = newIndex;
        }
        
        Component.onCompleted: {
            // 组件初始化完成
        }
    }
    
    // 分页器样式
    RecentCitiesPagerStyle {
        anchors.fill: parent
        blurSource: recentCitiesPager.backgroundSource
    }
    
    // 主要内容区域
    Item {
        anchors.fill: parent
        anchors.margins: 20
        
        // 居中的分页指示器
        PageIndicator {
            id: pageIndicator
            anchors.centerIn: parent
            
            totalPages: citiesManager.maxCities
            currentPage: citiesManager.currentIndex
            
            // 样式配置 - 放大三倍，增加间距
            dotSize: 18  // 原来是6，放大三倍
            dotRadius: 9  // 原来是3，放大三倍
            spacing: 12  // 原来是6，增加一倍
            activeColor: "white"
            inactiveColor: Qt.rgba(1, 1, 1, 0.3)
            
            onPageClicked: function(pageIndex) {
                if (citiesManager.weatherViewModel) {
                    citiesManager.weatherViewModel.switchToCity(pageIndex);
                    citiesManager.currentIndex = pageIndex;
                }
            }
        }
        
        // 滑动手势支持区域
        MouseArea {
            anchors.fill: parent
            
            property real startX: 0
            property bool isDragging: false
            
            onPressed: function(mouse) {
                startX = mouse.x;
                isDragging = false;
            }
            
            onPositionChanged: function(mouse) {
                if (pressed) {
                    var deltaX = Math.abs(mouse.x - startX);
                    if (deltaX > 10) {
                        isDragging = true;
                    }
                }
            }
            
            onReleased: function(mouse) {
                if (isDragging) {
                    var deltaX = mouse.x - startX;
                    
                    if (Math.abs(deltaX) > 50) { // 滑动距离阈值
                        if (deltaX > 0) {
                            // 向右滑动，切换到上一个城市
                            citiesManager.switchToPrevious();
                        } else {
                            // 向左滑动，切换到下一个城市
                            citiesManager.switchToNext();
                        }
                    }
                } else if (!isDragging) {
                    // 点击事件
                    recentCitiesPager.cityClicked(citiesManager.getCurrentCity());
                }
                isDragging = false;
            }
            
            // 防止与拖拽窗口冲突
            propagateComposedEvents: true
        }
    }
    
    // 拖拽区域（用于移动窗口）
    DragArea {
        id: dragArea
        anchors.fill: parent
        
        // 动态启用/禁用拖拽，避免与分页指示器冲突
        property bool isOverPageIndicator: false
        
        onPressed: function(mouse) {
            var pageIndicatorPos = mapToItem(pageIndicator, mouse.x, mouse.y);
            isOverPageIndicator = (pageIndicatorPos.x >= 0 && pageIndicatorPos.x <= pageIndicator.width &&
                                  pageIndicatorPos.y >= 0 && pageIndicatorPos.y <= pageIndicator.height);
            
            if (!isOverPageIndicator) {
                // 只有在非分页指示器区域才启用拖拽
                enableDrag = true;
            } else {
                enableDrag = false;
            }
        }
    }
    
    // 公共方法
    function addCity(cityData) {
        citiesManager.addRecentCity(cityData);
    }
    
    function getCurrentCity() {
        return citiesManager.getCurrentCity();
    }
    
    function switchToNext() {
        citiesManager.switchToNext();
    }
    
    function switchToPrevious() {
        citiesManager.switchToPrevious();
    }
    
    function getCityCount() {
        return citiesManager.getCityCount();
    }
}