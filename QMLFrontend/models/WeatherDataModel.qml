// WeatherDataModel.qml - 天气数据模型
import QtQuick

QtObject {
    id: weatherDataModel
    
    // 基础天气数据结构
    property string cityName: ""
    property string temperature: "--°C"
    property string weatherIcon: "🌤️"
    property string weatherDescription: "未知"
    property string maxMinTemp: "--°C / --°C"
    
    // 扩展数据
    property var weeklyForecast: null
    property var detailedInfo: null
    property var sunriseInfo: null
    property string ganmao: ""
    property string notice: ""
    
    // 数据验证
    function isValid() {
        return cityName !== "" && temperature !== "--°C"
    }
    
    // 从原始数据创建模型
    function fromRawData(rawData) {
        if (!rawData) return createEmpty()
        
        var model = Qt.createQmlObject('
            import QtQuick
            import "."
            WeatherDataModel {}
        ', weatherDataModel)
        
        model.cityName = rawData.cityName || ""
        model.temperature = rawData.temperature || "--°C"
        model.weatherIcon = rawData.weatherIcon || "🌤️"
        model.weatherDescription = rawData.weatherDescription || "未知"
        model.maxMinTemp = rawData.maxMinTemp || "--°C / --°C"
        model.weeklyForecast = rawData.weeklyForecast || null
        model.detailedInfo = rawData.detailedInfo || null
        model.sunriseInfo = rawData.sunriseInfo || null
        model.ganmao = rawData.ganmao || ""
        model.notice = rawData.notice || ""
        
        return model
    }
    
    // 创建空模型
    function createEmpty() {
        var model = Qt.createQmlObject('
            import QtQuick
            import "."
            WeatherDataModel {}
        ', weatherDataModel)
        
        model.cityName = "暂无城市"
        model.temperature = "--°C"
        model.weatherIcon = "🌤️"
        model.weatherDescription = "未知"
        model.maxMinTemp = "--°C / --°C"
        
        return model
    }
    
    // 转换为普通对象
    function toObject() {
        return {
            cityName: cityName,
            temperature: temperature,
            weatherIcon: weatherIcon,
            weatherDescription: weatherDescription,
            maxMinTemp: maxMinTemp,
            weeklyForecast: weeklyForecast,
            detailedInfo: detailedInfo,
            sunriseInfo: sunriseInfo,
            ganmao: ganmao,
            notice: notice
        }
    }
    
    // 复制模型
    function clone() {
        return fromRawData(toObject())
    }
    
    // 更新数据
    function updateData(newData) {
        if (!newData) return
        
        if (newData.cityName !== undefined) cityName = newData.cityName
        if (newData.temperature !== undefined) temperature = newData.temperature
        if (newData.weatherIcon !== undefined) weatherIcon = newData.weatherIcon
        if (newData.weatherDescription !== undefined) weatherDescription = newData.weatherDescription
        if (newData.maxMinTemp !== undefined) maxMinTemp = newData.maxMinTemp
        if (newData.weeklyForecast !== undefined) weeklyForecast = newData.weeklyForecast
        if (newData.detailedInfo !== undefined) detailedInfo = newData.detailedInfo
        if (newData.sunriseInfo !== undefined) sunriseInfo = newData.sunriseInfo
        if (newData.ganmao !== undefined) ganmao = newData.ganmao
        if (newData.notice !== undefined) notice = newData.notice
    }
}