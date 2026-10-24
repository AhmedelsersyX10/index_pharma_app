# تقرير إصلاحات واجهة العميل — 2026-10-24

## النتيجة

إصلاح عرض تاريخ الطلب، توحيد الفرع النشط عبر شاشات العميل، وتنظيف المحتوى غير الموثق. لا تغيير لعقود API أو Backend أو قاعدة البيانات أو حالات Notion أو سياسة منع بيع المنتجات المنتهية. لا حزم جديدة.

## الأسباب والقرارات

- بطاقة الطلب كانت تحول DateFormat إلى نص؛ أصبحت تنسق createdAt باللغة النشطة بنفس نمط التفاصيل. حفظنا سلوك المنطقة الزمنية الحالي دون تحويل تاريخ الطلب أو تغيير بياناته.
- كان لكل مسار BranchCubit مستقل، والحساب لا يستقبل الفرع. أصبح اختيار العميل مشتركاً عبر DI، وتستمع الشاشات لتغيراته. نطاق الموظف وPOS منفصلان.
- أزلنا fallback أول فرع عند غياب اختيار صالح. يجري التحقق من الفرع المحفوظ ومسح المعرّف القديم غير الصالح. أبقينا قاعدة اختيار الفرع الوحيد عند بدء الاستخدام دون اختيار محفوظ؛ لا تُستخدم لاستبدال اختيار محفوظ غير صالح بفرع مختلف.
- رتبنا عمليات حفظ الاختيار، وأضفنا إبطال نتائج الطلبات السابقة عند تغير النطاق، بما يشمل صفحات المنتجات والتفاصيل وإعادة المحاولة. التحميل له حالة مستقلة، ولا تسمح إعادة المحاولة بالرجوع إلى فرع قديم بعد إبطال النطاق.
- تأكيد تعارض السلة مستمر؛ إلغاؤه يحافظ على السلة والفرع. فشل حفظ الاختيار يظهر كفشل بدلاً من إعلان نجاحه.

## المحتوى

حُذفت أقسام الاعتماد والتراخيص والامتثال وضمان التخزين والتشفير، ساعات الفروع ووقت التوصيل المفترض والمخزون المكتمل، الخط الساخن الثابت والإصدار الوهمي. استُبدلت وعود الدعم المستمر والتتبع المباشر والتحقق الفوري والتذكيرات بصياغة تصف التصفح ورفع الروشتة ومتابعة الحالة فقط. أُزيل تقييم جودة الصورة الافتراضي لعدم وجود تقييم فعلي.

احتُفظ بأسماء المنتجات والمواد الفعالة ومعرّفاتها، وأسماء الفروع وعناوينها وهواتفها الفعلية. نُظفت العبارات التفسيرية الإنجليزية في العربية مثل OTC وActive Ingredient وRTL/LTR. عدّاد الطلب يصف مجموع الكميات بوحدات، وليس أصنافاً مختلفة.

محتوى بانر الرئيسية محلي ومحايد؛ إعدادات التسويق العامة لا تتجاوز سياسة العرض ولا تُفلتر بمطابقة كلمات هشة. لم نغيّر إعدادات السيرفر؛ أي اعتماد مستقبلي لنصوصه التسويقية يحتاج تحققاً منفصلاً. فُحصت صور onboarding الثلاث بصرياً ولم تتطلب استبدالاً لنصوص مدمجة.

## التحقق النهائي

| الفحص | النتيجة |
|---|---|
| flutter analyze --no-pub | PASSED؛ لا مشاكل، exit 0 |
| flutter test --no-pub --concurrency=4 --timeout 45s | PASSED؛ 600 اختبار، exit 0 |
| flutter build apk --debug --no-pub | PASSED؛ app-debug.apk، exit 0 |
| git diff --check | PASSED؛ exit 0 |
| مفاتيح ar/en | متطابقة؛ لا ثوابت ترجمة بلا قيمة |

تشمل الاختبارات الجديدة التاريخ والأرقام العربية والإنجليزية والتنقل من البطاقة، تغير الفرع بين الرئيسية والحساب واستعادته، الاختيارات غير الصالحة وفشل الحفظ وترتيب الكتابة، نتائج الطلبات والصفحات المتأخرة، إعادة المحاولة بعد إبطال الفرع، تأكيد تعارض السلة وإلغاؤه، وإعدادات التسويق الفارغة وغير الموثقة باللغتين والثيمين.

الجولة الأولى للبناء فشلت بسبب امتلاء القرص، ثم نجح البناء بعد تحسن المساحة. صُحح خطأ تجميع ظهر أثناء تعديل حالة التحميل قبل الجولة النهائية الناجحة.

## التحقق اليدوي والقيود

أبلغ صاحب المشروع أن تجربته نجحت. هذا تأكيد عام منه، وليس سجلاً لاختبارات أجهزة نفذها Agent. لم نثبت أو نجرب APK النهائي على المحاكي من جانب Agent بعد آخر التعديلات. لم ننشئ طلبات أو نرفع روشتات أو نعدل ملفاً شخصياً أو بيانات سيرفر، ولم نسجل بيانات الدخول أو بيانات العميل في التقرير.

## الاختلافات عن Stitch

إزالة أقسام الثقة والامتثال والوعود غير المدعومة، وتبسيط بطاقات الفروع لتعرض حقول العقد فقط، وإزالة تحديد الموقع الوهمي، وضبط المسافات وصياغة بانر الرئيسية باستخدام الثيم القائم. هذه تغييرات محتوى وإصلاح وظائف؛ تحسين UI/UX الشامل ما زال مؤجلاً.

## ملفات التنفيذ ضمن نطاق المهمة

- [assets/translations/ar.json](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/assets/translations/ar.json)
- [assets/translations/en.json](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/assets/translations/en.json)
- [lib/core/localization/app_locale_keys.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/core/localization/app_locale_keys.dart)
- [lib/core/utils/app_router.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/core/utils/app_router.dart)
- [lib/features/choose_branches/di/branch_di.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/choose_branches/di/branch_di.dart)
- [lib/features/choose_branches/presentation/cubit/branch_cubit.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/choose_branches/presentation/cubit/branch_cubit.dart)
- [lib/features/choose_branches/presentation/screens/branch_selection_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/choose_branches/presentation/screens/branch_selection_screen.dart)
- [lib/features/choose_branches/presentation/widgets/branch_card.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/choose_branches/presentation/widgets/branch_card.dart)
- [lib/features/choose_branches/presentation/widgets/branch_intro_section.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/choose_branches/presentation/widgets/branch_intro_section.dart)
- [lib/features/account/presentation/screens/account_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/account/presentation/screens/account_screen.dart)
- [lib/features/account/presentation/screens/edit_profile_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/account/presentation/screens/edit_profile_screen.dart)
- [lib/features/account/presentation/widgets/account_guest_view.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/account/presentation/widgets/account_guest_view.dart)
- [lib/features/account/presentation/widgets/account_preferences_section.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/account/presentation/widgets/account_preferences_section.dart)
- [lib/features/auth/presentation/screens/login_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/auth/presentation/screens/login_screen.dart)
- [lib/features/auth/presentation/screens/register_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/auth/presentation/screens/register_screen.dart)
- [lib/features/auth/presentation/widgets/auth_brand_header.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/auth/presentation/widgets/auth_brand_header.dart)
- [lib/features/auth/presentation/widgets/login_required_prompt.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/auth/presentation/widgets/login_required_prompt.dart)
- [lib/features/cart/presentation/screens/cart_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/cart/presentation/screens/cart_screen.dart)
- [lib/features/cart/presentation/widgets/cart_order_summary_card.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/cart/presentation/widgets/cart_order_summary_card.dart)
- [lib/features/checkout/presentation/widgets/checkout_summary_card.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/checkout/presentation/widgets/checkout_summary_card.dart)
- [lib/features/home/presentation/screens/home_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/home/presentation/screens/home_screen.dart)
- [lib/features/home/presentation/widgets/home_branch_selector_strip.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/home/presentation/widgets/home_branch_selector_strip.dart)
- [lib/features/home/presentation/widgets/home_hero_banner.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/home/presentation/widgets/home_hero_banner.dart)
- [lib/features/orders/presentation/widgets/order_card.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/orders/presentation/widgets/order_card.dart)
- [lib/features/prescriptions/presentation/screens/upload_prescription_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/prescriptions/presentation/screens/upload_prescription_screen.dart)
- [lib/features/products/presentation/cubit/product_details_cubit.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/products/presentation/cubit/product_details_cubit.dart)
- [lib/features/products/presentation/cubit/products_cubit.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/products/presentation/cubit/products_cubit.dart)
- [lib/features/products/presentation/screens/product_details_screen.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/products/presentation/screens/product_details_screen.dart)
- [lib/features/products/presentation/screens/products_page.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/products/presentation/screens/products_page.dart)
- [lib/features/products/presentation/widgets/product_details/product_details_showcase_card.dart](/Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/lib/features/products/presentation/widgets/product_details/product_details_showcase_card.dart)

حُذف المكونان غير المستخدمين: clinical_trust_footer.dart وhome_storage_guarantee_footer.dart بعد إزالة مواضع عرضهما. أُضيف customer_qa_regression_test.dart وcustomer_scope_races_test.dart، وحُدثت اختبارات الشاشات المتأثرة واختبارات اختيار الفرع والترجمة لتطابق السلوك المعتمد. هذا الملف يسجل النتيجة النهائية فقط.
