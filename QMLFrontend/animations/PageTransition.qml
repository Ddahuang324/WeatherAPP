import QtQuick

Item {
    id: pageTransition
    
    // 公开属性
    property Item currentView: null
    property Item nextView: null
    property int duration: 400
    property int fadeOutDuration: 300
    property int fadeInDuration: 300
    property var easingType: Easing.OutCubic
    property bool running: fadeAnimation.running
    
    // 信号
    signal transitionStarted()
    signal transitionCompleted()
    
    // 淡入淡出动画
    ParallelAnimation {
        id: fadeAnimation
        
        // 当前视图淡出
        NumberAnimation {
            target: pageTransition.currentView
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: pageTransition.fadeOutDuration
            easing.type: pageTransition.easingType
        }
        
        // 下一个视图淡入
        NumberAnimation {
            target: pageTransition.nextView
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: pageTransition.fadeInDuration
            easing.type: pageTransition.easingType
        }
        
        onStarted: {
            if (pageTransition.nextView) {
                pageTransition.nextView.visible = true
                pageTransition.nextView.opacity = 0.0
            }
            pageTransition.transitionStarted()
            console.log("Page transition started")
        }
        
        onFinished: {
            pageTransition.transitionCompleted()
            console.log("Page transition completed")
        }
    }
    
    // 公开方法
    function startTransition() {
        if (currentView && nextView) {
            fadeAnimation.start()
        } else {
            console.warn("PageTransition: currentView or nextView is null")
        }
    }
    
    function stopTransition() {
        fadeAnimation.stop()
    }
    
    function setDuration(newDuration) {
        duration = newDuration
        fadeOutDuration = newDuration / 2
        fadeInDuration = newDuration / 2
    }
    
    function setFadeOutDuration(newDuration) {
        fadeOutDuration = newDuration
    }
    
    function setFadeInDuration(newDuration) {
        fadeInDuration = newDuration
    }
    
    function setEasingType(newEasing) {
        easingType = newEasing
    }
}