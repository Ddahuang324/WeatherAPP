// BaseView.qml - 视图基类
import QtQuick
import "../components/common"
import "../animations"

Rectangle {
    id: baseView
    
    // 基础属性
    color: "transparent"
    
    // 视图标识
    property string viewId: ""
    property string viewName: ""
    
    // 数据属性
    property var weatherData: null
    property var viewModel: null
    
    // 状态属性
    property bool isLoading: false
    property string errorMessage: ""
    property bool isActive: false
    
    // 配置属性
    property bool enableDrag: true
    property bool showLoadingIndicator: true
    property bool showErrorMessage: true
    
    // 信号
    signal viewActivated()
    signal viewDeactivated()
    signal dataUpdated(var data)
    signal errorOccurred(string error)
    signal userInteraction(string action, var data)
    
    // 抽象方法（子类需要实现）
    function updateCityData(cityData) {
        weatherData = cityData
        dataUpdated(cityData)
        // 子类应该重写此方法来处理具体的数据更新逻辑
    }
    
    function onViewActivated() {
        isActive = true
        viewActivated()
        // 子类可以重写此方法来处理视图激活逻辑
    }
    
    function onViewDeactivated() {
        isActive = false
        viewDeactivated()
        // 子类可以重写此方法来处理视图停用逻辑
    }
    
    // 通用方法
    function setLoading(loading) {
        if (isLoading !== loading) {
            isLoading = loading
        }
    }
    
    function setError(error) {
        errorMessage = error || ""
        if (error) {
            errorOccurred(error)
        }
    }
    
    function clearError() {
        setError("")
    }
    
    function refresh() {
        if (viewModel && viewModel.refreshData) {
            viewModel.refreshData()
        }
    }
    
    function validateData(data) {
        return data && typeof data === 'object'
    }
    
    // 通用拖拽区域
    DragArea {
        id: dragArea
        anchors.fill: parent
        enableDrag: baseView.enableDrag
        z: -1 // 确保在内容下方
    }
    
    // 加载指示器
    Rectangle {
        id: loadingIndicator
        anchors.centerIn: parent
        width: 100
        height: 100
        radius: 10
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: isLoading && showLoadingIndicator
        z: 1000
        
        Column {
            anchors.centerIn: parent
            spacing: 10
            
            // 简单的旋转动画作为加载指示
            Text {
                text: "⟳"
                font.pixelSize: 30
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                
                RotationAnimation {
                    target: parent
                    property: "rotation"
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: loadingIndicator.visible
                }
            }
            
            Text {
                text: "加载中..."
                font.pixelSize: 14
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
    
    // 错误消息显示
    Rectangle {
        id: errorMessageContainer
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: Qt.rgba(1, 0, 0, 0.8)
        visible: errorMessage !== "" && showErrorMessage
        z: 999
        
        Text {
            anchors.centerIn: parent
            text: errorMessage
            color: "white"
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: clearError()
        }
        
        // 自动隐藏错误消息
        Timer {
            interval: 5000
            running: errorMessageContainer.visible
            onTriggered: clearError()
        }
    }
    
    // 生命周期管理
    Component.onCompleted: {
        console.log("BaseView completed:", viewId)
    }
    
    Component.onDestruction: {
        console.log("BaseView destroyed:", viewId)
    }
    
    // 属性变化监听
    onWeatherDataChanged: {
        if (weatherData) {
            clearError()
        }
    }
    
    onIsActiveChanged: {
        if (isActive) {
            onViewActivated()
        } else {
            onViewDeactivated()
        }
    }
    
    // 键盘事件处理
    Keys.onPressed: function(event) {
        switch(event.key) {
            case Qt.Key_F5:
                refresh()
                event.accepted = true
                break
            case Qt.Key_Escape:
                clearError()
                event.accepted = true
                break
        }
    }
    
    // 焦点管理
    focus: isActive
    
    // 辅助功能
    function getViewInfo() {
        return {
            id: viewId,
            name: viewName,
            isActive: isActive,
            isLoading: isLoading,
            hasError: errorMessage !== "",
            hasData: weatherData !== null
        }
    }
    
    function emitUserInteraction(action, data) {
        userInteraction(action, data || {})
    }
}