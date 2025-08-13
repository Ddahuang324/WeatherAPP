// NavigationMenu.qml - 导航菜单组件
import QtQuick

Column {
    id: navigationMenu
    spacing: 80
    
    // 菜单项点击事件信号
    signal menuItemClicked(string itemId)
    
    // 当天天气查询按钮
    MenuItem {
        iconText: "☀️"
        labelText: "今日天气"
        onClicked: navigationMenu.menuItemClicked("today_weather")
    }
    
    // 一周温度趋势
    MenuItem {
        iconText: "📈"
        labelText: "温度趋势"
        onClicked: navigationMenu.menuItemClicked("temperature_trend")
    }
    
    // 一周天气预报
    MenuItem {
        iconText: "📅"
        labelText: "详细天气"
        onClicked: navigationMenu.menuItemClicked("detailed_info")
    }
    
    // 日出日落时间
    MenuItem {
        iconText: "🌅"
        labelText: "日出日落"
        onClicked: navigationMenu.menuItemClicked("sunrise_sunset")
    }
}