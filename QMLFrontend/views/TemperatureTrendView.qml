import QtQuick
import "../components/TempratureTrend"
import "../components/common"
import "../animations"

Rectangle {
    id: temperatureTrendView
    color: "transparent"
    
    // 简单的模拟数据
    property var recentDaysName: [
        "今天", "明天", "后天", "周四", "周五", "周六", "周日"
    ]
    
    property var recentDaysMaxMinTempreture: [
        "22°C / 12°C",
        "25°C / 15°C", 
        "20°C / 10°C",
        "18°C / 8°C",
        "23°C / 13°C",
        "26°C / 16°C",
        "24°C / 14°C"
    ]
    
    property var recentDaysWeatherDescriptionIcon: [
        "☀️", "⛅", "🌧️", "☀️", "🌤️", "☀️", "⛅"
    ]
    
    property string currentCityName: "北京"
    
    // 组件初始化时的处理
    Component.onCompleted: {
        console.log("TemperatureTrendView 已加载，包含", recentDaysName.length, "天的数据");
    }
    
    // 使用TempratureTrendItem组件
    TempratureTrendItem {
        anchors.fill: parent
        anchors.margins: 20
        
        // 传递数据给组件
        recentDaysName: temperatureTrendView.recentDaysName
        recentDaysMaxMinTempreture: temperatureTrendView.recentDaysMaxMinTempreture
        recentDaysWeatherDescriptionIcon: temperatureTrendView.recentDaysWeatherDescriptionIcon
        currentCityName: temperatureTrendView.currentCityName
    }
    
    // 拖拽区域
    DragArea {
        anchors.fill: parent
    }
}