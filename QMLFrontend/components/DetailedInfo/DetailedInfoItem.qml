import QtQuick
import QtQuick.Layouts
import "../common"
import "."

Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // 天气数据属性
        property string cityName: "北京"
        property string cityHumidity: ""
        property string cityWind: ""
        property string cityRain: ""
        property string cityAirQuality: ""
        property string cityAirPressure: ""
        property string cityUVI: ""

        //复用组件：城市名称
        CityNameLabel{
            id:cityNameComponent
            cityName : parent.cityName
            fontSize : 50
            font.bold : true
        }
        //详细信息组件
        GridLayout{
            width: parent.width
            height: parent.height - cityNameComponent.height - 40
            columns: 3
            rows: 2
            columnSpacing: 30
            rowSpacing: 30
            Layout.alignment: Qt.AlignCenter

            //湿度
            DetailedInfoLabel{
                labelText: "湿度"
                valueText: cityHumidity || "65%"
                iconText: "💧"
                fontSize: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            //风速
            DetailedInfoLabel{
                labelText: "风速"
                valueText: cityWind || "东南风 2级"
                iconText: "💨"
                fontSize: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            //降雨量
            DetailedInfoLabel{
                labelText: "降雨量"
                valueText: cityRain || "0mm"
                iconText: "🌧️"
                fontSize: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            //空气质量
            DetailedInfoLabel{
                labelText: "空气质量"
                valueText: cityAirQuality || "良好"
                iconText: "🌿"
                fontSize: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            //PM2.5
            DetailedInfoLabel{
                labelText: "PM2.5"
                valueText: cityAirPressure || "25 μg/m³"
                iconText: "🌫️"
                fontSize: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            //紫外线指数
            DetailedInfoLabel{
                labelText: "紫外线"
                valueText: cityUVI || "中等"
                iconText: "☀️"
                fontSize: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }  
        
    }
