import '../../domain/entities/reciter.dart';
import '../../domain/entities/tafsir_option.dart';
import '../../domain/entities/juz_boundary.dart';
import '../../domain/entities/thematic_topic.dart';
import '../../domain/entities/bookmark_category.dart';

const int totalChapters = 114;
const int totalVerses = 6236;
const int totalJuz = 30;
const int totalHizb = 60;
const int totalPages = 604;

const List<ReciterInfo> reciters = [
  ReciterInfo(id: 7, chapterRecitationId: 7, verseRecitationId: 7, name: 'Mishary Rashid Alafasy', nameArabic: 'مشاري راشد العفاسي', style: 'حدر'),
  ReciterInfo(id: 1, chapterRecitationId: 1, verseRecitationId: 1, name: 'AbdulBaset AbdulSamad', nameArabic: 'عبدالباسط عبدالصمد', style: 'مجود'),
  ReciterInfo(id: 6, chapterRecitationId: 6, verseRecitationId: 6, name: 'Mahmoud Khalil Al-Husary', nameArabic: 'محمود خليل الحصري', style: 'مرتل'),
  ReciterInfo(id: 5, chapterRecitationId: 52, verseRecitationId: 0, name: 'Maher Al-Muaiqly', nameArabic: 'ماهر المعيقلي', style: 'حدر'),
  ReciterInfo(id: 3, chapterRecitationId: 13, verseRecitationId: 0, name: 'Saad Al-Ghamdi', nameArabic: 'سعد الغامدي', style: 'حدر'),
  ReciterInfo(id: 2, chapterRecitationId: 3, verseRecitationId: 3, name: 'Abdul Rahman Al-Sudais', nameArabic: 'عبدالرحمن السديس', style: 'حدر'),
  ReciterInfo(id: 10, chapterRecitationId: 10, verseRecitationId: 10, name: 'Saud Al-Shuraim', nameArabic: 'سعود الشريم', style: 'حدر'),
  ReciterInfo(id: 4, chapterRecitationId: 4, verseRecitationId: 4, name: 'Abu Bakr Al-Shatri', nameArabic: 'أبو بكر الشاطري', style: 'حدر'),
  ReciterInfo(id: 9, chapterRecitationId: 5, verseRecitationId: 5, name: 'Hani Ar-Rifai', nameArabic: 'هاني الرفاعي', style: 'حدر'),
  ReciterInfo(id: 12, chapterRecitationId: 104, verseRecitationId: 0, name: 'Nasser Al Qatami', nameArabic: 'ناصر القطامي', style: 'حدر'),
  ReciterInfo(id: 13, chapterRecitationId: 2, verseRecitationId: 2, name: 'AbdulBaset AbdulSamad (Mujawwad)', nameArabic: 'عبدالباسط عبدالصمد - مرتل', style: 'مرتل'),
  ReciterInfo(id: 14, chapterRecitationId: 8, verseRecitationId: 0, name: 'Ahmed Al-Ajmy', nameArabic: 'أحمد العجمي', style: 'حدر'),
  ReciterInfo(id: 15, chapterRecitationId: 12, verseRecitationId: 0, name: 'Yasser Ad-Dossari', nameArabic: 'ياسر الدوسري', style: 'حدر'),
  ReciterInfo(id: 16, chapterRecitationId: 9, verseRecitationId: 9, name: 'Mohamed Siddiq El-Minshawi', nameArabic: 'محمد صديق المنشاوي', style: 'مرتل'),
  ReciterInfo(id: 17, chapterRecitationId: 11, verseRecitationId: 0, name: 'Abdullah Basfar', nameArabic: 'عبدالله بصفر', style: 'حدر'),
  ReciterInfo(id: 18, chapterRecitationId: 14, verseRecitationId: 0, name: 'Ali Jaber', nameArabic: 'علي جابر', style: 'حدر'),
  ReciterInfo(id: 19, chapterRecitationId: 15, verseRecitationId: 0, name: 'Fares Abbad', nameArabic: 'فارس عباد', style: 'حدر'),
  ReciterInfo(id: 20, chapterRecitationId: 16, verseRecitationId: 0, name: 'Ibrahim Al-Akhdar', nameArabic: 'إبراهيم الأخضر', style: 'حدر'),
];

({int chapterApiId, int verseApiId}) getReciterApiIds(int internalId) {
  final reciter = reciters.where((r) => r.id == internalId).firstOrNull;
  if (reciter == null) return (chapterApiId: defaultReciterId, verseApiId: defaultReciterId);
  return (chapterApiId: reciter.chapterRecitationId, verseApiId: reciter.verseRecitationId);
}

const int defaultReciterId = 7;

const Map<String, int> tafsirIds = {
  'AL_SADI': 169,
  'AL_MUYASSAR': 16,
  'IBN_KATHIR': 160,
  'AL_BAGHAWI': 166,
};

const List<TafsirOption> tafsirOptions = [
  TafsirOption(id: 169, name: 'تفسير السعدي', author: 'عبدالرحمن السعدي'),
  TafsirOption(id: 16, name: 'التفسير الميسر', author: 'نخبة من العلماء'),
  TafsirOption(id: 160, name: 'تفسير ابن كثير', author: 'ابن كثير'),
  TafsirOption(id: 166, name: 'تفسير البغوي', author: 'البغوي'),
];

const List<JuzBoundary> juzBoundaries = [
  JuzBoundary(juz: 1, verseKey: '1:1', name: 'الفاتحة'),
  JuzBoundary(juz: 2, verseKey: '2:142', name: 'سيقول'),
  JuzBoundary(juz: 3, verseKey: '2:253', name: 'تلك الرسل'),
  JuzBoundary(juz: 4, verseKey: '3:93', name: 'لن تنالوا'),
  JuzBoundary(juz: 5, verseKey: '4:24', name: 'والمحصنات'),
  JuzBoundary(juz: 6, verseKey: '4:148', name: 'لا يحب الله'),
  JuzBoundary(juz: 7, verseKey: '5:82', name: 'لتجدن'),
  JuzBoundary(juz: 8, verseKey: '6:111', name: 'ولو أننا'),
  JuzBoundary(juz: 9, verseKey: '7:88', name: 'قال الملأ'),
  JuzBoundary(juz: 10, verseKey: '8:41', name: 'واعلموا'),
  JuzBoundary(juz: 11, verseKey: '9:93', name: 'يعتذرون'),
  JuzBoundary(juz: 12, verseKey: '11:6', name: 'وما من دابة'),
  JuzBoundary(juz: 13, verseKey: '12:53', name: 'وما أبرئ'),
  JuzBoundary(juz: 14, verseKey: '15:1', name: 'الحجر'),
  JuzBoundary(juz: 15, verseKey: '17:1', name: 'سبحان الذي'),
  JuzBoundary(juz: 16, verseKey: '18:75', name: 'قال ألم'),
  JuzBoundary(juz: 17, verseKey: '21:1', name: 'اقترب للناس'),
  JuzBoundary(juz: 18, verseKey: '23:1', name: 'قد أفلح'),
  JuzBoundary(juz: 19, verseKey: '25:21', name: 'وقال الذين'),
  JuzBoundary(juz: 20, verseKey: '27:56', name: 'أمن خلق'),
  JuzBoundary(juz: 21, verseKey: '29:46', name: 'اتل ما أوحي'),
  JuzBoundary(juz: 22, verseKey: '33:31', name: 'ومن يقنت'),
  JuzBoundary(juz: 23, verseKey: '36:28', name: 'وما أنزلنا'),
  JuzBoundary(juz: 24, verseKey: '39:32', name: 'فمن أظلم'),
  JuzBoundary(juz: 25, verseKey: '41:47', name: 'إليه يرد'),
  JuzBoundary(juz: 26, verseKey: '46:1', name: 'حم'),
  JuzBoundary(juz: 27, verseKey: '51:31', name: 'قال فما'),
  JuzBoundary(juz: 28, verseKey: '58:1', name: 'قد سمع'),
  JuzBoundary(juz: 29, verseKey: '67:1', name: 'تبارك'),
  JuzBoundary(juz: 30, verseKey: '78:1', name: 'عم'),
];

const List<BookmarkCategoryInfo> bookmarkCategories = [
  BookmarkCategoryInfo(id: 'general', label: 'عام', colorHex: '#a3a3a3'),
  BookmarkCategoryInfo(id: 'favorite', label: 'مفضلة', colorHex: '#f59e0b'),
  BookmarkCategoryInfo(id: 'dua', label: 'أدعية', colorHex: '#10b981'),
  BookmarkCategoryInfo(id: 'stories', label: 'قصص', colorHex: '#3b82f6'),
  BookmarkCategoryInfo(id: 'rulings', label: 'أحكام', colorHex: '#8b5cf6'),
  BookmarkCategoryInfo(id: 'memorize', label: 'حفظ', colorHex: '#ef4444'),
];

const List<ThematicTopic> thematicTopics = [
  ThematicTopic(
    id: 'paradise',
    name: 'الجنة ونعيمها',
    icon: 'park',
    description: 'آيات تصف الجنة ونعيمها وأهلها',
    verses: ['2:25', '3:15', '3:133', '3:136', '4:57', '9:72', '10:9', '13:35', '18:31', '22:23', '36:55', '37:43', '38:50', '43:71', '44:51', '47:15', '55:46', '55:54', '56:15', '76:12'],
  ),
  ThematicTopic(
    id: 'prophets',
    name: 'قصص الأنبياء',
    icon: 'menu_book',
    description: 'آيات تذكر قصص الأنبياء والمرسلين',
    verses: ['2:124', '2:246', '3:33', '6:84', '7:59', '7:65', '7:73', '7:85', '10:71', '11:25', '11:50', '11:61', '11:84', '12:4', '14:35', '15:51', '19:16', '19:41', '19:51', '21:51', '21:68', '21:76', '21:83', '26:10', '27:15', '28:7', '37:75', '37:99', '37:123', '38:17'],
  ),
  ThematicTopic(
    id: 'dua',
    name: 'الأدعية القرآنية',
    icon: 'front_hand',
    description: 'الأدعية المذكورة في القرآن الكريم',
    verses: ['1:5', '1:6', '2:127', '2:128', '2:201', '2:250', '2:286', '3:8', '3:16', '3:26', '3:147', '3:191', '3:193', '3:194', '7:23', '7:89', '7:126', '7:155', '10:85', '10:86', '14:35', '14:38', '14:40', '14:41', '17:24', '17:80', '20:114', '23:29', '23:97', '23:109', '23:118', '25:65', '25:74', '27:19', '40:7', '46:15', '59:10', '60:4', '66:8', '71:28'],
  ),
  ThematicTopic(
    id: 'rulings',
    name: 'آيات الأحكام',
    icon: 'balance',
    description: 'الآيات المتعلقة بالأحكام الشرعية',
    verses: ['2:183', '2:185', '2:196', '2:219', '2:222', '2:226', '2:228', '2:233', '2:234', '2:275', '2:282', '4:3', '4:7', '4:11', '4:12', '4:23', '4:24', '4:34', '4:43', '4:92', '4:101', '4:176', '5:1', '5:3', '5:5', '5:6', '5:33', '5:38', '5:45', '5:89', '5:90', '24:2', '24:4', '24:30', '24:31', '33:49', '33:53', '65:1', '65:4', '65:6'],
  ),
  ThematicTopic(
    id: 'tawheed',
    name: 'التوحيد وأسماء الله',
    icon: 'auto_awesome',
    description: 'آيات التوحيد وأسماء الله الحسنى',
    verses: ['2:163', '2:255', '3:2', '3:18', '6:3', '7:180', '17:110', '20:8', '21:22', '23:91', '28:70', '35:3', '39:4', '40:65', '42:11', '57:3', '59:22', '59:23', '59:24', '112:1', '112:2', '112:3', '112:4'],
  ),
  ThematicTopic(
    id: 'afterlife',
    name: 'اليوم الآخر',
    icon: 'hourglass_bottom',
    description: 'آيات تصف يوم القيامة والحساب',
    verses: ['6:73', '14:48', '18:47', '20:102', '22:1', '22:2', '22:7', '23:99', '23:100', '27:87', '36:51', '39:67', '39:68', '50:20', '50:22', '54:6', '56:1', '69:13', '70:8', '73:14', '75:7', '78:17', '79:34', '80:33', '81:1', '82:1', '84:1', '99:1', '100:9', '101:1'],
  ),
  ThematicTopic(
    id: 'science',
    name: 'الإعجاز العلمي',
    icon: 'science',
    description: 'آيات فيها إشارات علمية',
    verses: ['2:22', '10:5', '13:2', '16:15', '16:66', '16:68', '16:69', '21:30', '21:33', '23:12', '23:13', '23:14', '24:40', '24:43', '25:53', '27:88', '30:48', '31:10', '36:36', '36:38', '36:40', '39:5', '41:11', '51:47', '51:49', '55:19', '55:33', '57:25', '67:3', '71:15', '71:16', '78:6', '78:7', '86:11', '86:12'],
  ),
  ThematicTopic(
    id: 'patience',
    name: 'الصبر والتوكل',
    icon: 'fitness_center',
    description: 'آيات عن الصبر والثبات والتوكل على الله',
    verses: ['2:45', '2:153', '2:155', '2:156', '2:157', '3:17', '3:120', '3:125', '3:159', '3:186', '3:200', '7:128', '8:46', '10:109', '11:115', '12:18', '12:83', '13:22', '14:12', '16:42', '16:96', '16:127', '20:130', '29:59', '31:17', '38:44', '39:10', '40:55', '41:35', '42:43', '46:35', '65:3', '70:5', '73:10', '103:3'],
  ),
];

const List<TranslationOption> translationOptions = [
  TranslationOption(id: 16, name: 'التفسير الميسر', language: 'ar'),
  TranslationOption(id: 131, name: 'Sahih International', language: 'en'),
  TranslationOption(id: 20, name: 'Pickthall', language: 'en'),
  TranslationOption(id: 22, name: 'Yusuf Ali', language: 'en'),
  TranslationOption(id: 97, name: 'Maulana Maududi', language: 'ur'),
  TranslationOption(id: 77, name: 'Diyanet İşleri', language: 'tr'),
  TranslationOption(id: 136, name: 'Muhammad Hamidullah', language: 'fr'),
  TranslationOption(id: 33, name: 'Kemenag', language: 'id'),
];

class TranslationOption {
  final int id;
  final String name;
  final String language;

  const TranslationOption({
    required this.id,
    required this.name,
    required this.language,
  });
}
