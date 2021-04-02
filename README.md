# f_fridgehub / 냉장고 허브

![image](https://user-images.githubusercontent.com/73573249/113379246-f263fc00-93b3-11eb-8618-819fa481025b.png)

초보자를 위한 요리 추천 앱입니다.
냉장고 페이지에 당신이 가지고 있는 재료를 추가하세요.
그럼 앱이 당신을 위한 요리들과 레시피를 추천해줄거에요.


사용자는 앱에서 작성한 냉장고 안의 재료와 장바구니 등을 가족이나 그룹과 공유할 수 있습니다.
요리 재료를 장바구니에 추가해보세요. 당신이 참여한 그룹의 맴버가 퇴근하며 내용을 확인하고 구매해 올 수 있습니다.
그럼 당신이 먹고싶은 요리를 검색하고 장바구니에 재료를 추가해보세요!
가족과 함께 저녁식사를 즐기세요 :)


Cuisine Recommendation App for Beginners.
Add the ingredients you have to the refrigerator page.
Then the app will recommend dishes and recipes for you.

You can share this data with family or some group.
If you put the ingredients in your shopping cart, someone in your group can check it out and buy the ingredients.
Then? Choose what you want to eat and put ingredients in your shopping cart!
Enjoy dinner with your family!

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

* Lab: Write your first Flutter app
* Cookbook: Useful Flutter samples

For help getting started with Flutter, view our online documentation, which offers tutorials, samples, guidance on mobile development, and a full API reference.

## Feature Introduction / 기능 소개

**요리 추천을 위한 옵션을 지원합니다.
Some options for recommending dishes.**

![image](https://user-images.githubusercontent.com/73573249/113379119-9dc08100-93b3-11eb-9fb5-754dcefbb0d4.png)


1) 최대한 많은 재료를 소비하는 요리를 우선하여 추천.
2) 요리에 필요한 재료의 보유율이 높은 요리를 우선하여 추천.
3) 소금과 간장등의 양념을 제외한 재료의 보유율이 높은 요리를 우선하여 추천.


1) Recommended dishes that consume as much ingredients as possible.
2) Recommended dishes with a high retention rate of ingredients needed for cooking.
3) Recommended dishes with a high retention rate of ingredients except for salt and soy sauce.


**냉장고안의 재료를 관리하기 위한 기능
Ability to manage the ingredients in the refrigerator**

![image](https://user-images.githubusercontent.com/73573249/113379169-b7fa5f00-93b3-11eb-88fb-7e73547fb4d8.png)


1) 요리 재료의 검색 가능합니다.
2) 각각의 재료에 수량이나 유통기한 등을 메모할 수 있고 수정 할 수 있습니다.
3) 그룹의 맴버 모두가 냉장고 안의 재료와 장바구니안의 아이탬들을 함께 관리 할 수 있습니다.


1) Cooking ingredients can be searched
2) Each cooking ingredient can take notes such as quantity or expiration date.
3) Participating group members can manage items and shopping bags in the refrigerator together.


**레시피 검색을 위한 기능들
features for recipe searching**

![image](https://user-images.githubusercontent.com/73573249/113379213-d8c2b480-93b3-11eb-944a-07e06aaf1869.png)



1) 검색 단어 자동완성 기능
2) 레시피 페이지에서 재료 보유여부 확인 가능
3) 냉장고에 없는 재료만 장바구니에 추가 기능
4) 레시피 스크랩 기능


1) Automatic completion of search words
2) You can check the possession of ingredients on the recipe page.
3) Only ingredients that are not in the refrigerator are added to the shopping cart.
4) Recipe scrap function


**다양한 그룹 참여를 위한 기능
Ability to engage diverse groups**

![image](https://user-images.githubusercontent.com/73573249/113384548-3d384080-93c1-11eb-9852-d830ff15ea75.png)



1) 두개 이상의 그룹에 참여할 수 있으며 초대코드를 통해 맴버를 그룹에 초대할 수 있습니다.


1) You can participate in more than one group and invite members to the group through the invitation code.




## Used Library / 
  
  **1) sqflite **
  
  플러터를 위한 sqlite이며, 오프라인에서 DB활용을 위해 사용
  sqlite for the plutter, used for offline DB utilization
  
  **2) firebase_core: ^0.5.3**
  **3) cloud_firestore: ^0.14.4**
  
  냉장고안의 재료와 장바구니를 여러 사람들과 공유하기 위해 파이어베이스를 활용
  Using Firebase to share ingredients and shopping bags in the refrigerator with many people
  
  **4) google_sign_in: ^4.5.6**
  **5) firebase_auth: ^0.18.4+1**
  **6) flutter_signin_button: ^1.1.0**
  
  구글 계정의 프로필을 앱에서 사용하기위해 사용
  Using a profile from a Google account to use in an app
  
  **7) flutter_typeahead: ^1.9.1**
  
  검색창 위젯에 활용
  
  Leverage for search window widgets
  
  **8) cached_network_image: ^2.5.0**
  
  캐시 이미지 활용
  
  **9) flutter_staggered_grid_view: ^0.3.3**
  
  그리드뷰 위젯
  
  // bot_toast: ^3.0.5 - not used
  //  timeline_tile: ^1.0.0 - not used
  
  **12) animations: ^1.1.2**
  
  화면이나 위젯 전환등에 애니메이션 사용
  Use for some animations to switch pages or widgets
  
  **13) shared_preferences: ^0.5.12+4**
  
  앱 내의 설정과 최초 실행 등의 확인을 위해 사용
  Used to determine whether an app is set up and running for the first time, etc.
  
  **14) carousel_slider: ^3.0.0**
  
  소개 페이지 슬라이드
  Used for slide pages for introduction
  
  **15) auto_size_text: ^2.1.0**
  
  디바이스 크기에 따라 Text 영역의 overflow방지를 위해 사용
  Used to prevent overflow in Text area depending on device size
  
  // comment_tree: ^0.1.2 - not used
  
  **17) provider: ^4.3.3**
  
  상태관리에 사용
  Using for State Management


## License / 라이센스

1) 요리, 재료, 레시피에 대한 데이터 - 농림수산식품교육문화정보원 제공

