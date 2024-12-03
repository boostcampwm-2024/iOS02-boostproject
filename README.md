# ✈️ AirplaIN

> **같은 공간에서 인터넷 없이 나누는 자유로운 순간들**

<img width="1470" alt="Group 67" src="https://github.com/user-attachments/assets/a0581639-eed4-4dca-ae8c-d551bf291407">      
   
   
AirplaIN은 비행기나 크루즈 등 오프라인 환경에서도 주변 사람들과 연결할 수 있도록 설계된 근거리 통신 앱입니다.       

함께 화이트보드를 공유하고, 미니 게임을 즐기며 채팅을 나눠보세요.      

인터넷 연결 없이도 서로 이야기를 나눌 수 있습니다!

<br>

## 🎉 주요 기능

### 🖼️ 화이트보드 생성 및 참여
![화생참](https://github.com/user-attachments/assets/17a1d8c9-11b4-4bbd-bdb5-4250de2d43b0)


- **보드 생성 및 참여**: 근처 사용자가 만든 보드를 탐색해 참여하거나 새로운 보드를 생성할 수 있어요.

### 🎨 화이트보드 꾸미기
![화꾸](https://github.com/user-attachments/assets/5ceca358-35c4-47fc-b38d-8e3a1ab2d9aa)


- **드로잉**: 손쉽게 그림을 그리며 실시간으로 함께 꾸밀 수 있어요.
- **사진 및 텍스트 추가**: 사진과 텍스트로 보드를 더욱 개성 있게 채워보세요.

### 🎮 미니 게임
![웓](https://github.com/user-attachments/assets/43bad363-450c-49cd-9f84-2e0643e243e9)


- **함께하는 워들**: 사람들과 함께 워들 단어 맞추기 게임을 즐겨보세요!

### 💬 채팅
![챝](https://github.com/user-attachments/assets/c9321ba0-eea2-45d0-8e7c-76d0f3aa7573)


- **실시간 채팅**: 함께하는 사람들과 실시간으로 소통할 수 있습니다.

<br>

## 🛠️ 기술 스택 및 프로젝트 구조 
- **언어:** Swift
- **아키텍처:** MVVM, Clean Architecture
- **UI 프레임워크:** UIKit, SwiftUI
- **비동기 작업:** Combine, Swift Concurrency
- **근거리 통신:** Multipeer Connectivity Framework

- **모듈화 구조:**
![Group 97](https://github.com/user-attachments/assets/eb7750ab-9e2f-48b0-9c2a-8d17fa0efa3f)

    - App
    - Domain
    - Presentation
    - DataSource
    - NearbyNetwork
    - Persistence

<br>

## ⛓️ AirplaIN 데이터 흐름
- [📋 화이트보드 생성 · 참여 흐름](https://buttoned-package-f84.notion.site/d98b26eaa1144bb18ddcde7981e38427?pvs=4)
- [⚡️ 화이트보드 오브젝트 송수신 흐름](https://buttoned-package-f84.notion.site/a16c4d17c560450ebb5ce90fcd3c79fa?pvs=4)
- [💬 채팅 송수신 흐름](https://buttoned-package-f84.notion.site/b9148bc5c5d04ca5af9645b7aadabbea?pvs=4)

<br>

## 🚀 기술적 도전
| 키워드 | 제목 |
|------|------|
|`GitHub Actions`| [🏭 CI/CD 도입 과정](https://buttoned-package-f84.notion.site/CI-CD-b1591f5aa33e42808f902e7f4ab27aa7?pvs=4)|
|`Swift`| [🐊 Encodable과 Decodable 적용하기](https://buttoned-package-f84.notion.site/Enodable-Decodable-d4f8a58788e54663affbde7cd400541c?pvs=4)|
|`Core Animation`| [⬜️ CALayer와 서브클래스](https://buttoned-package-f84.notion.site/CALayer-d3bce979f1044fa8849eeb72b967571f?pvs=4)|
|`Multipeer Connectivity`| [📤 MPC 데이터 Handling](https://buttoned-package-f84.notion.site/MPC-URL-a0ca507a7a684275ad80bb7bf7dc430b?pvs=4)|
|`UIKit`| [📐 오브젝트 조작하기 1편 (hitTest, ResponderChain, UIGestureRecognizer)](https://buttoned-package-f84.notion.site/1-hitTest-ResponderChain-UIGestureRecognizer-bc2bce91622e404db13d31dfbd0898e8?pvs=4)|
|`UIKit`| [📐 오브젝트 조작하기 2편 (좌표계 변환과 제스쳐 처리)](https://buttoned-package-f84.notion.site/2-d20a00669cef4616a458a432aabc6a2e?pvs=4)|
|`UIKit`| [📐 오브젝트 조작하기 3편 (CGAffineTransform)](https://buttoned-package-f84.notion.site/3-CGAffineTransform-00175c361f7e44f2a918d5570d96e1a8?pvs=4)|
|`동시성`| [💥 우당탕탕 동시성 문제 해결하기](https://buttoned-package-f84.notion.site/a7b9d7fcb37343089ff584fcee593425?pvs=4)|

<br>

## ✈️ 파일럿s
|[S027 박승찬](https://github.com/eemdeeks)|[S047 이동현](https://github.com/taipaise)|[S068 최다경](https://github.com/ekrud99)|[S071 최정인](https://github.com/choijungp)|
|:--:|:--:|:--:|:--:|
| <img src="https://avatars.githubusercontent.com/u/87136217?v=4" width="120"> | <img src="https://avatars.githubusercontent.com/u/83569908?v=4" width="120"> | <img src="https://avatars.githubusercontent.com/u/99407953?v=4" width="120"> | <img src="https://avatars.githubusercontent.com/u/37467592?v=4" width="120"> | 
|딴 iOS |딩동 iOS|다우니 iOS|조이 iOS|

<br>

## 🎈 함께 해요
AirplaIN은 오프라인 환경에서도 소통의 즐거움을 제공합니다.

자세한 정보는 [Wiki](https://github.com/boostcampwm-2024/iOS02-AirplaIN/wiki)에서 확인하세요.

