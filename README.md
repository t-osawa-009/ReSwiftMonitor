# ReSwiftMonitor

[ReSwift](https://github.com/ReSwift/ReSwift) middleware that can be used to communicate with redux-dev tools. It has been tested with  [redux-devtools cli](https://github.com/reduxjs/redux-devtools/tree/main/packages/redux-devtools-cli), but it should work with [other monitors]( https://github.com/zalmoxisus/remote-redux-devtools#monitoring) too.
This project is heavily inspired by the [katanaMonitor-lib-swift](https://github.com/bolismauro/katanaMonitor-lib-swift). 

![gif](https://github.com/takuchantuyoshi/ReSwiftMonitor/blob/master/GIF/reswiftmonitor_sample.gif?raw=true)

#### Dependencies 

Install the redux-devtools cli once:

```sh
npm install -g @redux-devtools/cli
```

Run the standalone application (every time you want to use the monitor)

```sh
redux-devtools --open
```

#### Project Integration
The monitor is shipped using Cocoapods.

##### Pod
Add the pod `ReSwiftMonitor`

```ruby
pod 'ReSwiftMonitor', :configurations => ['Debug']
```
##### Carthage
```
github "t-osawa-009/ReSwiftMonitor"
```

The middleware should be used in debug configurations only.

In your application, conditionally add the middleware. Here, for instance, we use the `DEBUG` macro to conditionally add the middleware in debug configurations only:

```swift
var middleware: [Middleware<AppState>] = {
    var _middleware: [Middleware<AppState>] = []
    #if DEBUG
    let monitorMiddleware = MonitorMiddleware.make(configuration: Configuration())
    _middleware.append(monitorMiddleware)
    #endif
    return _middleware
}()

let store = Store<AppState>(reducer: AppState.reducer(), state: AppState(), middleware: middleware)

```



#### Usage

* Launch `redux-devtools` in your terminal
* Click `settings` and make sure that `Use custom local server` is selected and the configuration is the proper ones (by default localhost and 8000). This is the UI where actions will appear
* Launch your Reswift application

#### More
- [ReSwiftMonitorBrowser](https://github.com/t-osawa-009/ReSwiftMonitorBrowser) ReSwiftMonitor Browser for iOS, Mac OS

#### Libraries Used
- [sacOO7/socketcluster-client-swift](https://github.com/sacOO7/socketcluster-client-swift)
- [ReSwift](https://github.com/ReSwift/ReSwift)
- [HandyJSON](https://github.com/alibaba/HandyJSON)
- [Starscream](https://github.com/daltoniam/Starscream)

### Contributing
There's still a lot of work to do here. We would love to see you involved. You can find all the details on how to get started in the [Contributing Guide](https://github.com/t-osawa-009/ReSwiftMonitor/blob/master/CONTRIBUTING.md).

### License

ReSwiftMonitor is released under the MIT license. See LICENSE for details.
