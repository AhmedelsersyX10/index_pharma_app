# AGENTS.md — Index Pharma · قواعد العمل الموحدة

> اقرأ هذا الملف بالكامل أولاً في بداية كل مهمة. هذا هو المرجع الوحيد لقواعد العمل في المشروع.
> **اقرأ دائماً [INDEX_PHARMA_API_REFERENCE.md](INDEX_PHARMA_API_REFERENCE.md) قبل تنفيذ أي مهمة، ثم راجع قسم العقد الخاص بالمسار قبل أي تغيير يعتمد على الباك إند.** يحتوي مرجع API على العقود، دليل التكامل، والعينات التاريخية؛ لا توجد ملفات قواعد أو أدلة API موازية.

آخر تحديث: 2026-10-24. دمج قواعد الهندسة وسياسات المشروع دون تغيير صلاحيات أو حالة تنفيذ المهام.

## 1. المشروع والمراجع

| البند | القيمة |
|---|---|
| التطبيق | index_pharma؛ Flutter واحد للعملاء والموظفين: customer/pharmacist/admin/superadmin |
| Dart | ^3.11.4؛ راجع pubspec.yaml لأي تغيير |
| Backend المدقق | main عند cac43644406e075add3b99c867aa5f0458ccea9e؛ التفاصيل والأدلة في مرجع API |
| التصميم | stitch_designs/؛ دليل وليس مواصفات ملزمة للشكل |
| مرجع API الوحيد | INDEX_PHARMA_API_REFERENCE.md؛ فهرس القراءة في مقدمته |
| تصميم الشاشات | stitch_designs/docs/DESIGN_SYSTEM.md وSCREEN_DIRECTORY.md وCOMPONENT_INVENTORY.md؛ اقرأها قبل UI |
| قرارات المنتج والتقدم | Notion «Index Pharma — خطة التنفيذ» مع أحدث تعليمات صاحب المشروع |

**تعارض الأدلة:** افصل عقد السيرفر عن سياسة المنتج. الكود المؤرخ وأدلة تشغيل النسخة نفسها يسبقان عينات قديمة/غير مؤرخة. أي اختلاف بين الكود وتشغيل نفس النسخة يحتاج تحققاً ولا يحسم بالتخمين. قرارات صاحب المشروع الحالية تسبق التصميم؛ دعم السيرفر لا يلغي الاستبعادات. أمثلة الكود ليست captured runtime evidence.

## 2. افهم ثم خطط ونفّذ

1. افحص Git status واحفظ التغييرات المتتبعة وغير المتتبعة. اقرأ هيكل المشروع وpubspec.yaml وmain والـrouter والـDI والكود والاختبارات ذات الصلة قبل الكتابة.
2. راجع مرجع API دائماً؛ لا تخترع endpoint أو حقلاً أو صلاحية أو حالة أو مقياساً. اقرأ الكود أو القرارات الموجودة قبل طلب معلومة سبق توثيقها.
3. للفيتشرات الكبيرة: قدم خطة مرحلية قصيرة، الملفات المقترحة، تدفق البيانات والقرارات والاختبارات والنواقص الحقيقية؛ انتظر الموافقة قبل التنفيذ. العمل على ميزة مكتملة واحدة في كل مرة. إذا طلب المستخدم تحقيقاً فقط، لا تنفذ.
4. اشرح مسؤولية الطبقات والقرارات المهمة بلغة واضحة؛ لا تنشئ ملفات أو خدمات أو طبقات شكلية تلقائياً. احترم المراجعة ملفاً بملف إن طلبها المستخدم.
5. نفذ أصغر تغيير صحيح يعالج السبب؛ لا تعيد هيكلة غير المرتبط بالمهمة ولا تغير public interfaces دون حاجة ونطاق معتمد.
6. لا حذف أو reset أو أوامر مدمرة دون إذن صريح. لا تتخلص من شغل موجود ولا تعدل Git history أو تعمل commit/deploy لم يُطلب.
7. لا تعدل Backend/DB أو تعمل migration/seed/reset أو تنشئ بيانات لجمع مدخلات Flutter تلقائياً. أي كتابة حية تحتاج نطاقاً مأذوناً وبيانات اختبار معزولة، وليست جزءاً ضمنياً من قراءة العقود.
8. لا تغير حالات Notion أو تعلن مهمة منتهية دون دليل وصلاحية؛ فرّق بين خطة جاهزة وتنفيذ مكتمل واختبار حي.

## 3. المعمارية ومسؤوليات الطبقات

Clean Architecture + Feature-First؛ اتجاه الاعتماد Presentation → Domain ← Data.

```text
feature_name/
  data/
    datasources/       # API/storage access
    models/            # DTO parsing/serialization
    repositories/      # implementations and Failure/result mapping
  domain/
    entities/          # pure business objects
    repositories/      # contracts
    usecases/          # meaningful business operations when warranted
    services/          # pure rules/validation when needed
  presentation/
    cubit/             # feature state and coordination
    screens/           # existing project naming
    widgets/           # feature-specific UI
```

ترتيب التنفيذ: Entity/Model → DataSource → Repository → UseCase عند الحاجة → Cubit → UI. اتبع المسؤوليات دون فرض عدد ملفات أو إنشاء usecase يمرر النداء فقط دون مبرر.

- UI لا يستدعي Dio/DataSource/API/storage مباشرة؛ يعرض الحالة ويتعامل مع التفاعل فقط.
- Cubit لا يستدعي Dio أو DataSource مباشرة؛ ينسق Repository/UseCase. قواعد العمل والتحقق المعقد في domain قابلة للاختبار، لا داخل Widgets أو build/event handlers أو Cubit.
- Domain لا يستورد Flutter ولا يحتوي نصوص العرض؛ استخدم قيم حالات/translationKey وفق النمط القائم.
- DataSource يستخدم عميل الشبكة/التخزين المركزي؛ Repository يعزل العقد ويربط الأخطاء بـFailure/ApiResult القائمين دون فرض abstraction جديد.
- ضع المشترك فعلاً في core، ومنطق feature داخلها. لا تنقل screens إلى pages أو utils إلى routing لمجرد مطابقة قالب.

## 4. هيكل المشروع وتقنياته

```text
lib/
  main.dart
  core/
    constants/  di/  errors/  localization/  network/
    storage/  theme/  utils/  widgets/
  features/
    account/ auth/ cart/ categories/ checkout/ choose_branches/
    home/ language/ onboarding/ orders/ prescriptions/ products/
    settings/ splash/ staff/
test/                 # mirrors lib; helpers/pump_with_providers.dart
stitch_designs/       # code/, images/, docs/
assets/translations/  # ar.json/en.json
```

staff/ موجود في شجرة العمل الحالية؛ وجوده لا يثبت انتهاء كل المرحلة 4. حدّث هذا القسم عند إضافة feature فعلية.

| الغرض | التقنية والقيد |
|---|---|
| State | flutter_bloc؛ Cubit افتراضي، Bloc عند تعقيد الأحداث؛ لا استبدال بـGetX/Provider/Riverpod |
| Routing | go_router؛ redirects/guards مركزية، لا navigation من data/domain |
| DI | get_it؛ composition في core/di مع modules الـfeatures القائمة |
| HTTP/session | Dio المركزي ApiClient + PersistCookieJar + dio_cookie_manager |
| Storage | SharedPreferences عبر StorageService؛ Hive خيار عند ضرورة واعتماد الإضافة، غير مثبتة |
| Localization | easy_localization؛ ar/en وRTL/LTR |
| Images | cached_network_image؛ AppConfig.mediaUrl للمسار النسبي |
| Picking/scanning | image_picker/mobile_scanner مثبتتان؛ لا حزمة ماسح أخرى |

**المصدر الفعلي للحزم وإصداراتها pubspec.yaml**؛ لا تضف flutter_secure_storage أو socket/chart/screenutil أو Freezed/build_runner أو غيرها لمجرد وجود مثال. أضف حزمة فقط عند ضرورة غير مغطاة وبعد الاعتماد اللازم؛ لا upgrade شامل أو override مؤقت بلا دليل. لا تعدل pubspec.lock يدوياً. عند تغيير dependencies شغّل pub get والتحقق المناسب، ولا flutter clean أو حذف build عشوائياً.

## 5. State وDI والتوجيه والتخزين

- كل Cubit ذو نطاق واضح (route/screen/flow)؛ لا تجمع التطبيق كله في Cubit ولا تسجل كل Cubits في main. loading/success/empty/failure حالات واضحة.
- setState مسموح فقط لحالة محلية صغيرة كإظهار كلمة السر/expand؛ ليس business state أو حالة مشتركة.
- لا تنشئ services/dependencies داخل Widgets ولا GetIt fallback فيها؛ وفرها بالـconstructor أو BlocProvider/context provider القائم. تجنب التسجيل المكرر والنسخ غير المقصودة.
- احمِ الروابط المباشرة/deep links والعودة بعد الدخول، وليس إخفاء الأزرار فقط. مرر أقل بيانات لازمة للمسار دون كائنات ضخمة بلا سبب.
- التخزين وراء Service/DataSource؛ SharedPreferences للـflags/preferences الصغيرة وليس بيانات كبيرة/حساسة. لا اختيار Hive/قاعدة أخرى تلقائياً.
- افصل سلة العميل وفرع المتجر عن POS ونطاق الموظف؛ عند تغيير المستخدم/الفرع أبطل أو تجاهل الطلبات القديمة وأعد التحقق من الوردية/المخزون/السلة. أكد قبل إفراغ سلة غير فارغة.

## 6. الشبكة والأخطاء وحماية البيانات

- استخدم ApiClient المركزي وإعداد AppConfig؛ لا Dio جديد في كل repository أو إعداد مكرر. الرفع يستخدم uploadOptions بمهلة >=60s.
- اعتمد CookieJar؛ لا JWT في JSON ولا تخزين Bearer جديد. تفاصيل envelopes والأدوار والهيدر في مرجع API.
- لا secrets في العميل ولا logs لبيانات دخول/كوكي/token أو raw sensitive payloads؛ سجل metadata آمنة فقط.
- لا تعرض Exception.toString أو message خاماً؛ حوّل Failure إلى رسالة مترجمة بالعربية والإنجليزية. الرسائل قد تأتي بأي منهما وبأكثر من envelope.
- لا empty catch (_) ولا ابتلاع للأخطاء؛ عالج الفشل أو سجله بأمان. حافظ على Result/Failure contracts القائمة.
- لا تستخرج كمية من نص خطأ، ولا تفترض أن HTTP code يميز كل أسباب الفشل. عقود المتجر وPOS مختلفة؛ راجع endpoint المحدد.
- لا تكرر الكتابة تلقائياً بعد timeout/429؛ قد تكون نجحت. صمم منع duplicate submit والتعامل الصريح مع النتيجة المجهولة.
- الأسعار النهائية/التقارير/المخزون يملكها السيرفر حسب العقد؛ preview إن احتاجته الواجهة تقديري واضح في domain، وليس دليلاً على نجاح العملية.
- لا تعرض purchasingPrice/averageCost/costAtSale أو supplier financial details للعميل/الصيدلي. ترشيح العرض لا يعالج انكشافها من API.

## 7. جودة Dart والواجهة والتصميم

- أسلوب Dart الرسمي وflutter_lints؛ أسماء واضحة، كود مباشر قابل للفهم، functions/widgets بحجم مناسب. لا حيل معقدة أو abstractions/boilerplate دون قيمة.
- استخدم const حيث يناسب؛ تجنب dynamic غير الضروري وforced casts و! لإسكات analyzer. تحقق من null وJSON num عند حدود البيانات، ولا تكرر قواعد التحويل/التحقق دون سبب.
- لا TODO/FIXME أو كود تجريبي بلا شرح واعتماد؛ التعليقات للأسباب والقيود، وليست تكراراً للكود.
- لا Controllers/FocusNodes أو موارد مكلفة داخل build؛ dispose في الوقت الصحيح. ضيّق BlocBuilder/BlocSelector للجزء الذي يحتاج التحديث.
- Stitch دليل وليس مواصفات للشكل: نفذ كل بيانات/إجراءات/تحققات/حالات backend ضمن نطاق المهمة وسياسات الوصول والاستبعاد، ويمكن تحسين النص/layout/UX وحذف التكرار.
- لا نسخ Tailwind/CSS ولا اختراع design system. استخدم theme tokens والمكونات المشتركة: AppPageBar،AppTextField/AppSearchBar،CartActionButton حيث يناسب (دون ربط POS بسلة العميل).
- ألوان features/* وcore/widgets من context theme/colorScheme/clinicalTheme، لا AppColors مباشر أو ألوان ثابتة. تحقق من light/dark وresponsive layouts وtouch targets؛ لا أبعاد تكسر الشاشات.
- كل نص ظاهر عبر ar.json/en.json ومفاتيح متطابقة؛ RTL للعربي وLTR للإنجليزي، مع الاتجاه والمحاذاة والأيقونات والتنقل. لا raw API status إنجليزي كـfallback في العربي.
- الصور عبر AppConfig.mediaUrl دون /api في origin؛ cached_network_image وحالات loading/error. لا تكرر helper بمضيف ثابت في feature.
- لا ادعاءات طبية/تسويقية/قانونية دون مصدر؛ اسأل عن قرار المحتوى إن احتاجه النطاق.

## 8. سياسة المنتج والصلاحيات — قرارات صاحب المشروع

### 8.1 الأدوار والبيانات المالية (2026-10-24)

- المنتجات CRUD/رفع: admin/superadmin؛ التصنيفات CRUD: كل الموظفين؛ الفروع create/update: superadmin.
- purchasingPrice/averageCost/costAtSale: admin/superadmin فقط؛ احجب القيم عن presentation/diagnostics غير المسموح بها.
- التقارير بما فيها الربح وCOGS: pharmacist/admin مع permissions.viewReports === true، أو superadmin؛ لا تجاوز تلقائي للعلم للأدمن.
- أعد استخدام PermissionService والمفاتيح editPrice/manageTransfers/viewPrescriptions/viewReports/viewReturns؛ لا مفتاح مالي/منتج/تصنيف مخترع. لا تجعل flag يمنح إجراء يمنعه الدور.
- ظهور الروشتات يخضع لـviewPrescriptions حسب الخدمة القائمة؛ استثناء backend الحالي: superadmin يقرأ ولا يراجع بسبب فحص controller. العقد الدقيق في مرجع API §9.7.
- مفاتيح permissions ليست مفروضة حالياً على endpoints المرحلة 4؛ UI hiding ليس backend security. لا تفسر تسرب استجابة بأنه تصريح منتج.

### 8.2 الاستبعادات الملزمة لـV1

- ETA ورسوم التوصيل و«شحن مبرد» و«فاتورة ضريبية».
- التأمين، جرس الإشعارات/وعود إشعار، الدعم/الشات.
- إدخال الدفع بالبطاقة/الرقمي/الآجل/split؛ الدفع الجديد نقداً فقط. تسوية endingVisa للمقبوضات الموجودة ليست إضافة دفع بالبطاقة.
- المفضلة والتقييمات والعروض وإدخال الخصومات والطباعة.
- كود الفرع وساعات العمل؛ لا تمنع الحقول الفعلية isActive والتواريخ في الإدارة.
- باركود العميل مؤجل؛ باركود الموظف ضمن المرحلة 4.
- ادعاءات بلا مصدر أو نص إنجليزي ظاهر في واجهة عربية.

اقرأ سجلات الدفع/الخصم التاريخية بأمانة دون فتح إجراءات مؤجلة. manual/pull-to-refresh هو الافتراضي؛ polling/socket يحتاج موافقة منفصلة. لا تضف منع بيع المنتهي في Flutter دون قرار صاحب المشروع.

## 9. الاختبارات والتحقق والتسليم

- اختبارات ذات معنى لقواعد العمل والتحويلات وrepositories/cubits والصلاحيات والنطاق والأخطاء والسباقات. Regression test للخلل عند الإمكان، دون اختبارات تكرر implementation فقط.
- استخدم fakes/mocks للشبكة والكاميرا والتخزين؛ أعد استخدام test/helpers/pump_with_providers.dart حيث يناسب. لا تعتمد على شبكة أو hardware/timing في unit/widget tests.
- لتسليم تنفيذ Flutter: flutter analyze وflutter test بالكامل، وbuild عند صلته. targeted tests أثناء العمل؛ لا تدّع نجاح أمر لم تشغله أو اكتمال suite من output مبتور.
- التوثيق فقط: فحوص diff/روابط/أمثلة مناسبة، مع ذكر عدم تشغيل runtime tests وسببه.
- ميّز آلي/حي/جهاز فعلي وPASSED/FAILED/NOT RUN/BLOCKED. اختبار الكاميرا على جهاز حقيقي لا يثبت بالـmock أو المحاكي.
- QA يغطي guest/customer/pharmacist/admin/superadmin،flags null/false/true،فرع selected/all/missing/invalid/inactive،session401 مقابل403،empty/validation/network/server/stock/no-shift،duplicate submit وscope races.
- قبل التسليم راجع git diff والحالة ونطاق الملفات،المعمارية وDI،الـAPI الموثق،حالات loading/empty/error/success،الصور،نطاق الفرع،عدم تسرب التكلفة،الترجمات وRTL/LTR/light/dark،والاستبعادات والحزم.

**التقرير النهائي الإلزامي:** ما تغير ولماذا؛ الملفات المنشأة/المعدلة/المحذوفة؛ القرارات التقنية؛ الأوامر المنفذة ونتائجها الفعلية؛ المخاطر/المتابعة وما لم يُختبر؛ قائمة الاختلافات عن Stitch وأسبابها (أو لا اختلافات لتعديل توثيقي فقط). لا تخفِ قيد backend ولا تحول unknown إلى نجاح.
