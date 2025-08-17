import QtQuick
import QtQuick.Layouts
import "../common"
import "."

Column {
        width: parent.width - 40
        height: parent.height - 40
        anchors.centerIn: parent
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
            anchors.left: undefined
            anchors.top: undefined
        }
        //详细信息组件
        GridLayout{
            width: parent.width - 100
            height: parent.height - cityNameComponent.height -80
            anchors.top : cityNameComponent.bottom
            anchors.topMargin: 50
            anchors.left: undefined
            anchors.leftMargin: 50
            columns: 3
            rows: 2
            columnSpacing: 40
            rowSpacing: 20

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
                valueText: cityWind || "12km/h"
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
            
            //气压
            DetailedInfoLabel{
                labelText: "气压"
                valueText: cityAirPressure || "1013hPa"
                iconText: "📊"
                fontSize: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            
            //紫外线指数
            DetailedInfoLabel{
                labelText: "紫外线"
                valueText: cityUVI || "5"
                iconText: "☀️"
                fontSize: 16
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }  
        
    }
