#ifndef NAVIGATIONVIEWMODEL_HPP
#define NAVIGATIONVIEWMODEL_HPP

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>

class AppStateManager;

class NavigationViewModel : public QObject
{
    Q_OBJECT
    // 定义当前视图的属性，只读，当视图更改时发出通知
    Q_PROPERTY(QString currentView READ currentView NOTIFY currentViewChanged)
    // 定义可用视图列表的属性，只读，当可用视图列表更改时发出通知
    Q_PROPERTY(QVariantList availableViews READ availableViews NOTIFY availableViewsChanged)

public:
    explicit NavigationViewModel(QObject *parent = nullptr);
    ~NavigationViewModel();
    
    // 属性获取方法
    QString currentView() const { return m_currentView; } // 获取当前视图的ID
    QVariantList availableViews() const { return m_availableViews; } // 获取可用视图列表

    // 公共方法
    Q_INVOKABLE void initialize(QObject *stateManager); // 初始化视图模型，传入状态管理器
    Q_INVOKABLE bool navigateToView(const QString &viewId); // 导航到指定ID的视图，返回导航是否成功
    Q_INVOKABLE QVariantMap getCurrentViewInfo(); // 获取当前视图的信息
    Q_INVOKABLE QVariantMap getViewInfo(const QString &viewId); // 获取指定ID视图的信息
    Q_INVOKABLE QVariantList getAvailableViews(); // 获取可用视图列表
    Q_INVOKABLE bool isValidView(const QString &viewId); // 检查指定ID的视图是否有效
    Q_INVOKABLE QString getNextView(); // 获取下一个视图的ID
    Q_INVOKABLE QString getPreviousView(); // 获取上一个视图的ID
    Q_INVOKABLE bool navigateToNext(); // 导航到下一个视图，返回导航是否成功
    Q_INVOKABLE bool navigateToPrevious(); // 导航到上一个视图，返回导航是否成功
    Q_INVOKABLE bool isCurrentView(const QString &viewId); // 检查指定ID的视图是否为当前视图
    Q_INVOKABLE int getCurrentViewIndex(); // 获取当前视图在可用视图列表中的索引
    Q_INVOKABLE bool resetToDefault(); // 重置到默认视图，返回重置是否成功
    Q_INVOKABLE QString getViewPath(const QString &viewId); // 获取指定ID视图的路径
    Q_INVOKABLE bool addCustomView(const QVariantMap &viewInfo); // 添加自定义视图，传入视图信息，返回添加是否成功
    Q_INVOKABLE bool removeCustomView(const QString &viewId); // 移除自定义视图，传入视图ID，返回移除是否成功
    Q_INVOKABLE void cleanup(); // 清理视图模型资源

signals:
    void currentViewChanged();
    void availableViewsChanged();
    
    void viewChanged(const QString &viewId);
    void navigationRequested(const QString &viewId);

private slots:
    void onViewModeChanged(const QString &viewMode);

private:
    QString m_currentView;
    QVariantList m_availableViews;
    QStringList m_defaultViews;
    
    AppStateManager* m_appStateManager;
    
    void initializeAvailableViews();
    int findViewIndex(const QString &viewId) const;
};

#endif // NAVIGATIONVIEWMODEL_HPP