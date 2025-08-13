// CityDisplayCard.qml - 城市信息展示卡片组件
import QtQuick

Item {
    id: cityDisplayCard
    
    // 城市数据属性
    property string cityName: "暂无城市"
    property string temperature: "--°C"
    property string weatherIcon: "🌤️"
    property string weatherDescription: "未知"
    property string maxMinTemp: "--°C / --°C"
    
    // 样式属性
    property color textColor: "white"
    property color primaryTextColor: "white"
    property color secondaryTextColor: Qt.rgba(1, 1, 1, 0.7)
    property int primaryFontSize: 18
    property int secondaryFontSize: 14
    property int temperatureFontSize: 24
    
    // 动画属性
    property bool animationEnabled: true
    
    // 内容布局
    Column {
        anchors.centerIn: parent
        spacing: 6
        
        // 天气图标
        Text {
            id: weatherIconText
            text: cityDisplayCard.weatherIcon
            font.pixelSize: 32
            anchors.horizontalCenter: parent.horizontalCenter
            
            Behavior on opacity {
                NumberAnimation { 
                    duration: cityDisplayCard.animationEnabled ? 300 : 0 
                }
            }
        }
        
        // 城市名称
        Text {
            id: cityNameText
            text: cityDisplayCard.cityName
            font.pixelSize: cityDisplayCard.primaryFontSize
            font.bold: true
            color: cityDisplayCard.primaryTextColor
            anchors.horizontalCenter: parent.horizontalCenter
            
            Behavior on opacity {
                NumberAnimation { 
                    duration: cityDisplayCard.animationEnabled ? 300 : 0 
                }
            }
        }
        
        // 当前温度
        Text {
            id: temperatureText
            text: cityDisplayCard.temperature
            font.pixelSize: cityDisplayCard.temperatureFontSize
            font.bold: true
            color: cityDisplayCard.primaryTextColor
            anchors.horizontalCenter: parent.horizontalCenter
            
            Behavior on opacity {
                NumberAnimation { 
                    duration: cityDisplayCard.animationEnabled ? 300 : 0 
                }
            }
        }
        
        // 天气描述
        Text {
            id: weatherDescText
            text: cityDisplayCard.weatherDescription
            font.pixelSize: cityDisplayCard.secondaryFontSize
            color: cityDisplayCard.secondaryTextColor
            anchors.horizontalCenter: parent.horizontalCenter
            
            Behavior on opacity {
                NumberAnimation { 
                    duration: cityDisplayCard.animationEnabled ? 300 : 0 
                }
            }
        }
        
        // 最高最低温度
        Text {
            id: maxMinTempText
            text: cityDisplayCard.maxMinTemp
            font.pixelSize: cityDisplayCard.secondaryFontSize
            color: cityDisplayCard.secondaryTextColor
            anchors.horizontalCenter: parent.horizontalCenter
            
            Behavior on opacity {
                NumberAnimation { 
                    duration: cityDisplayCard.animationEnabled ? 300 : 0 
                }
            }
        }
    }
    
    // 数据更新动画
    function updateWithAnimation() {
        if (!animationEnabled) return;
        
        // 淡出
        weatherIconText.opacity = 0;
        cityNameText.opacity = 0;
        temperatureText.opacity = 0;
        weatherDescText.opacity = 0;
        maxMinTempText.opacity = 0;
        
        // 延迟后淡入
        fadeInTimer.start();
    }
    
    Timer {
        id: fadeInTimer
        interval: 150
        onTriggered: {
            weatherIconText.opacity = 1;
            cityNameText.opacity = 1;
            temperatureText.opacity = 1;
            weatherDescText.opacity = 1;
            maxMinTempText.opacity = 1;
        }
    }
}