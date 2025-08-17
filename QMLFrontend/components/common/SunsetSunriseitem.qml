import QtQuick
import QtQuick.Shapes

Item {
    id: sunsetSunriseItem
    width: 400
    height: 250
    
    // 属性定义
    property string sunriseTime: "06:30"  // 日出时间
    property string sunsetTime: "18:45"   // 日落时间
    property string currentTime: "12:30"  // 当前时间
    
    // 将时间字符串转换为分钟数的函数
    function timeToMinutes(timeStr) {
        var parts = timeStr.split(":");
        return parseInt(parts[0]) * 60 + parseInt(parts[1]);
    }
    
    // 计算当前时间在半圆中的角度
    function calculateCurrentAngle() {
        var sunriseMinutes = timeToMinutes(sunriseTime);
        var sunsetMinutes = timeToMinutes(sunsetTime);
        var currentMinutes = timeToMinutes(currentTime);
        
        // 如果当前时间在日出之前或日落之后，返回相应的边界角度
        if (currentMinutes <= sunriseMinutes) {
            return 0; // 日出位置（左侧，0度）
        }
        if (currentMinutes >= sunsetMinutes) {
            return 180; // 日落位置（右侧，180度）
        }
        
        // 计算当前时间相对于日出时间的进度
        var totalDaylight = sunsetMinutes - sunriseMinutes; // 日出到日落的总时间
        var elapsedTime = currentMinutes - sunriseMinutes;  // 从日出开始已经过去的时间
        var ratio = elapsedTime / totalDaylight;            // 进度比例
        
        // 将比例转换为角度（0-180度，从左到右）
        return ratio * 180;
    }
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
     
        
        // 半圆图形区域
        Item {
            width: 300
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
                
                // 半圆背景
                Shape {
                    anchors.fill: parent
                    
                    ShapePath {
                        strokeColor: "lightgray"
                        strokeWidth: 3
                        fillColor: "transparent"
                        
                        PathArc {
                            x: 250
                            y: 150
                            radiusX: 125
                            radiusY: 125
                            useLargeArc: true
                        }
                        
                        startX: 25
                        startY: 150
                    }
                }
                
                // 日出标记
                Rectangle {
                    x: 15
                    y: 140
                    width: 20
                    height: 20
                    color: "orange"
                    radius: 10
                    
                    Text {
                        text: "🌅"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                }
                
                // 日落标记
                Rectangle {
                    x: 265
                    y: 140
                    width: 20
                    height: 20
                    color: "red"
                    radius: 10
                    
                    Text {
                        text: "🌇"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }
                }
                
                // 当前时间指示器
                Item {
                    id: currentTimeIndicator
                    width: parent.width
                    height: parent.height
                    
                    property real angle: calculateCurrentAngle()
                    property real radius: 125
                    property real centerX: 150  // 半圆的中心X坐标
                    property real centerY: 150  // 半圆的中心Y坐标（底部）
                    
                    // 计算当前时间点的坐标（在半圆弧上）
                    property real arcX: centerX + radius * Math.cos((180 - angle) * Math.PI / 180)
                    property real arcY: centerY - radius * Math.sin((180 - angle) * Math.PI / 180)
                    
                    // 计算指示线顶部位置（继续加长30像素）
                    property real lineRadius: radius + 70  // 比弧线半径大70像素
                    property real lineTopX: centerX + lineRadius * Math.cos((180 - angle) * Math.PI / 180)
                    property real lineTopY: centerY - lineRadius * Math.sin((180 - angle) * Math.PI / 180)
                    
                    // 计算太阳emoji的位置（进一步外移）
                    property real sunRadius: radius + 90  // 比弧线半径大90像素，进一步外移
                    property real sunX: centerX + sunRadius * Math.cos((180 - angle) * Math.PI / 180)
                    property real sunY: centerY - sunRadius * Math.sin((180 - angle) * Math.PI / 180)
                    
                    // 指示线（从圆心延伸到更长位置）
                    Rectangle {
                        x: currentTimeIndicator.centerX - 1
                        y: currentTimeIndicator.centerY - currentTimeIndicator.lineRadius  // 延伸到更长位置
                        width: 2
                        height: currentTimeIndicator.lineRadius  // 增加线的长度
                        color: "yellow"
                        transformOrigin: Item.Bottom
                        rotation: currentTimeIndicator.angle - 90  // 调整角度，使线条正确指向
                    }
                    
                    // 弧线上的指示点
                    Rectangle {
                        x: currentTimeIndicator.arcX - 4
                        y: currentTimeIndicator.arcY - 4
                        width: 8
                        height: 8
                        color: "yellow"
                        radius: 4
                        border.color: "white"
                        border.width: 1
                    }
                    
                    // 线顶部的黄色指示点
                    Rectangle {
                        x: currentTimeIndicator.lineTopX - 6
                        y: currentTimeIndicator.lineTopY - 6
                        width: 12
                        height: 12
                        color: "yellow"
                        radius: 6
                        border.color: "white"
                        border.width: 2
                    }
                    
                    // 太阳emoji（进一步外移）
                    Text {
                        x: currentTimeIndicator.sunX - 12
                        y: currentTimeIndicator.sunY - 12
                        text: "☀️"
                        font.pixelSize: 24
                    }
                }
            }
        
        // 时间信息显示
        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10
            spacing: 40
            
            Column {
                spacing: 2
                Text {
                    text: "日出"
                    font.pixelSize: 12
                    color: "lightgray"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: sunriseTime
                    font.pixelSize: 14
                    font.bold: true
                    color: "orange"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            Column {
                spacing: 2
                Text {
                    text: "当前"
                    font.pixelSize: 12
                    color: "lightgray"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: currentTime
                    font.pixelSize: 14
                    font.bold: true
                    color: "yellow"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            
            Column {
                spacing: 2
                Text {
                    text: "日落"
                    font.pixelSize: 12
                    color: "lightgray"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: sunsetTime
                    font.pixelSize: 14
                    font.bold: true
                    color: "red"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}