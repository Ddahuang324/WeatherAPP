# Animations 动画效果模块

这个文件夹包含了项目中所有的美化动画和视觉效果组件，实现了UI与动画效果的完全解耦。

## 架构设计

### 三层架构
1. **基础效果层**: GlassEffect, EdgeBlurEffect, GradientBackground
2. **组合样式层**: SidebarStyle, RecentCitiesPagerStyle, ContentAreaStyle
3. **UI逻辑层**: 各个layout组件只关注功能逻辑

## 组件说明

### GlassEffect.qml
玻璃模糊效果组件，提供毛玻璃背景效果。

**主要属性：**
- `blurSource`: 模糊源对象
- `blurRadius`: 模糊半径 (默认: 32)
- `blurIntensity`: 模糊强度 (默认: 1.0)
- `glassColor`: 玻璃着色 (默认: 半透明蓝色)
- `borderColor`: 边框颜色
- `cornerRadius`: 圆角半径

**使用示例：**
```qml
GlassEffect {
    anchors.fill: parent
    blurSource: backgroundItem
    blurRadius: 48
    glassColor: Qt.rgba(160, 213, 229, 0.59)
}
```

### EdgeBlurEffect.qml
边缘模糊阴影效果组件，为组件添加边缘阴影。

**主要属性：**
- `enableTop/Bottom/Left/Right`: 控制各边是否启用阴影
- `topHeight/bottomHeight/leftWidth/rightWidth`: 各边阴影尺寸
- `shadowColor`: 阴影颜色
- `shadowOpacity`: 阴影透明度

**使用示例：**
```qml
EdgeBlurEffect {
    anchors.fill: parent
    enableLeft: false
    shadowColor: Qt.rgba(0, 0, 0, 0.1)
}
```

### GradientBackground.qml
渐变背景组件，提供可配置的渐变背景效果。

**主要属性：**
- `startColor/endColor`: 渐变起始和结束颜色
- `gradientOrientation`: 渐变方向
- `cornerRadius`: 圆角半径
- `enableTexture`: 是否启用纹理效果
- `textureColor/textureOpacity`: 纹理颜色和透明度

**使用示例：**
```qml
GradientBackground {
    anchors.fill: parent
    startColor: "#38bdf8"
    endColor: "#3b82f6"
    enableTexture: true
}
```

### 高级样式组件

#### SidebarStyle.qml
侧边栏专用样式组件，封装了侧边栏的所有视觉效果。

**使用示例：**
```qml
SidebarStyle {
    anchors.fill: parent
    blurSource: backgroundItem
}
```

#### RecentCitiesPagerStyle.qml
最近城市分页器专用样式组件。

**使用示例：**
```qml
RecentCitiesPagerStyle {
    anchors.fill: parent
    blurSource: backgroundItem
}
```

#### ContentAreaStyle.qml
内容区域专用样式组件。

**使用示例：**
```qml
ContentAreaStyle {
    anchors.fill: parent
}
```

## 使用方法

1. 在QML文件中导入animations模块：
```qml
import "../animations"
```

2. 直接使用组件：
```qml
Rectangle {
    GlassEffect {
        anchors.fill: parent
        // 配置属性...
    }
}
```

## 优势

1. **代码复用**: 避免在每个组件中重复编写相同的美化效果代码
2. **统一管理**: 所有视觉效果集中管理，便于维护和更新
3. **灵活配置**: 通过属性配置，适应不同场景的需求
4. **解耦设计**: UI逻辑与视觉效果分离，提高代码可维护性
5. **性能优化**: 统一的组件实现，便于后续性能优化