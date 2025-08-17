import QtQuick

// 专门的温度图表组件
Rectangle {
    id: temperatureChart
    color: "transparent"
    
    // 对外接口属性
    property var maxTemperatures: []
    property var minTemperatures: []
    property var dayLabels: []
    property color maxTempColor: "#FF6B6B"
    property color minTempColor: "#4ECDC4"
    property color textColor: "white"
    property color axisColor: "white"
    
    // 内部计算属性
    property real calculatedMinTemp: 0
    property real calculatedMaxTemp: 40
    
    // 图表更新函数
    function updateChart(maxTemps, minTemps, labels) {
        maxTemperatures = maxTemps || [];
        minTemperatures = minTemps || [];
        dayLabels = labels || [];
        
        // 计算温度范围
        if (maxTemperatures.length > 0 && minTemperatures.length > 0) {
            var tempMin = Math.min(...minTemperatures);
            var tempMax = Math.max(...maxTemperatures);
            calculatedMinTemp = tempMin - 3;
            calculatedMaxTemp = tempMax + 3;
        }
        
        canvas.requestPaint();
    }
    
    // 解析温度数据的辅助函数
    function parseTemperatureData(temperatureStrings, dayNames) {
        var maxTemps = [];
        var minTemps = [];
        var labels = [];
        
        console.log("TemperatureChart: 开始解析温度数据，共", temperatureStrings.length, "条记录");
        
        for (var i = 0; i < temperatureStrings.length; i++) {
            var tempStr = temperatureStrings[i];
            console.log("TemperatureChart: 解析第", i, "条数据:", tempStr);
            
            if (tempStr && typeof tempStr === 'string' && tempStr.includes(" / ")) {
                var temps = tempStr.split(" / ");
                if (temps.length >= 2) {
                    var highTempStr = temps[0].trim();
                    var lowTempStr = temps[1].trim();
                    
                    // 支持多种温度格式："高温 30℃"、"30°C"、"30℃"
                    var highTemp, lowTemp;
                    
                    // 解析高温
                    if (highTempStr.includes("高温")) {
                        highTemp = parseInt(highTempStr.replace("高温", "").replace("℃", "").replace("°C", "").trim());
                    } else {
                        highTemp = parseInt(highTempStr.replace("℃", "").replace("°C", "").trim());
                    }
                    
                    // 解析低温
                    if (lowTempStr.includes("低温")) {
                        lowTemp = parseInt(lowTempStr.replace("低温", "").replace("℃", "").replace("°C", "").trim());
                    } else {
                        lowTemp = parseInt(lowTempStr.replace("℃", "").replace("°C", "").trim());
                    }
                    
                    console.log("TemperatureChart: 解析结果 - 高温:", highTemp, "低温:", lowTemp);
                    
                    if (!isNaN(highTemp) && !isNaN(lowTemp)) {
                        maxTemps.push(highTemp);
                        minTemps.push(lowTemp);
                        labels.push(dayNames[i] || "Day" + (i + 1));
                    } else {
                        console.log("TemperatureChart: 温度解析失败，跳过此条数据");
                    }
                }
            }
        }
        
        console.log("TemperatureChart: 最终解析结果 - 最高温度:", maxTemps, "最低温度:", minTemps, "标签:", labels);
        updateChart(maxTemps, minTemps, labels);
    }
    
    Canvas {
        id: canvas
        anchors.fill: parent
        anchors.margins: 20
        
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            
            if (maxTemperatures.length === 0) return;
            
            // 设置画布样式
            ctx.strokeStyle = axisColor;
            ctx.fillStyle = textColor;
            ctx.font = "12px Arial";
            
            var margin = 40;
            var chartWidth = width - 2 * margin;
            var chartHeight = height - 2 * margin;
            
            // 绘制坐标轴
            ctx.beginPath();
            ctx.moveTo(margin, margin);
            ctx.lineTo(margin, height - margin);
            ctx.lineTo(width - margin, height - margin);
            ctx.stroke();
            
            // 绘制Y轴刻度和标签
            var tempRange = calculatedMaxTemp - calculatedMinTemp;
            for (var i = 0; i <= 5; i++) {
                var temp = calculatedMinTemp + (tempRange * i / 5);
                var y = height - margin - (chartHeight * i / 5);
                
                ctx.beginPath();
                ctx.moveTo(margin - 5, y);
                ctx.lineTo(margin, y);
                ctx.stroke();
                
                ctx.fillText(Math.round(temp) + "°C", 5, y + 4);
            }
            
            // 绘制X轴标签
            for (var j = 0; j < dayLabels.length; j++) {
                var x = margin + (chartWidth * j / (dayLabels.length - 1));
                ctx.fillText(dayLabels[j], x - 15, height - 5);
            }
            
            // 绘制最高温度折线
            if (maxTemperatures.length > 1) {
                ctx.strokeStyle = maxTempColor;
                ctx.lineWidth = 3;
                ctx.beginPath();
                
                for (var k = 0; k < maxTemperatures.length; k++) {
                    var x = margin + (chartWidth * k / (maxTemperatures.length - 1));
                    var y = height - margin - ((maxTemperatures[k] - calculatedMinTemp) / tempRange * chartHeight);
                    
                    if (k === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        ctx.lineTo(x, y);
                    }
                }
                ctx.stroke();
                
                // 绘制最高温度点和标签
                ctx.fillStyle = maxTempColor;
                for (var l = 0; l < maxTemperatures.length; l++) {
                    var x = margin + (chartWidth * l / (maxTemperatures.length - 1));
                    var y = height - margin - ((maxTemperatures[l] - calculatedMinTemp) / tempRange * chartHeight);
                    
                    ctx.beginPath();
                    ctx.arc(x, y, 4, 0, 2 * Math.PI);
                    ctx.fill();
                    
                    ctx.fillText(maxTemperatures[l] + "°C", x - 15, y - 10);
                }
            }
            
            // 绘制最低温度折线
            if (minTemperatures.length > 1) {
                ctx.strokeStyle = minTempColor;
                ctx.lineWidth = 3;
                ctx.beginPath();
                
                for (var m = 0; m < minTemperatures.length; m++) {
                    var x = margin + (chartWidth * m / (minTemperatures.length - 1));
                    var y = height - margin - ((minTemperatures[m] - calculatedMinTemp) / tempRange * chartHeight);
                    
                    if (m === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        ctx.lineTo(x, y);
                    }
                }
                ctx.stroke();
                
                // 绘制最低温度点和标签
                ctx.fillStyle = minTempColor;
                for (var n = 0; n < minTemperatures.length; n++) {
                    var x = margin + (chartWidth * n / (minTemperatures.length - 1));
                    var y = height - margin - ((minTemperatures[n] - calculatedMinTemp) / tempRange * chartHeight);
                    
                    ctx.beginPath();
                    ctx.arc(x, y, 4, 0, 2 * Math.PI);
                    ctx.fill();
                    
                    ctx.fillText(minTemperatures[n] + "°C", x - 15, y + 20);
                }
            }
            
            // 绘制图例
            ctx.fillStyle = maxTempColor;
            ctx.fillRect(width - 150, 20, 15, 3);
            ctx.fillStyle = textColor;
            ctx.fillText("最高温度", width - 130, 30);
            
            ctx.fillStyle = minTempColor;
            ctx.fillRect(width - 150, 40, 15, 3);
            ctx.fillStyle = textColor;
            ctx.fillText("最低温度", width - 130, 50);
        }
    }
}