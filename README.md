# EasyRest

Add to Podfile

```ruby
pod 'EasyRest', :git => 'https://github.com/ingdanni/EasyRest'
```

In the `AppDelegate` file, add configuration in `didFinishLaunchingWithOptions` method:

```swift
APIManager.shared.baseUrl = "https://jsonplaceholder.typicode.com"
```

### Create API class

```swift
class API {

    static let shared = API()

    private init() {}

    let posts = Entity(name: "posts")

}
```

### Make a request

```swift
API.shared.posts.get {
    data, error in

    if let data = data {
        print(data)
    }

    if let error = error {
        print(error)
    }
}
```
