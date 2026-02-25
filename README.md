# CurrencyConverter

**실시간 데이터를 외부 API를 통해 받아오고**

그 데이터를 UI에 표시하고, 사용자의 입력을 바탕으로 **새로운 결과를 계산하여 보여주는 앱**을 만들었습니다.
UIKit 기반으로 **환율 목록 조회 + 검색 + 즐겨찾기 + 환율 계산** 기능을 제공하는 앱입니다.  
컬렉션뷰 리스트 UI와 MVVM 구조로 바인딩은 클로저를 사용했고, 즐겨찾기는 Core Data를 이용해 저장했습니다.

## ✨ Features

- **환율 목록 화면**
  - 환율 리스트 표시 (CollectionView + CompositionalLayout)
  - 통화 검색 (UISearchBar)
  - 즐겨찾기(⭐️) 토글 및 즐겨찾기 우선 정렬
  - 검색 결과가 없을 때 `검색 결과 없음` 안내

- **환율 계산기 화면**
  - 선택한 통화 정보 표시
  - 금액 입력 후 환율 계산 결과 표시
  - 잘못된 입력(빈 값/숫자 아님 등) 시 Alert 표시

- **데이터 저장 (Core Data)**
  - 즐겨찾기 통화 목록 저장/조회/삭제
  - (Entity) `CurrencyRate`, `AppState` 모델 포함
 
## 🧱 Architecture

- 화면 구성: `UIViewController` + 분리된 `UIView`(커스텀 뷰)
- 데이터/상태 전달: ViewModel의 클로저 바인딩 방식 사용  
  - `ViewController` → `CurrencyTableView`에 데이터 업데이트
  - `CurrencyTableView` → 셀/즐겨찾기 이벤트를 다시 상위로 전달
  - `RateCalculatorViewController` → ViewModel 계산 결과를 View에 반영

## 🧩 UI / Interaction 흐름

1. **ViewController**
   - `UISearchBar` + `CurrencyTableView` 배치
   - `ViewModel`의 `upDate` 콜백을 받아 리스트 업데이트
   - 셀 선택 시 `RateCalculatorViewController`로 push

2. **CurrencyTableView**
   - `UICollectionViewCompositionalLayout`로 리스트 레이아웃 구성
   - 업데이트 시 `Core Data`에서 즐겨찾기 목록을 읽어와 아이템에 반영
   - 즐겨찾기 우선 정렬(⭐️ 먼저, 그 다음 `currency` 알파벳)

3. **ListCell**
   - 통화/국가/환율 표시
   - 즐겨찾기 버튼(`CustomButton`) 이벤트를 `onTapFavorite`으로 외부 전달
   - `separator`를 `1px` 두께로 직접 구현 (`1 / UIScreen.main.scale`)

4. **RateCalculatorViewController / RateCalculatorView**
   - 선택한 통화 정보를 표시하고 금액 입력 후 계산 버튼으로 결과 출력
   - 입력 오류는 `Alert`로 사용자에게 안내
   
## 🗂 Key Files

- `ViewController.swift`
  - 환율 목록 화면 컨트롤러 (검색바 + 리스트)
- `CurrencyTableView.swift`
  - 환율 리스트 뷰(컬렉션뷰, 즐겨찾기 반영/정렬/빈 결과 처리)
- `ListCell.swift`
  - 리스트 셀 UI + 즐겨찾기 토글 이벤트 전달 + separator 구현
- `RateCalculatorViewController.swift`
  - 계산기 화면 컨트롤러 (버튼 액션/Alert)
- `RateCalculatorView.swift`
  - 계산기 화면 UI (입력/버튼/결과)
- `CoreDataManager.swift`
  - Core Data stack + 즐겨찾기 CRUD
- `CurrencyRate+CoreData*.swift`
  - 환율 데이터 Entity
- `AppState+CoreData*.swift`
  - 앱 상태 저장용 Entity

## ⚙️ Tech Stack

- UIKit
- SnapKit (AutoLayout)
- Then (UI 컴포넌트 초기화 편의)
- Core Data (즐겨찾기/상태 저장)


# 🛠 Trouble Shooting 정리

## 1️⃣ RateCalculatorViewModel 캡슐화 – `var item: Item { selectedItem }`

### ❗ 문제
`selectedItem`을 외부에서 직접 접근하면 `ViewModel`의 상태가 외부에 의해 변경될 수 있음.

### 🔍 원인
 내부 프로퍼티를 그대로 노출하면 `MVVM` 구조가 깨질 수 있음.

### ✅ 해결
```swift
private let selectedItem: Item
var item: Item { selectedItem }
```

- `selectedItem`은 내부에서만 수정
- 외부에는 `item`이라는 **읽기 전용 computed property**로 제공

### 📌 배운 점
- 캡슐화는 객체지향 설계의 핵심
- ViewModel은 상태 관리자 역할
- 읽기 전용 프로퍼티 패턴은 MVVM에서 자주 사용됨



## 2️⃣ CurrencyTableView – CompositionalLayout으로 리스트 구현

### ❗ 문제
기본 `list config`과 요구사항의 높이 고정이 충돌함

### 🔍 원인
`UICollectionViewCompositionalLayout`을 이용하여 직접 리스트 형태로 만들어서 사용함

### ✅ 해결
```swift
private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0
        section.contentInsets = .zero
        
        return UICollectionViewCompositionalLayout(section: section)
    }
```

- `UICollectionViewCompositionalLayout` 사용
- Section / Group / Item 구조로 리스트 구성

### 📌 배운 점
- 단순 리스트라도 확장성이나 다른 속성을 고려하면 `UICollectionViewCompositionalLayout`이 좋은 선택 같음



## 3️⃣ ListCell – Separator 직접 구현

### ❗ 문제
UICollectionView는 기본 separator를 제공하지 않음.
직접구현해야 함.

### 🔍 원인
CollectionView는 자유 레이아웃 기반이기 때문에 리스트에 있는 기본 구분선 기능이 없음.

### ✅ 해결
```swift
private func setupSeparator() {
        separatorView.backgroundColor = .separator
        contentView.addSubview(separatorView)

        let onePixel = 1.0 / UIScreen.main.scale
        let inset: CGFloat = 16

        separatorView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(inset)
            $0.trailing.equalToSuperview().inset(inset)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(onePixel)
        }
    }
```
- 각 기기마다 포인트에 대항하는 픽셀이 다르기 때문에 `let onePixel = 1.0 / UIScreen.main.scale` 이런식으로 1픽셀 두께를 직접 구현함.
- `separatorView`를 직접 추가
- AutoLayout으로 하단에 고정

### 📌 배운 점
- CollectionView는 기본 기능이 적지만 자유도가 높음
- 커스텀 separator 구현으로 UI 제어 가능
- UITableView와 구조적 차이 이해



## 4️⃣ CustomButton – UIControl Event

### ❗ 문제
즐겨찾기 CustomButton의 어떤 파라미터 상태를 기준으로 event를 전달할 것인가

### 🔍 원인
즐겨찾기가 눌렸다는 것을 셀에 보여줄 때와 실제로 즐겨찾기 내부 로직이 실행될 분기가 나뉘어야 함

### ✅ 해결
```swift
addAction(UIAction { [weak self] _ in
    guard let self = self else { return }
    self.isSelected.toggle()
    self.sendActions(for: .valueChanged)
}, for: .touchUpInside)
```

- `touchUpInside`는 사용자 터치 입력 이벤트이기 떄문에 사용자가 버튼을 눌렀다가 손을 떼면 실행
- `valueChanged`로 이 버튼의 상태가 변경되었음을 외부에 알리는 것

### 📌 배운 점
- 단순히 실행하는 버튼이 아니고 상태를 가지는 버튼일 경우 값을 `valueChanged`와 함께 사용하는게 더 적절함



## 5️⃣ CoreData – `newBackgroundContext()`로 Upsert 처리

### ❗ 문제
환율 데이터를 대량 저장할 때 UI가 멈추는 현상 발생.

### 🔍 원인
CoreData를 메인 Context에서 처리하면 메인 스레드를 점유하게 됨.

### ✅ 해결
```swift
let context = persistentContainer.newBackgroundContext()
```

- `Background Context`에서 `insert/update` 처리
- `UI` 스레드 차단 방지

### 📌 배운 점
- `CoreData`는 `Thread-safe`하지 않음
- `Context`는 자신이 생성된 `Queue`에서만 사용 가능
- 데이터 작업은 `Background`, `UI`는 `Main`에서 처리 강제해야함


# 📚 What I Learned
- MVVM의 기본 구조와 구현을 배웠습니다.
- ViewModel의 상태를 직접 노출하지 않고 읽기 전용으로 제공하며 캡슐화의 중요성을 체감했습니다.
- CollectionView를 리스트처럼 구성하며 CompositionalLayout의 확장성을 이해했습니다.
- Core Data를 사용할 때 Context 분리와 동시성 처리가 중요하다는 것을 배웠습니다.
- UIControl 이벤트를 단순 터치가 아닌 상태 변경 중심으로 설계하는 방법을 익혔습니다.
