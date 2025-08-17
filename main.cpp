#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "include/commonDataType/WeatherDataModel.hpp"
#include "include/models/AppStateManager.hpp"
#include "include/services/WeatherDataService.hpp"
#include "include/viewmodels/NavigationViewModel.hpp"
#include "include/viewmodels/WeatherViewModel.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 注册C++类型到QML
    qmlRegisterType<WeatherDataModel>("WeatherAPP", 1, 0, "WeatherDataModel");
    qmlRegisterType<AppStateManager>("WeatherAPP", 1, 0, "AppStateManager");
    qmlRegisterType<WeatherDataService>("WeatherAPP", 1, 0, "WeatherDataService");
    qmlRegisterType<NavigationViewModel>("WeatherAPP", 1, 0, "NavigationViewModel");
    qmlRegisterType<WeatherViewModel>("WeatherAPP", 1, 0, "WeatherViewModel");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/WeatherAPP/QMLFrontend/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
