// WeatherDataService.qml - 天气数据服务
import QtQuick
import "../models"

QtObject {
    id: weatherDataService
    
    // 信号
    signal dataLoaded(var weatherData)
    signal dataLoadError(string error)
    
    // 获取城市天气数据
    function getCityWeather(cityName, callback) {
        // 模拟异步数据获取
        Qt.callLater(function() {
            var mockData = generateMockWeatherData(cityName)
            if (callback) {
                callback(mockData)
            }
            dataLoaded(mockData)
        })
    }
    
    // 获取周天气预报
    function getWeeklyForecast(cityName, callback) {
        Qt.callLater(function() {
            var forecastData = generateMockWeeklyForecast(cityName)
            if (callback) {
                callback(forecastData)
            }
        })
    }
    
    // 获取详细天气信息
    function getDetailedWeatherInfo(cityName, callback) {
        Qt.callLater(function() {
            var detailedData = generateMockDetailedInfo(cityName)
            if (callback) {
                callback(detailedData)
            }
        })
    }
    
    // 获取日出日落信息
    function getSunriseInfo(cityName, callback) {
        Qt.callLater(function() {
            var sunriseData = generateMockSunriseInfo(cityName)
            if (callback) {
                callback(sunriseData)
            }
        })
    }
    
    // 搜索城市
    function searchCities(query, callback) {
        Qt.callLater(function() {
            var results = generateMockSearchResults(query)
            if (callback) {
                callback(results)
            }
        })
    }
    
    // 生成模拟天气数据
    function generateMockWeatherData(cityName) {
        var weatherOptions = [
            { icon: "☀️", desc: "晴", temp: 25, min: 18, max: 28 },
            { icon: "🌤️", desc: "多云", temp: 22, min: 16, max: 25 },
            { icon: "🌦️", desc: "小雨", temp: 20, min: 15, max: 23 },
            { icon: "⛅", desc: "阴", temp: 18, min: 12, max: 21 },
            { icon: "🌧️", desc: "雨", temp: 16, min: 10, max: 19 }
        ]
        
        var randomWeather = weatherOptions[Math.floor(Math.random() * weatherOptions.length)]
        
        return {
            cityName: cityName,
            temperature: randomWeather.temp + "°C",
            weatherIcon: randomWeather.icon,
            weatherDescription: randomWeather.desc,
            maxMinTemp: randomWeather.max + "°C / " + randomWeather.min + "°C"
        }
    }
    
    // 生成模拟周天气预报
    function generateMockWeeklyForecast(cityName) {
        var days = ["今天", "明天", "后天", "周四", "周五", "周六", "周日"]
        var icons = ["☀️", "🌤️", "🌦️", "⛅", "🌧️"]
        
        var forecast = {
            recentDaysName: days,
            recentDaysMaxMinTempreture: [],
            recentDaysWeatherDescriptionIcon: []
        }
        
        for (var i = 0; i < days.length; i++) {
            var maxTemp = Math.floor(Math.random() * 15) + 20 // 20-35°C
            var minTemp = maxTemp - Math.floor(Math.random() * 10) - 5 // 比最高温低5-15°C
            forecast.recentDaysMaxMinTempreture.push(maxTemp + "°C / " + minTemp + "°C")
            forecast.recentDaysWeatherDescriptionIcon.push(icons[Math.floor(Math.random() * icons.length)])
        }
        
        return forecast
    }
    
    // 生成模拟详细信息
    function generateMockDetailedInfo(cityName) {
        return {
            humidity: (Math.floor(Math.random() * 40) + 40) + "%", // 40-80%
            windSpeed: (Math.floor(Math.random() * 20) + 5) + "km/h", // 5-25km/h
            rainfall: (Math.floor(Math.random() * 10)) + "mm", // 0-10mm
            airQuality: ["优", "良好", "轻度污染", "中度污染"][Math.floor(Math.random() * 4)],
            airPressure: (Math.floor(Math.random() * 50) + 1000) + "hPa", // 1000-1050hPa
            uvIndex: Math.floor(Math.random() * 11).toString() // 0-10
        }
    }
    
    // 生成模拟日出日落信息
    function generateMockSunriseInfo(cityName) {
        var sunriseHour = Math.floor(Math.random() * 2) + 6 // 6-7点
        var sunriseMinute = Math.floor(Math.random() * 60)
        var sunsetHour = Math.floor(Math.random() * 2) + 18 // 18-19点
        var sunsetMinute = Math.floor(Math.random() * 60)
        
        var sunrise = String(sunriseHour).padStart(2, '0') + ":" + String(sunriseMinute).padStart(2, '0')
        var sunset = String(sunsetHour).padStart(2, '0') + ":" + String(sunsetMinute).padStart(2, '0')
        
        var dayLengthMinutes = (sunsetHour * 60 + sunsetMinute) - (sunriseHour * 60 + sunriseMinute)
        var dayLengthHours = Math.floor(dayLengthMinutes / 60)
        var remainingMinutes = dayLengthMinutes % 60
        
        return {
            sunrise: sunrise,
            sunset: sunset,
            dayLength: dayLengthHours + "小时" + remainingMinutes + "分钟"
        }
    }
    
    // 生成模拟搜索结果
    function generateMockSearchResults(query) {
        var allCities = [
            "北京", "上海", "广州", "深圳", "杭州", "南京", "武汉", "成都",
            "重庆", "天津", "苏州", "西安", "长沙", "沈阳", "青岛", "郑州",
            "大连", "东莞", "宁波", "厦门", "福州", "无锡", "合肥", "昆明",
            "哈尔滨", "济南", "佛山", "长春", "温州", "石家庄", "南宁", "常州"
        ]
        
        if (!query || query.trim() === "") {
            return allCities.slice(0, 10).map(city => ({ cityName: city }))
        }
        
        var filtered = allCities.filter(city => city.includes(query))
        return filtered.slice(0, 10).map(city => ({ cityName: city }))
    }
    
    // 验证城市名称
    function validateCityName(cityName) {
        return cityName && cityName.trim().length > 0
    }
}