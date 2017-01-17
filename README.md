# RMRPullToRefresh
==

Репозиторий pull to refresh контрола для UIScrollView, UITableView, UICollectionView для платформы iOS.



<img src="https://dl.dropboxusercontent.com/u/69633554/RMRPullToRefresh/pullSuccessBottom.gif" width="262" height="468">
<img src="https://dl.dropboxusercontent.com/u/69633554/RMRPullToRefresh/pullNoUpdatesTop.gif" width="262" height="468">
<img src="https://dl.dropboxusercontent.com/u/69633554/RMRPullToRefresh/pullErrorTop.gif" width="262" height="468">

Как установить?
--------

`pod 'RMRPullToRefresh', :git => "git@git.redmadrobot.com:helper-ios/RMRPullToRefresh.git"`

Как добавить?
--------

```swift
import RMRPullToRefresh

var pullToRefresh: RMRPullToRefresh?

pullToRefresh = RMRPullToRefresh(scrollView: tableView, 
                                   position: .Top) { [weak self] _ in // .Top или .Bottom
            // Загрузка данных
            self?.service.load() { _ in
                // Завершение загрузки
                self?.pullToRefresh?.stopLoading()
            })
        }
```

Чтобы завершить анимацию, необходимо выполнить:
```swift
pullToRefresh?.stopLoading() // Завершиться с результатом .Success
```
или
```swift
pullToRefresh?.stopLoading(.Success) // .Success, .NoUpdates, .Error
```

Позиции
--------
```swift
public enum RMRPullToRefreshPosition: Int {
    case Top // Для добавления контрола сверху скрола
    case Bottom // Для добавления контроль снизу скрола
}
```

Состояния
--------
```swift
public enum RMRPullToRefreshState: Int {
    case Stopped // Нет скролинга, нет загрузки
    case Dragging // Скролинг
    case Loading // Загрузка
}
```

Тип результата
--------
```swift
public enum RMRPullToRefreshResultType: Int {
    case Success // Загрузка завершилась успешно и есть обновления
    case NoUpdates // Загрузка завершилась успешно, но обновлений нет
    case Error // Загрузка завершилась с ошибкой
}
```

Как кастомизировать?
--------

Существует два метода для конфигурации кастомных view:
```swift
func configureView(view :RMRPullToRefreshView, state:RMRPullToRefreshState, result:RMRPullToRefreshResultType) 
```

```swift
func configureView(view :RMRPullToRefreshView, result:RMRPullToRefreshResultType) // Будет сконфигурировано для состояний .Loading, .Dragging и .Stopped
```

Пример:
```swift
// Конфигурируем view для состояний .Dragging и .Loading для результата .Success
if let pullToRefreshView = BeelineView.XIB_VIEW() {
            pullToRefresh?.configureView(pullToRefreshView, state: .Dragging, result: .Success)
            pullToRefresh?.configureView(pullToRefreshView, state: .Loading, result: .Success)
        }
```

Кастомная view должна наследоваться от класса RMRPullToRefreshView и для анимирования должны быть реализованы методы протокола RMRPullToRefreshViewProtocol:

```swift
// Подготовка к анимации загрузки
// Вызываться перед beginLoadingAnimation()
public func prepareForLoadingAnimation(startProgress: CGFloat) {}

// Начало анимации
public func beginLoadingAnimation() {} 
    
// Завершение анимации
// Будет вызываться сразу после завершения загрузки
public func willEndLoadingAnimation() {}

// Завершение анимации
// Будет вызывать через время, равное hideDelay после завершения загрузки
// @param hidden - флаг будет скрыт контрол или нет после завершения анимации
public func didEndLoadingAnimation(hidden: Bool) {}
    
// Изменения прогресса скролинга
public func didChangeDraggingProgress(progress: CGFloat) {}
```

Настройки
--------


Для задания RedMadRobot дизайна: 

```swift
pullToRefresh?.setupDefaultSettings()
```

Изменить высоту (по умолчанию 90.0):

```swift
pullToRefresh?.height = 70.0
```

Изменить цвет бэкграунда (по умолчанию whiteColor()):
```swift
pullToRefresh?.backgroundColor = UIColor(red: 16.0/255.0, 
                                       green: 192.0/255.0, 
                                        blue: 119.0/255.0, 
                                       alpha: 1.0)
```
Для задания времени закрытия контрола (по умолчанию 0.0):
```swift
pullToRefresh?.setHideDelay(5.0, result: .Success) // .Success, .NoUpdates, .Error
```


Если не хотим скрывать контрол с ошибкой (не забудьте установить view для .Error):
```swift
pullToRefresh?.hideWhenError = false
```
<img src="https://dl.dropboxusercontent.com/u/69633554/RMRPullToRefresh/pullErrorTopNoHide.gif" width="262" height="468">
