import QtQuick
import QtQuick.Controls
import "../" as Components

// 温度趋势主组件 - 专注于布局和数据传递
Rectangle {
    id: tempratureTrendItem
    width: parent.width
    height: parent.height
    radius: 10
    color: "transparent"

    // 对外数据接口
    property var recentDaysName: []
    property var recentDaysMaxMinTempreture: []
    property var recentDaysWeatherDescriptionIcon: []
    property string currentCityName: ""

    // 颜色配置
    property color textColor: "#FFFFFF"
    property color maxTempretureColor: "#FF6B6B"
    property color minTempretureColor: "#4ECDC4"

    Component.onCompleted: {
        console.log("TempratureTrendItem loaded with", recentDaysName.length, "days of data");
    }

    // 监听数据变化，自动更新图表
    onRecentDaysMaxMinTempretureChanged: {
        console.log("温度数据已更新，包含", recentDaysMaxMinTempreture.length, "天的数据");
        if (recentDaysMaxMinTempreture.length > 0) {
            temperatureChart.parseTemperatureData(recentDaysMaxMinTempreture, recentDaysName);
        }
    }

    // 主要内容布局
    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // 城市名称
        Text {
            id: cityNameComponent
            text: tempratureTrendItem.currentCityName
            font.pixelSize: 32
            font.bold: true
            color: "white"
            anchors.left: parent.left
        }

        // 左侧列表/右侧视图
        Row {
            width: parent.width
            height: parent.height - cityNameComponent.height - parent.spacing
            spacing: 20

            // 左侧列表面板
            Rectangle {
                id: leftPanel
                width: parent.width * 0.4  // 参考View中的宽度比例
                height: parent.height
                color: Qt.rgba(1, 1, 1, 0.1)
                radius: 10
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 1

                ListView {
                    id: leftListView
                    anchors.fill: parent
                    anchors.margins: 10
                    model: tempratureTrendItem.recentDaysName.length
                    spacing: 5
                    delegate: TempratureTrendItemDelegate {
                        width: leftListView.width
                        height: 60
                        cityName: tempratureTrendItem.recentDaysName[index] || ""
                        maxMinTempreture: tempratureTrendItem.recentDaysMaxMinTempreture[index] || ""
                        weatherDescriptionIcon: tempratureTrendItem.recentDaysWeatherDescriptionIcon[index] || ""
                    }
                }
            }

            // 右侧图表面板
            Rectangle {
                id: rightPanel
                width: parent.width * 0.6 - parent.spacing
                height: parent.height
                color: Qt.rgba(1, 1, 1, 0.1)
                radius: 10
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 1

                // 使用专门的温度图表组件
                TemperatureChart {
                    id: temperatureChart
                    anchors.fill: parent
                    anchors.margins: 15
                    
                    // 传递颜色配置
                    maxTempColor: tempratureTrendItem.maxTempretureColor
                    minTempColor: tempratureTrendItem.minTempretureColor
                    textColor: tempratureTrendItem.textColor
                    
                    Component.onCompleted: {
                        // 初始化时解析数据
                        if (recentDaysMaxMinTempreture.length > 0) {
                            parseTemperatureData(recentDaysMaxMinTempreture, recentDaysName);
                        }
                    }
                }
            }
        }
    }
}
