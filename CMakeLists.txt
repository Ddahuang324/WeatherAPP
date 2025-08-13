cmake_minimum_required(VERSION 3.16)

project(WeatherAPP VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick QuickEffects QuickControls2 Charts)

qt_standard_project_setup()

qt_add_executable(appWeatherAPP
    main.cpp
)

qt_add_qml_module(appWeatherAPP
    URI WeatherAPP
    VERSION 1.0
    QML_FILES
        QMLFrontend/Main.qml
        QMLFrontend/layouts/SideBar.qml
        QMLFrontend/layouts/ContentArea.qml
        QMLFrontend/layouts/RecentCitiesPager.qml
        QMLFrontend/animations/GlassEffect.qml
        QMLFrontend/animations/EdgeBlurEffect.qml
        QMLFrontend/animations/GradientBackground.qml
        QMLFrontend/animations/SidebarStyle.qml
        QMLFrontend/animations/RecentCitiesPagerStyle.qml
        QMLFrontend/animations/ContentAreaStyle.qml
        QMLFrontend/animations/qmldir
        QMLFrontend/components/common/WindowControls.qml
        QMLFrontend/components/common/SearchBar.qml
        QMLFrontend/components/common/DragArea.qml
        QMLFrontend/components/common/CityNameLabel.qml
        QMLFrontend/components/navigation/MenuItem.qml
        QMLFrontend/components/navigation/NavigationMenu.qml
        QMLFrontend/components/TodaysWeather/TodaysWeatherItem.qml
        QMLFrontend/components/TempratureTrend/TempratureTrendItem.qml
        QMLFrontend/components/TempratureTrend/TempratureTrendItemDelegate.qml
        QMLFrontend/components/TempratureTrend/TemperatureChart.qml
        QMLFrontend/components/DetailedInfo/DetailedInfoItem.qml
        QMLFrontend/components/DetailedInfo/DetailedInfoLabel.qml
        QMLFrontend/components/DetailedInfo/qmldir
        QMLFrontend/components/qmldir
        QMLFrontend/views/TodayWeatherView.qml
        QMLFrontend/views/TemperatureTrendView.qml
        QMLFrontend/views/DetailedInfoView.qml
        QMLFrontend/views/SunriseSunsetView.qml
        QMLFrontend/views/qmldir
)

set_target_properties(appWeatherAPP PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appWeatherAPP
    PRIVATE Qt6::Quick Qt6::QuickEffects Qt6::QuickControls2 Qt6::Charts
)

include(GNUInstallDirs)
install(TARGETS appWeatherAPP
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
