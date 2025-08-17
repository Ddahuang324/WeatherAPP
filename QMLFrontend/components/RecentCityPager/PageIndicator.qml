// PageIndicator.qml - 分页指示器组件
import QtQuick

Row {
    id: pageIndicator
    spacing: 8
    
    // 可配置属性
    property int totalPages: 3
    property int currentPage: 0
    property color activeColor: "white"
    property color inactiveColor: Qt.rgba(1, 1, 1, 0.3)
    property real dotSize: 8
    property real dotRadius: 4
    
    // 页面切换信号
    signal pageClicked(int pageIndex)
    
    Repeater {
        model: pageIndicator.totalPages
        
        Rectangle {
            width: pageIndicator.dotSize
            height: pageIndicator.dotSize
            radius: pageIndicator.dotRadius
            color: index === pageIndicator.currentPage ? 
                   pageIndicator.activeColor : pageIndicator.inactiveColor
            
            Behavior on color {
                ColorAnimation { duration: 200 }
            }
            
            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
            
            scale: index === pageIndicator.currentPage ? 1.2 : 1.0
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: pageIndicator.pageClicked(index)
                
                onPressed: parent.scale = 0.8
                onReleased: parent.scale = index === pageIndicator.currentPage ? 1.2 : 1.0
            }
        }
    }
}