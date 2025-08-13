// RecentCitiesManager.qml - 最近城市数据管理器
import QtQuick

QtObject {
    id: citiesManager
    
    // 数据属性
    property var recentCities: []
    property int currentIndex: 0
    property int maxCities: 3
    property string currentViewMode: "today_weather"
    
    // 信号
    signal citiesChanged()
    signal currentCityChanged(var cityData)
    signal indexChanged(int newIndex)
    signal viewModeChanged(string viewMode)
    
    // 获取当前城市数据
    function getCurrentCity() {
        if (recentCities.length > 0 && currentIndex < recentCities.length) {
            return recentCities[currentIndex];
        }
        return {
            cityName: "暂无城市",
            temperature: "--°C",
            weatherIcon: "🌤️",
            weatherDescription: "未知",
            maxMinTemp: "--°C / --°C"
        };
    }
    
    // 添加新城市到最近访问列表
    function addRecentCity(cityData) {
        if (!cityData || !cityData.cityName) {
            console.warn("Invalid city data provided");
            return;
        }
        
        // 检查是否已存在
        var existingIndex = -1;
        for (var i = 0; i < recentCities.length; i++) {
            if (recentCities[i].cityName === cityData.cityName) {
                existingIndex = i;
                break;
            }
        }
        
        // 创建新的数组副本
        var newCities = recentCities.slice();
        
        if (existingIndex >= 0) {
            // 如果已存在，移除旧的
            newCities.splice(existingIndex, 1);
        }
        
        // 添加到最前面
        newCities.unshift(cityData);
        
        // 保持最多maxCities个城市
        if (newCities.length > maxCities) {
            newCities = newCities.slice(0, maxCities);
        }
        
        // 更新数据
        recentCities = newCities;
        currentIndex = 0;
        
        // 发送信号
        citiesChanged();
        indexChanged(currentIndex);
        currentCityChanged(getCurrentCityDataForView());
        
        console.log("Added city:", cityData.cityName, "Total cities:", recentCities.length);
    }
    
    // 切换到指定索引的城市
    function switchToCity(index) {
        if (index >= 0 && index < recentCities.length && index !== currentIndex) {
            currentIndex = index;
            indexChanged(currentIndex);
            currentCityChanged(getCurrentCityDataForView());
            console.log("Switched to city:", getCurrentCity().cityName);
        }
    }
    
    // 切换到下一个城市
    function switchToNext() {
        if (recentCities.length > 0) {
            var newIndex = (currentIndex + 1) % recentCities.length;
            switchToCity(newIndex);
        }
    }
    
    // 切换到上一个城市
    function switchToPrevious() {
        if (recentCities.length > 0) {
            var newIndex = (currentIndex - 1 + recentCities.length) % recentCities.length;
            switchToCity(newIndex);
        }
    }
    
    // 获取城市数量
    function getCityCount() {
        return recentCities.length;
    }
    
    // 检查是否有城市数据
    function hasCities() {
        return recentCities.length > 0;
    }
    
    // 获取指定索引的城市
    function getCityAt(index) {
        if (index >= 0 && index < recentCities.length) {
            return recentCities[index];
        }
        return null;
    }
    
    // 清空所有城市
    function clearCities() {
        recentCities = [];
        currentIndex = 0;
        citiesChanged();
            indexChanged(currentIndex);
            currentCityChanged(getCurrentCityDataForView());
    }
    
    // 移除指定城市
    function removeCity(cityName) {
        var newCities = [];
        var removedIndex = -1;
        
        for (var i = 0; i < recentCities.length; i++) {
            if (recentCities[i].cityName !== cityName) {
                newCities.push(recentCities[i]);
            } else {
                removedIndex = i;
            }
        }
        
        if (removedIndex >= 0) {
            recentCities = newCities;
            
            // 调整当前索引
            if (currentIndex >= recentCities.length) {
                currentIndex = Math.max(0, recentCities.length - 1);
            } else if (removedIndex < currentIndex) {
                currentIndex = Math.max(0, currentIndex - 1);
            }
            
            citiesChanged();
            indexChanged(currentIndex);
            currentCityChanged(getCurrentCityDataForView());
        }
    }
    
    // 设置视图模式
    function setViewMode(viewMode) {
        if (currentViewMode !== viewMode) {
            currentViewMode = viewMode;
            viewModeChanged(viewMode);
            // 重新发送当前城市数据以适应新的视图模式
            currentCityChanged(getCurrentCityDataForView());
        }
    }
    
    // 获取当前视图模式下的城市数据
    function getCurrentCityDataForView() {
        var baseData = getCurrentCity();
        
        switch(currentViewMode) {
            case "today_weather":
                var todayData = JSON.parse(JSON.stringify(baseData));
                todayData.viewMode = "today_weather";
                return todayData;
            case "temperature_trend":
                var trendData = JSON.parse(JSON.stringify(baseData));
                trendData.viewMode = "temperature_trend";
                trendData.weeklyForecast = getWeeklyForecast(baseData.cityName);
                return trendData;
            case "detailed_info":
                var detailData = JSON.parse(JSON.stringify(baseData));
                detailData.viewMode = "detailed_info";
                detailData.detailedInfo = getDetailedInfo(baseData.cityName);
                return detailData;
            case "sunrise_sunset":
                var sunriseData = JSON.parse(JSON.stringify(baseData));
                sunriseData.viewMode = "sunrise_sunset";
                sunriseData.sunriseInfo = getSunriseInfo(baseData.cityName);
                return sunriseData;
            default:
                return baseData;
        }
    }
    
    // 获取周天气预报数据
    function getWeeklyForecast(cityName) {
        // 模拟数据，实际应该从后端获取
        return {
            recentDaysName: ["今天", "明天", "后天", "周四", "周五", "周六", "周日"],
            recentDaysMaxMinTempreture: [
                "22°C / 12°C", "25°C / 15°C", "20°C / 10°C",
                "18°C / 8°C", "23°C / 13°C", "26°C / 16°C", "24°C / 14°C"
            ],
            recentDaysWeatherDescriptionIcon: ["☀️", "⛅", "🌧️", "☀️", "🌤️", "☀️", "⛅"]
        };
    }
    
    // 获取详细信息数据
    function getDetailedInfo(cityName) {
        // 模拟数据，实际应该从后端获取
        return {
            humidity: "65%",
            windSpeed: "12km/h",
            rainfall: "0mm",
            airQuality: "良好",
            airPressure: "1013hPa",
            uvIndex: "5"
        };
    }
    
    // 获取日出日落信息
    function getSunriseInfo(cityName) {
        // 模拟数据，实际应该从后端获取
        return {
            sunrise: "06:30",
            sunset: "18:45",
            dayLength: "12小时15分钟"
        };
    }
    
    // 初始化示例数据（可选）
    function initializeWithSampleData() {
        var sampleCities = [
            {
                cityName: "北京",
                temperature: "25°C",
                weatherIcon: "☀️",
                weatherDescription: "晴",
                maxMinTemp: "28°C / 18°C"
            },
            {
                cityName: "上海",
                temperature: "22°C",
                weatherIcon: "🌤️",
                weatherDescription: "多云",
                maxMinTemp: "25°C / 19°C"
            },
            {
                cityName: "广州",
                temperature: "28°C",
                weatherIcon: "🌦️",
                weatherDescription: "小雨",
                maxMinTemp: "30°C / 24°C"
            }
        ];
        
        recentCities = sampleCities;
        currentIndex = 0;
        citiesChanged();
        indexChanged(currentIndex);
        currentCityChanged(getCurrentCityDataForView());
    }
}