(여기의 내용은 '꼼꼼한 재은씨의 Swift: 기본편'의 'CHPATER 02: iOS 앱의 구조와 코코아 터치 프레임워크'의 내용을 공부하며 작성하였습니다)

# iOS 코어

OS에서도 kernel과 user로 나뉘고, 커널 인터페이스로 시스템 콜을 제공하듯이, iOS 앱도 Custom Code와 System Framework로 나뉘어서 각각 건드릴 수 있는 영역과 건드릴 수 없는 영역으로 나뉜다. 앱은 우리가 작성하는 커스텀코드와 시스템 프레임워크 사이에서 매우 복잡한 상호작용을 한다. 시스템 프레임워크는 iOS 기반의 앱이 실행하는 데에 필요한 기반 환경을 제공하는 역할이다.

앱은 기본적으로 시스템 프레임워크가 정의한 원리에 의해 동작하고 그 외에는 우리가 정의해서 구현할 수 있는 것이다. 이 말은 곧 우리가 신경쓸 부분만 잘 신경써주면 앱은 잘 굴러간다는 의미가 된다. 그러니 효율적으로 앱을 개발하기 위해서는 iOS 시스템의 기본 구조와 동작 원리를 잘 이해해야 한다. 우리가 운영체제를 열심히 공부하는 이유와도 비슷하다.

## 앱의 기본 구조

### 엔트리 포인트와 앱의 초기화 과정

오브젝티브-C도 C를 뿌리로 하고 있기에 main() 함수로부터 앱이 시작된다. 이를 엔트리 포인트(Entry Point, 시작점)이라고 한다. iOS 앱은 우리가 main() 함수를 작성하지 않고 Xcode 프로젝트를 생성하면 자동으로 만들어진다. 여기에는 이미 앱이 실행될 때 필요한 내용이 작성되어 있어서 우리는 main() 함수를 전혀 건드릴 필요가 없다. 

다음은 실제로 오브젝티브-C 기반의 Xcode 프로젝트를 생성했을 때 main.m 파일 안에 생성되는 main() 함수이다.

```objective-c
#import <UIKit/UIKit.h>
#import "AppDelgate.h"

int main(int argc, char* argv[]) {
  @autoreleasepool {
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}
```

main() 함수가 하는 일은 실행 시 시스템으로부터 전달받은 두 개의 인자값과 AppDelegate 클래스를 이용하여 UIApplicationMain() 함수를 호출하고, 그 결과로 UIApplication 객체를 반환한다. 이렇게 생성된 UIApplication 객체는 UIKit 프레임워크에 속해 있으므로 이후의 앱 제어권은 UIKit 프레임워크로 이관된다.

main() 함수가 C 기반 애플리케이션의 엔트리 포인트라면, UIApplicationMain() 함수는 그 중에서도 iOS 앱에 속하는 부분의 엔트리 포인트라고 할 수 있다. 앱이 동작하는데 핵심적인 객체들을 생성하는 프로세스를 핸들링하고 우리가 생성하고 작성하는 파일, 커스텀 코드를 호출해 줘 앱 생성 초기에 필요한 설정을 구현할 수 있게 해준다. 또 이벤트 루프를 실행시키기도 한다.

그리고 UIApplicationMain() 함수가 생성해서 반환하는 UIApplication 객체는 앱의 본체라고도 할 수 있는 객체다. 커스텀 코드나 객체, 앱 기능의 모든 것들이 UIApplication에 포함되어 있는 하위 객체이다. 그래서 디바이스에서 앱을 실행시키면 메모리에 올라가는 프로세스가 곧 이 UIApplication 객체라고 봐도 무방하다.

이 UIApplication 객체는 다양한 역할을 가지고 있고 우리는 이 클래스를 특별한 일이나 중대한 목적이 없다면 상속받는 것 없이 그대로 사용한다. 하지만 이 클래스를 그대로 상속 없이 사용하기에는 한계가 있다. 우리의 의도와 목적에 맞게 특별히 처리해야할 것도 있을 수 있기 때문이다. 그래서 UIApplication 객체는 AppDelegate라는 대리 객체을 두고 커스텀 코드를 처리할 수 있도록 약간의 권한을 준다. 이 AppDelegate 객체는 위임받은 일부 권한으로 커스텀 코드와 상호작용하는 역할을 담당하고, 우리가 필요한 코드를 구현할 수 있도록 도와준다. 예를 들어 앱이 최초 실행될 때 로드하는 과정을 마치는 순간에 AppDelegate 객체의 application(_:didFinishLaunchingWithOptions:) 메소드를 호출되는데, 이 메소드 안에 우리가 원하는 커스텀 코드를 작성해두면 실행이 되는 식이다. 그래서 앱을 실행시켰을 때 5초 정도 기다렸다가 실행되도록 sleep(5) 같이 적어줄 수 있는 것이다.

이 AppDelegate 객체는 iOS 앱 내에서 오직 하나의 인스턴스만 생성되도록 보장받는다. 그래서 앱이 시작될 때 생성되고 실행되는 동안 유지되고, 앱이 종료될 때 그때 함께 소멸된다. 이런 특징으로 AppDelegate 객체 내에 데이터를 저장하면 앱이 종료될 때까지 계속 데이터를 유지할 수도 있다. 그래서 AppDelegate 객체는 종종 앱의 초기 데이터 구조를 설정하기 위해 사용되기도 한다.

UIApplication 객체와 AppDelegate 객체가 연관되어 앱이 실행되는 전체 과정을 정리하면 다음과 같다.

> 1. main() 함수가 실행됨
> 2. main() 함수는 다시  UIApplicationMain() 함수를 호출함
> 3. UIApplicationMain() 함수는 앱의 본체에 해당하는 UIApplication 객체를 생성함
> 4. UIApplication 객체는 Info.plist 파일을 바탕으로 앱에 필요한 데이터와 객체를 로드함
> 5. AppDelegate 객체를 생성하고 UIApplication 객체와 연결함
> 6. 이벤트 루프를 만드는 등 실행에 필요한 준비를 진행함
> 7. 실행 완료 직전, 앱 델리게이트의 application(_:didFinishLaunchingWithOptions:) 메소드를 호출함

반면 스위프트는 C 기반의 언어가 아니기에 main.m 파일이 존재하지 않고 엔트리 포인트 역시 존재하지 않는다. 그래서 스위프트에서는 위의 1~5의 과정을 다음과 같은 어노테이션 표기로 대체한다.

```swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
  ...
  ...
}
```

iOS 시스템은 앱을 실행할 때 이 어노테이션(@UIApplicationMain)이 표시된 클래스를 찾아 델리게이트로 지정한다. 이후 진행되는 나머지 과정은 동일하다.

application(_:didFinishLaunchingWithOptions:) 메소드가 호출되고 앱이 실행되고 나면, 시스템 프레임워크의 이벤트 루프가 실행되면서 우리가 작성하는 이벤트 핸들에 의해 커스텀 코드로 연결된다. 여기서 말하는 이벤트 핸들은 @IBAction 메소드 등과 같은 것을 말한다. 일종의 콜백함수 개념.

이외에도 앱의 생명주기와 관련하여 여러 메소드들이 존재한다(앱이 메모리에서 제거될 때 호출되는 applicationWillTerminate(_:) 등과 같이).

## 앱의 상태 변화(= Life Cycle)

앱의 상태는 우리가 관여하는 영역이 아닌, 운영체제가 처리하는 영역이다. 예를 들어 사용자가 앱을 사용하던 중 전화가 오면 실행되던 앱은 꺼지듯 화면에서 사라지고 전화 화면이 대체하게 되는데, 이는 iOS가 전화라는 상황에 맞게 기존 앱의 상태를 변경한 것이다. 이처럼 iOS는 앱마다 모두 상태 변화를 제어하여 실행, 홈화면으로 내리고, 종료 등 처리한다. 다음은 iOS에서 앱이 가질 수 있는 상태값은 다음과 같다.

![iOS App's life cycle](https://docs-assets.developer.apple.com/published/95ed05c755/30f48607-bf65-42cf-983f-38a55bdd0d6a.png)

![iOS App's Life cycle](https://docs-assets.developer.apple.com/published/f55402f424/9dfc33e2-1072-4d21-88d9-34ad894b615f.png)

(위 이미지는 앱의 라이프 사이클을 scene으로 나타낸 것(스토리보드의 씬과 다르다). iOS 13 이상부터 지원하는 앱 기능중 scene이라는 기능이 새로 생김. 하나의 앱에서 여러 씬을 만들고 각 씬은 서로 다른 상태, 다른 라이프 사이클을 가질 수 있음)

(아래 이미지가 일반적인 앱 라이프사이클.)

* Not Running: 앱시 시작되지 않았거나 실행되었지만 시스템에 의해 종료된 상태
* Inactive: 앱이 전면에서 실행 중이지만, 아무런 이벤트를 받지 않고 있는 상태(active로 가는 중)
* Active: 앱이 전면에서 실행 중이며, 이벤트를 받고 있는 상태
* Background: 앱이 백그라운드에 있지만 여전히 코드가 실행되고 있는 상태. 대부분의 앱은 이 단계를 Suspended로 가기 전에 스쳐지나가듯 지나가지만, 파일 다운로드나 업로드, 연산처리, 음악 실행 등 여분의 실행 시간이 필요한 앱의 경우 특정 시간 동안 이 상태로 남아있게 되는 경우도 있음
* Suspended: 앱이 메모리에 유지되지만 실행코드가 없는 상태(홈화면에서 켜진 앱들 보면 멈춰있는 그런 상태). 메모리가 부족해지면 iOS 시스템은 포그라운드에 있는 앱의 여유 메모리 공간을 확보하기 위해 Suspended 상태에 있는 앱들을 특별한 알림 없이 정리한다.

앱은 특정한 순간에 위 상태 중 하나일 수도 있고, 하나의 상태에서 다른 상태로 옮겨가는 중일 수도 있다. 

앱의 실행 상태가 변화할 때마다 앱 객체는 앱 델리게이트에 정의된 특정 메소드를 호출한다. 그리고 이 메소드 내부에 적절한 커스텀 코드를 작성함으로써 우리가 원하는 작업이 실행되도록 할 수 있다. 앱이 종료되기 전에 데이터 저장이라든지, 앱이 백그라운드 상태로 내려갔을 때 메모리 정리를 한다든지 등이다. 

앱 상태에 따른 여러 가지 메소드들은 UIAppDelegateProtocol의 공식 문서를 참고하자. [공식문서](https://developer.apple.com/documentation/uikit/uiapplicationdelegate)

## 코코아 터치 프레임워크

iOS에서 제공하는 아이폰용 앱 개발에 사용되는 프레임워크이다. (Spring처럼 정교하게 잘 만들었으니 프레임워크의 전체적인 부분을 잘 이해하는 것이 앱을 제작하는 데 중요하다). 코코아 터치 프레임워크에는 UIKit 프레임워크, 파운데이션 프레임워크, WebKit 프레임워크 등이 있다. 앱을 만들고 실행할 때 필요한 iOS 기반 기술들은 모두 코코아 터치 프레임워크를 통해 구현된다.

운영체제의 역할이 그렇듯이, iOS도 디바이스마다 다른 하드웨어에 대해서 제어를 인터페이스로 제공해주는 역할을 한다. 그래서 개발자들은 하드웨어의 구체적인 동작방법을 알 필요 없이, iOS가 추상화해준 인터페이스를 통해서 개발을 할 수 있는 것이다. 그리고 이 iOS 인터페이스가 바로 코코아 터치 프레임워크니, 무엇보다도 코코아 터치 프레임워크를 잘 이해하는 것이 곧 아이폰 앱을 잘 개발할 수 있다고 볼 수 있다.

코코아 터치 프레임워크는 여러 가지 프레임워크들을 하위로 가지고 있는데 그중 양대산맥이 바로 UIKit 프레임워크와 파운데이션 프레임워크이다. 둘은 그 자체만으로 굉장히 내용이 많고 앱을 개발할 때 필수적이기 때문에 이 둘을 주 코코아 터치 프레임워크의 주 프레임워크로 간주한다. UIKit는 유저 인터페이스 도구를 통해 iOS 앱을 구현할 수 있는 방법을 제공하고, 파운데이션은 기본 데이터 형식, 컬렉션 및 앱의 기본 객체와 기반 기술을 제공하는 역할을 한다.

#### 코코아 프레임워크와 코코아 터치 프레임워크

> 코코아 프레임워크는 맥용 앱을 제작할 때 사용되는 프레임워크이다. 기존에 애플에는 OS X를 사용하는 매킨토시 데스크톱이 전부였다. 그래서 코코아 프레임워크에는 Appkit 프레임워크와 파운데이션 프레임워크가 양대산맥이었다(Appkit은 코코아 터치 프레임워크의 UIKit처럼 데스크톱용 UI를 담당). 이후 아이폰이 등장하고, 기존 코코아 프레임워크를 사용하기에는 많은 부분이 달라서 기존 것을 기반으로 코코아 터치 프레임워크가 생긴 것이다. 그래서 현재에도 둘은 많은 부분을 공유한다. 예를 들어 파운데이션 프레임워크는 둘 다 공유해서 사용한다.

## 프레임워크 계층 관계

코코아 터치 프레임워크에도 계층이 존재한다. 상위일수록 보다 추상화가 잘되어 있고 개발자가 사용하기 쉽다. 반면 하위로 갈수록 프레임워크는 하드웨어에 가까워져서 개발자가 다룰 수 있는 게 많아지지만 그만큼 번거로워 진다.

이러한 계층 구조 덕분에 앱을 개발할 때 로우 레벨에 대한 이해가 없어도 상위 프레임워크만을 통해 원하는 결과물을 쉽게 구현할 수 있다.

하지만 앱 개발 시 전적으로 상위 계층의 프레임워크만 사용하는 것은 아니다. 경우에 따라서 상위 레벨의 프레임워크가 지원하지 않는 기능을 구현해야 하는데 이 경우에는 하위 프레임워크를 사용하여 기능을 구현해야하기 때문이다. 그러니 어플리케이션 기능을 확정하기 위해서는 하위 프레임워크에 대한 구조와 사용 방법까지 충분히 숙지하고 있어야 한다.

iOS 프레임워크의 계층 관계는 다음과 같다.

![iOS Framework hierarchy](https://static.packt-cdn.com/products/9781849691307/graphics/1307_01_01.jpg)

### 코어 OS 계층

### 코어 서비스 계층

### 미디어 계층

### 코코아 터치 계층

# 앱을 구성하는 핵심 객체들

## iOS 유저 인터페이스의 표현 구조

## 뷰 컨트롤러

## 뷰 컨트롤러의 상태 변화와 생명 주기
