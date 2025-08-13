// NavigationMenu.qml - 导航菜单组件
import QtQuick

Column {
    id: navigationMenu
    spacing: 80
    
    // 属性
    property string currentView: "today_weather"
    
    // 菜单项点击事件信号
    signal menuItemClicked(string itemId)
    
    // 当天天气查询按钮
    MenuItem {
        iconText: "☀️"
        labelText: "今日天气"
        itemId: "today_weather"
        isSelected: currentView === "today_weather"
        onClicked: navigationMenu.menuItemClicked("today_weather")
    }
    
    // 一周温度趋势
    MenuItem {
        iconText: "📈"
        labelText: "温度趋势"
        itemId: "temperature_trend"
        isSelected: currentView === "temperature_trend"
        onClicked: navigationMenu.menuItemClicked("temperature_trend")
    }
    
    // 一周天气预报
    MenuItem {
        iconText: "📅"
        labelText: "详细天气"
        itemId: "detailed_info"
        isSelected: currentView === "detailed_info"
        onClicked: navigationMenu.menuItemClicked("detailed_info")
    }
    
    // 日出日落
    MenuItem {
        iconText: "🌅"
        labelText: "日出日落"
        itemId: "sunrise_sunset"
        isSelected: currentView === "sunrise_sunset"
        onClicked: navigationMenu.menuItemClicked("sunrise_sunset")
    }
}