# Noor El-Quran 2026 — UI/UX Audit Final Report

> **Scope:** UI/UX, Navigation, Text/Fonts, Alignment/RTL, and User Experience (plus Theme/Color, Accessibility, and Consistency) across all 93 Dart files in `lib/`.
> **Method:** 14 parallel finders (9 feature-area + 5 cross-cutting lenses) raised candidate flaws; each was then **adversarially re-checked against the actual source** (a skeptic refuted anything the code didn't prove), a completeness-critic round hunted for gaps, and survivors were de-duplicated and severity-adjudicated. Inline parentheticals such as *"(merged)"* or *"(the original framing is overstated)"* record where claims were consolidated or down-rated during verification.
> **Result:** 143 verified flaws. No crashes occur in normal use; the highest-severity items are data-loss / broken-input bugs and systemic theming & localization gaps. Line numbers reference the repository state on branch `claude/ui-ux-audit-bub3da`. A machine-readable list of every finding is in [`ui_ux_audit_findings.json`](./ui_ux_audit_findings.json).

## Executive Summary

Noor El-Quran 2026 is a functionally complete, Arabic-first Quran reader with a clean-architecture foundation and a rich feature set (flowing/mushaf reading, audio with 18 reciters, khatmah planning, memorization, thematic browsing, stats). However, the audit surfaced **143 verified flaws** clustered around five recurring root causes that systematically undermine an otherwise solid app. The single largest theme is **theme-token bypass**: roughly 66 hardcoded `Color(0xFFD97706)` literals plus divergent `Colors.amber[700]`/`Colors.amber` swatches across ~21 files mean the app's carefully-defined per-theme accents (notably the brighter AMOLED `#FFB74D` and the low-contrast sepia surface) are never honored — producing both visual inconsistency and at least one genuine WCAG contrast failure on sepia. The second theme is **incomplete Arabic localization of numerals and grammar**: a `toArabicNumeral()` helper and Arabic plural rules exist but are skipped in dozens of places, so Western digits and singular nouns (`٧ آية`, `7 يوم`, `2:255`) leak into a fully-RTL UI. Third, **information architecture and navigation discoverability** are weak — 7 of 10 screens live outside the bottom-nav shell behind a single unlabeled overflow menu on Home, and pushed routes lose both the bottom nav and the persistent audio controls. Fourth, **typography is fragmented**: the same verse renders in different fonts and line-heights across surfaces, the default fonts (Cairo, Hafs Smart) lack bold assets, and centralized constants meant to fix this are dead code. Finally, several **input and feedback flaws** (controllers recreated in `build()` breaking the memorization range entry, broken word-hiding logic, silent khatmah-plan data loss on import) rise to high severity. The good news: most fixes are localized and mechanical (token substitution, numeral wrapping, controller lifecycle), and the underlying navigation/data flows work correctly.

## Severity Scoreboard

### By Severity
| Severity | Count |
|---|---|
| 🔴 Critical | 0 |
| 🟠 High | 8 |
| 🟡 Medium | 45 |
| ⚪ Low | 90 |
| **Total** | **143** |

### By Dimension (as adjudicated)
| Dimension | Count |
|---|---|
| Text & Fonts | 27 |
| User Experience | 38 |
| Theme & Color | 23 |
| Consistency | 19 |
| Accessibility | 12 |
| Navigation | 11 |
| UI/UX | 8 |
| Alignment & RTL | 5 |

*(Findings are mapped below to the user's requested headings; Consistency items fold into the most relevant section.)*

---

## Navigation

### 🟠 Secondary screens lose both bottom nav AND the persistent audio player, leaving orphaned playback
- **Where:** `lib/core/router/app_router.dart:67-102`; `lib/core/widgets/app_shell.dart:25-66`
- **Problem:** Notes, Juz, Khatmah, Memorization, Stats, and Thematic are `GoRoute`s with `parentNavigatorKey: _rootNavigatorKey`, rendering **outside** the `ShellRoute`. `AppShell` is the only host of the bottom `NavigationBar` *and* the `_MiniAudioPlayer`. So on all six screens there is no tab bar and no playback controls. Worse, the memorization screen itself starts audio via `playVerse(...)` (`memorization_screen.dart:223`) yet offers no persistent play/pause/stop — its only stop is a side effect of the back button, so playback can be left running with no in-app control.
- **Impact:** A user playing a surah who opens any tool loses all audio controls; playback can become orphaned and uncontrollable except by backing out.
- **Fix:** Either move these routes inside the `ShellRoute` (keeping shell chrome), or render the mini player at the app level above the `Navigator` so controls persist on every screen.

### 🟡 7 of 10 screens are reachable only via an unlabeled overflow menu on Home
- **Where:** `lib/core/router/app_router.dart:23-103`; `lib/features/home/screens/home_screen.dart:88-99`
- **Problem:** The `ShellRoute` exposes only Home/Bookmarks/Settings. Juz, Khatmah, Notes, Memorization, and Thematic are reachable **only** through a generic three-dot `PopupMenuButton(Icons.more_vert)` on the Home AppBar (Stats via an adjacent icon button). The menu items are plain `Text` with no leading icons; the button has no `tooltip` (unlike the sibling stats `IconButton` at line 85). From the Bookmarks or Settings tab these features are unreachable without returning Home. *(Reported twice across the audit — `home_screen.dart:88-99` and the IA view — merged here.)*
- **Impact:** Major features (memorization, khatmah, thematic, notes) have near-zero discoverability; many users will never find them, and they vanish entirely on 2 of 3 tabs.
- **Fix:** Surface these as a "More"/"الأدوات" grid on Home, add a 4th "Tools" tab or a `NavigationDrawer`, and at minimum add a tooltip + leading icons to each `PopupMenuItem`.

### 🟡 Mini audio player is not tappable to reopen the reader
- **Where:** `lib/core/widgets/app_shell.dart:100-161`
- **Problem:** The persistent mini player only wires `onTap` on its play/pause and stop buttons. The info text row ('الآية x' / 'سورة y') has no `onTap`, so a user listening while on another tab cannot tap the now-playing bar to return to the recited verse — the near-universal mini-player expectation.
- **Impact:** Users must remember the chapter, open Home, open the overflow menu, and re-navigate manually to return to what's playing.
- **Fix:** Wrap the info row in an `InkWell` that calls `context.pushNamed` to the reader for `audioState.currentChapterId` (the route already accepts a `verse` query param) when `currentVerseKey` is set.

### 🟡 Mushaf flowing scroll-to-verse uses a crude proportional jump that mis-targets long surahs
- **Where:** `lib/features/reader/screens/reader_screen.dart:198-251` (jump at 230-233; non-convergent retry at 235-249)
- **Problem:** `_scrollToVerseRobust` estimates offset as `(verseIndex+1)/(verses.length+2) * maxScrollExtent`, assuming uniform verse-card heights (false — verses vary wildly, plus a tall `ChapterHeader` at index 0). The retry path recurses up to 5 times re-applying the *identical* deterministic jump, so it never converges when the target lands outside the cache extent.
- **Impact:** Deep-linking to a verse (from search, bookmarks, saved progress) in flowing mode can land far from the target on long surahs, requiring manual scrolling.
- **Fix:** Use `scrollable_positioned_list` for index-based jumping, or incrementally scroll toward the `GlobalKey` with repeated `ensureVisible` instead of recomputing the same proportional offset.

### 🟡 Expanded khatmah-plan card state binds to list index, not plan id
- **Where:** `lib/features/khatmah/screens/khatmah_screen.dart:204-209` (call site missing key); `:222-227` (constructor lacks `Key` param)
- **Problem:** `_KhatmahPlanCard` is a `StatefulWidget` holding `_expanded`, created in `ListView.builder` with no `Key`. After `_deletePlan` → `ref.invalidate` shifts indices, the per-slot `_expanded` element state attaches to the wrong plan.
- **Impact:** After deleting a plan, a different plan's day grid can unexpectedly appear expanded/collapsed — looks like a glitch mid-interaction. (Completion *data* stays correct; only visual expansion leaks.)
- **Fix:** Add `key: ValueKey(plan.id)` at the call site and a `Key?`/`super.key` parameter to the private widget's constructor.

### ⚪ Auto-resume silently pushes the reader on startup with no cancel affordance
- **Where:** `lib/features/home/screens/home_screen.dart:40-63`
- **Problem:** On first build, if `autoResumeLastAyah` is on (default true) and a session exists, a post-frame callback immediately `context.pushNamed('reader')` with no prompt. Users wanting to browse the index are forced into the reader.
- **Impact:** Users must press back on every launch to reach Home (back navigation does work — the static guard prevents re-fire, so there is no loop).
- **Fix:** Rely on the existing `ContinueReadingCard` instead of an auto-push, or gate the push to true cold starts; the opt-out toggle already exists in Settings.

### ⚪ Thematic topic detail uses raw `Navigator.push(MaterialPageRoute)`, bypassing GoRouter
- **Where:** `lib/features/thematic/screens/thematic_screen.dart:55-64`
- **Problem:** The only `MaterialPageRoute` in `lib/`; every other screen uses GoRouter. `_ThematicVersesScreen` is not in the route graph (no URL, not deep-linkable), and its later `context.pushNamed('reader')` pushes onto a root navigator GoRouter doesn't track, leaving GoRouter's URL/stack out of sync. *(Two near-duplicate findings merged.)*
- **Impact:** Lost deep-linking/restoration for this leaf screen and a latent back-stack/pop-semantics hazard. No crash in normal use.
- **Fix:** Register it as a `GoRoute` (e.g. `/thematic/:topic`) and navigate via `context.pushNamed`.

---

## Text & Fonts

### 🟡 Cairo (the global default font) ships no bold asset despite pervasive `FontWeight.bold` usage
- **Where:** `pubspec.yaml:91-93`; usages across ~26 files
- **Problem:** Cairo is the app-wide `fontFamily` (`app_theme.dart:9,57,105,180`) but only `Cairo-Regular.ttf` is registered (no 700 variant), while Amiri and Scheherazade New declare proper Bold cuts. The UI uses bold/`w600`/`w700` on Cairo-rendered text in ~64 places, so Flutter synthesizes faux-bold app-wide.
- **Impact:** Every bold Arabic UI label/title/header renders as lower-quality synthetic bold (smeared/uneven), across most screens.
- **Fix:** Add `Cairo-Bold.ttf` (weight 700) to the Cairo family, or pull Cairo from `google_fonts` with proper weights.

### 🟡 The same verse renders in three different fonts because `settings.quranFont` is bypassed
- **Where:** `lib/features/home/screens/home_screen.dart:260` (search results hardcode `'Scheherazade New'`); `lib/features/bookmarks/screens/bookmarks_screen.dart:159-163`, `lib/features/notes/screens/notes_screen.dart:102`, `lib/features/stats/screens/stats_screen.dart:164`, `lib/features/home/screens/home_screen.dart:393`, `lib/features/reader/screens/mushaf_view.dart:296,320,505`, `lib/features/reader/widgets/chapter_header.dart:32`, `lib/features/juz_navigator/screens/juz_navigator_screen.dart:54`, `lib/features/reader/widgets/mushaf_navigation_sheet.dart:108,113,219,326,445` (hardcode `'Amiri'`); `lib/features/reader/widgets/tafsir_sheet.dart:185-186` (tafsir body hardcodes `'Amiri'`)
- **Problem:** Every authoritative verse surface (`verse_card`, `daily_verse_card`, `mushaf_view` body, `share_sheet`) honors `settings.quranFont` (default `Hafs Smart`), but search results force `Scheherazade New`, and saved-verse text in bookmarks/notes plus the tafsir body force `Amiri`. The smoking gun: `chapter_header.dart` uses `settings.quranFont` for the bismillah (line 55) but hardcodes `'Amiri'` for the surah name (line 32) in the same widget. *(Multiple near-duplicate findings consolidated; surah-name *headers* are a partly-defensible decorative choice, but saved verse text and tafsir body are unambiguous bugs.)*
- **Impact:** The user's chosen Quran font is silently overridden on many screens; identical verses look like different scripts across the app — corrosive for a Quran app whose core is consistent presentation.
- **Fix:** Use `settings.quranFont` for all Quran *verse* text; if a distinct decorative font is wanted for surah-name *headers*, centralize it in one constant rather than re-typing `'Amiri'`.

### 🟡 Page numbers, verse counts, and percentages render Western digits inside the Arabic RTL UI
- **Where:** `lib/features/reader/widgets/mushaf_navigation_sheet.dart:230`; `lib/features/settings/widgets/appearance_section.dart:43,67,88`; `lib/features/settings/widgets/reading_section.dart:36`; `lib/features/thematic/screens/thematic_screen.dart:200-201`; `lib/features/bookmarks/screens/bookmarks_screen.dart:139,227`; `lib/features/notes/screens/notes_screen.dart:81`; `lib/features/juz_navigator/screens/juz_navigator_screen.dart:63`; `lib/features/stats/screens/stats_screen.dart:52,197`; `lib/features/khatmah/screens/khatmah_screen.dart:44,58`; `lib/core/widgets/app_shell.dart:113-115`; `lib/features/home/widgets/daily_verse_card.dart:66,78`
- **Problem:** `toArabicNumeral()` (and `formatVerseReference()`) exist and are used in ~18 files, yet these locations interpolate raw `int`s and raw `verseKey` strings, producing Western digits (`صفحة 50`, `من 19:00 إلى 6:00`, `حجم الخط: 28`, `2:255`, `37%`, `7 يوم`, `سورة 18`). Stats and thematic even mix Arabic-Indic and Western digits on the *same* row/tile. *(A large family of near-identical numeral findings merged into one entry.)*
- **Impact:** Mixed numeral systems look unpolished and non-native throughout an otherwise fully-Arabic UI; some screens show two digit systems side by side.
- **Fix:** Wrap every user-visible integer/verse-key in `toArabicNumeral`/`formatVerseReference`. Consider a lint/helper so this can't regress.

### 🟡 Ayah marker uses the `۝` (U+06DD) combining mark, breaking multi-digit verse markers
- **Where:** `lib/core/utils/arabic_utils.dart:14-20`
- **Problem:** `formatAyahMarker` ('native' default) returns `'۝$num'`. U+06DD is meant to *enclose* the following digits, which is heavily font-dependent. The marker is rendered with `settings.quranFont` across a mixed stack (Amiri/Hafs enclose; Cairo/Noto Naskh typically do not), so for verses like 255 those fonts show a bare circle followed by loose numerals.
- **Impact:** On surahs like Al-Baqarah the end-of-ayah marker can render as a stray glyph plus un-enclosed digits instead of the traditional ornament.
- **Fix:** Default to the 'badge' style (`﴿..﴾`), or verify the chosen `quranFont` supports U+06DD multi-digit enclosing and fall back to a bracketed marker otherwise.

### 🟡 Chapter shown by number, not Arabic name, in thematic list
- **Where:** `lib/features/thematic/screens/thematic_screen.dart:192`
- **Problem:** Tiles render `'سورة ${toArabicNumeral(chapterId)}'` (e.g. `سورة ٢`) instead of the surah's Arabic name. The widget never reads `chaptersProvider`, even though `stats_screen.dart:162` demonstrates the pattern (`ch?.nameArabic ?? 'سورة …'`).
- **Impact:** Arabic readers identify surahs by name; `سورة ٢` instead of `سورة البقرة` is unnatural and inconsistent with the rest of the app.
- **Fix:** Resolve `nameArabic` from `chaptersProvider` and display `'سورة البقرة - الآية ٢٥٥'`.

### 🟡 Night-mode hours, font-size value, and font-name list show Western/Latin strings in Arabic settings
- **Where:** `lib/features/settings/widgets/reading_section.dart:77-84` (Latin font family names as labels); `lib/features/settings/widgets/appearance_section.dart:43,67,88`; `lib/features/settings/widgets/reading_section.dart:36`
- **Problem:** The font picker shows raw Latin identifiers (`Hafs Smart`, `Scheherazade New`, `Amiri`, `Noto Naskh Arabic`) as visible labels while sibling controls use Arabic (`مصحف المدينة`, `مضغوط`/`عادي`/`واسع`). Night-mode hour dropdowns/labels and the font-size value also emit Western digits. *(Numeral parts overlap with the merged numeral entry; font-name labels are the distinct issue here.)*
- **Impact:** Arabic users pick fonts from English codenames, several meaningless to them, inconsistent with otherwise-Arabic copy.
- **Fix:** Map each family to an Arabic display name (e.g. `حفص`, `شهرزاد`, `أميري`, `نسخ`) rendered in that font, keeping the Latin identifier as the value only.

### ⚪ Arabic number/noun agreement is wrong app-wide (singular nouns + plural counts)
- **Where:** `lib/core/utils/arabic_utils.dart:42-48` (relative time); `lib/features/home/screens/home_screen.dart:440`, `lib/features/thematic/screens/thematic_screen.dart:86,148`, `lib/features/stats/screens/stats_screen.dart:171`, `lib/features/memorization/screens/memorization_screen.dart:78`, `lib/features/reader/widgets/chapter_header.dart:41` (verse counts `${n} آية`); `lib/features/khatmah/screens/khatmah_screen.dart:44` (`$days يوم`); `lib/features/settings/widgets/backup_section.dart:151` (import snackbar)
- **Problem:** Counts always use the singular noun regardless of value. Arabic requires the plural for 3–10 (`٧ آيات`, `٥ ساعات`, `٤ أيام`, `إشارات`/`ملاحظات`) and the dual for 2. So Al-Fatiha shows `٧ آية` and a 3-minute timestamp shows `منذ ٣ دقيقة`. *(All grammar-agreement findings merged.)*
- **Impact:** Verse counts, durations, timestamps, and import confirmations read as broken Arabic to native speakers across core screens.
- **Fix:** Add a count-aware pluralization helper (1=مفرد, 2=مثنى, 3–10=جمع, 11+=singular tamyiz) and route all count strings through it.

### ⚪ Mushaf page-jump dialog mixes Arabic-Indic hint with Latin suffix and forces LTR
- **Where:** `lib/features/reader/screens/mushaf_view.dart:65-72`
- **Problem:** `hintText: '١ - ٦٠٤'` (Arabic-Indic) but `suffixText: '/ 604'` (Latin), with `textDirection: TextDirection.ltr` and a Western-digit prefill. Parsing via `int.tryParse` also rejects Arabic-Indic input, and out-of-range/Arabic input silently no-ops (dialog stays open, no error). *(Two related findings merged.)*
- **Impact:** A user primed by the Arabic-Indic pill/hint sees a Latin counter and, if they type Arabic digits, gets silent rejection — the feature feels broken.
- **Fix:** Make the suffix/prefill Arabic-Indic to match, normalize Arabic-Indic digits before parsing, and show inline validation feedback for out-of-range input.

### ⚪ Default Quran font 'Hafs Smart' faux-bolds the ayah marker (no bold asset)
- **Where:** `lib/features/reader/widgets/verse_card.dart:48-52`; `pubspec.yaml:88-90`
- **Problem:** `_buildAyahMarkerStyle` applies `FontWeight.w600` with `settings.quranFont`, but Hafs Smart (the default) and Noto Naskh register only a regular weight, so Flutter synthesizes faux-bold on the diacritic-rich marker glyph.
- **Impact:** Default-font users see a subtly thicker/distorted ayah-marker glyph, inconsistent with fonts that ship real bolds.
- **Fix:** Drop `w600` for single-weight Quran fonts (or ship a Hafs Smart bold). Verse body text is unaffected.

### ⚪ Tafsir in-sheet search matches ASCII case only — fails Arabic diacritic/alef variants
- **Where:** `lib/features/reader/widgets/tafsir_sheet.dart:48-78`
- **Problem:** `_highlightedTextSpan` uses `toLowerCase()` + `indexOf` with no tashkeel/alef-hamza normalization. A query without harakat won't match diacriticized tafsir text, so highlighting silently misses matches.
- **Impact:** In-sheet tafsir search feels broken for Arabic on diacriticized sources.
- **Fix:** Normalize both query and text (strip tashkeel; unify alef/hamza/ta-marbuta) before matching.

### ⚪ Translation/tafsir terminology and copy mismatches
- **Where:** `lib/features/settings/widgets/reading_section.dart:164-169` ('عرض الترجمة' title vs 'التفسير الميسر' subtitle); `lib/features/reader/widgets/share_sheet.dart:99-103` ('نسخ مع التفسير' copies the *translation*); `lib/features/bookmarks/screens/bookmarks_screen.dart:32,75,101-102` + `lib/features/stats/screens/stats_screen.dart:101` + `lib/features/settings/widgets/backup_section.dart:151` (bookmark named المفضلة/مفضلات vs الإشارة المرجعية vs إشارة)
- **Problem:** A toggle titled "translation" describes an Arabic tafsir; a "copy with tafsir" button actually copies the translation; and the bookmarks feature is named three different ways across AppBar, dialog, stats, and backup. *(Three terminology-consistency findings merged.)*
- **Impact:** Conflicting labels for one concept confuse users and undermine trust in a religious app where translation ≠ exegesis is meaningful.
- **Fix:** Pick one term per concept and apply it everywhere; align the share button label with what it actually copies.

### ⚪ Khatmah/gender label disagreement (`مكتمل` vs `مكتملة`)
- **Where:** `lib/features/khatmah/screens/khatmah_screen.dart:309-311`
- **Problem:** The progress line uses masculine `${percent}% مكتمل` for an in-progress (feminine) خطة, then feminine `مكتملة! ✓` when done — an internal gender-agreement switch within one card. Home tiles correctly use feminine `مكتملة`.
- **Impact:** Native readers notice the mismatch and inconsistent switch.
- **Fix:** Use a consistent feminine form (`مكتملة`) or a neutral phrasing like `أُنجز ${percent}%`.

### ⚪ Translation text right-aligned with forced RTL (fails for LTR translations)
- **Where:** `lib/features/home/widgets/daily_verse_card.dart:113-123`; `lib/features/reader/widgets/verse_card.dart:235-236`
- **Problem:** Translation `Text` uses `TextAlign.right`/`TextAlign.justify` with inherited or forced RTL and no per-script direction resolution. (Currently latent: the app only ever serves Arabic translation id 16 because no translation-picker UI is wired, so no LTR string reaches these widgets today.)
- **Impact:** If/when an English/French translation is enabled, it would be flush-right with mis-ordered punctuation.
- **Fix:** Use `TextAlign.start` and let direction resolve from the translation's script.

---

## Alignment & RTL

### ⚪ Audio bar time labels can overflow on narrow phones / hour-long recitations
- **Where:** `lib/features/reader/widgets/audio_player_bar.dart:56-104`
- **Problem:** Two unconstrained position/duration `Text` widgets plus fixed-width controls sit in a `Row` with `Spacer`s. For >1h audio the labels switch to 8-char `HH:MM:SS` (`audio_provider.dart:70-77`), and with no global `textScaler` clamp, accessibility scaling worsens it — risking `RenderFlex` overflow on tight widths.
- **Impact:** On long surahs or small/high-text-scale devices the bar can overflow (yellow/black stripes) or clip the stop button.
- **Fix:** Wrap time labels in `Flexible`/`FittedBox`, reserve `HH:MM:SS` width, and reduce control spacing.

### ⚪ Stats grid `childAspectRatio: 1.2` risks the previously-fixed overflow at high text scale
- **Where:** `lib/features/stats/screens/stats_screen.dart:76-113` (cards at 225-271); aggravated by missing `textScaler` clamp in `lib/app.dart:55-61`
- **Problem:** The 2×2 stat grid stacks Icon(28) + value(22) + label(11) in a fixed-ratio cell with no `FittedBox`/min-height guard. At default scale there's ~38px slack, but heavy OS font scaling (~1.8×+) reproduces the "Bottom Overflowed" class the changelog claims fixed. (Note: the stat texts are hardcoded sizes, not the `fontSize` setting.)
- **Impact:** Stat cards can overflow vertically at large accessibility font sizes on big devices.
- **Fix:** Wrap card contents in `FittedBox`/`mainAxisSize.min`, or use a max-cross-axis-extent delegate so cells adapt to text scale.

### ⚪ Verse line-height is inconsistent across surfaces; setting only affects the flowing reader
- **Where:** `lib/features/reader/screens/mushaf_view.dart:449,478` (hardcoded 2.0); `lib/features/reader/widgets/verse_card.dart:35-44` (respects `settings.lineHeight`); `lib/features/home/screens/home_screen.dart:262` (1.9); `lib/features/home/widgets/daily_verse_card.dart:105` (2.0); `lib/features/reader/widgets/tafsir_sheet.dart:188` (2.0)
- **Problem:** Only the flowing `verse_card` honors `settings.lineHeight` (1.8/2.2/2.8); mushaf and all other verse surfaces hardcode ad-hoc literals, and the existing `UiConstants.resolveLineHeight`/`mushafLineHeight` are ignored.
- **Impact:** A user choosing "loose"/"compact" sees it only in flowing mode; spacing feels inconsistent and the setting appears partly broken.
- **Fix:** Honor `settings.lineHeight` (via `UiConstants.resolveLineHeight`) on every verse surface, or document mushaf as intentionally fixed; unify the 1.9/2.0/2.2 literals.

### ⚪ Swipe-delete background uses physical (non-directional) alignment
- **Where:** `lib/features/notes/screens/notes_screen.dart:36-45`; `lib/features/bookmarks/screens/bookmarks_screen.dart:87-90`
- **Problem:** `Dismissible(direction: endToStart)` (directional) is paired with `Alignment.centerLeft` + `EdgeInsets.only(left: 24)` (physical). Correct today only because RTL is globally forced; the same file even uses `EdgeInsetsDirectional` elsewhere (line 54), so it's also internally inconsistent.
- **Impact:** Latent robustness issue — no visible defect under forced RTL, but the delete icon would land on the wrong side if Directionality ever changes.
- **Fix:** Use `AlignmentDirectional.centerStart` and `EdgeInsetsDirectional.only(start: 24)`.

---

## UI/UX

### 🟡 ShareSheet opens without `isScrollControlled`, clipping long verses
- **Where:** `lib/features/reader/screens/reader_screen.dart:295-301`
- **Problem:** `_showShareSheet` omits `isScrollControlled: true` (unlike the tafsir/note sheets), so the modal is capped at ~9/16 height. `ShareSheet`'s content is a non-scrollable `Column` (via `BaseBottomSheet`'s `Flexible`, not a scroll view), so the longest verses overflow.
- **Impact:** For long verses the preview/buttons clip and the native share button can be unreachable on small screens.
- **Fix:** Add `isScrollControlled: true` **and** wrap `ShareSheet` content in a scroll view (as `TafsirSheet` does).

### 🟡 Loading skeleton replaces the entire Home screen, hiding search and header cards
- **Where:** `lib/features/home/screens/home_screen.dart:192`; `lib/features/home/widgets/chapter_skeleton.dart`
- **Problem:** While `chaptersProvider` loads, the whole body becomes `ChapterListSkeleton` (fixed `itemCount: 10`, `NeverScrollableScrollPhysics`). The search field and header cards live only in the `data:` branch, so they pop in afterward with a layout jump.
- **Impact:** On cold start users see only grey bars, can't type a search, then get a full-screen content jump.
- **Fix:** Keep the search field (and ideally header cards) mounted during loading; skeleton only the chapter-list region.

### 🟡 Mushaf "page" is a free scroll view, breaking one-page fidelity
- **Where:** `lib/features/reader/screens/mushaf_view.dart:484-558` (scroll at 486-487)
- **Problem:** Each `_MushafPageContent` wraps text in a `SingleChildScrollView` with its own controller and uses `settings.fontSize` directly (no `FittedBox`/cap). At large fonts a page exceeds the viewport and scrolls, so "page N" no longer maps to a real mushaf page. The floating page-number pill (`Positioned bottom:16`) overlays the scrolling text.
- **Impact:** Memorization-by-page-position and cross-referencing lose the fixed-page guarantee; the page indicator overlaps content.
- **Fix:** Auto-scale text to fit (FittedBox) or cap font scaling in mushaf mode so each page is a non-scrolling unit; reserve space for the indicator.

### 🟡 Mushaf verse highlight never clears and re-scrolls on every revisit
- **Where:** `lib/features/reader/screens/mushaf_view.dart:197` (forwarding); manifests at 403-430 (re-scroll) and 441-467 (persistent paint)
- **Problem:** `widget.highlightVerseKey` is forwarded unchanged to every page and never reset. The amber background persists for the session, and because pages have no `Key`/keep-alive, swiping back recreates the page state and re-fires the `ensureVisible` auto-scroll.
- **Impact:** A navigated-to verse stays marked indefinitely and yanks the scroll position every time the user returns to that page.
- **Fix:** Clear the highlight after the first successful scroll (callback/provider), or scope it to the initial page so revisits don't re-trigger.

### 🟡 Mushaf mode ignores `showTajweed` and over-fetches whole chapters
- **Where:** `lib/features/reader/providers/mushaf_provider.dart:17-47`; renders plain at `mushaf_view.dart:444-445`
- **Problem:** `mushafPageVersesProvider` calls `repository.getVerses(ch)` with no args, so `withTajweed` defaults false; mushaf draws `verse.textUthmani` with no tajweed spans. Enabling tajweed colors verses in flowing mode but does nothing in mushaf. It also fetches each full chapter and filters client-side (one cached fetch per chapter).
- **Impact:** Tajweed coloring silently no-ops in mushaf mode — a mode-switch inconsistency users will notice.
- **Fix:** Pass `withTajweed: settings.showTajweed` and render tajweed spans in mushaf; prefer a verse-range fetch over whole-chapter pulls.

### ⚪ Empty search-results state forces a full-height centered message
- **Where:** `lib/features/home/screens/home_screen.dart:208-214`
- **Problem:** No-results returns `SliverFillRemaining(hasScrollBody: false)` centering the message, so it floats in the middle of an otherwise blank viewport far from the search box.
- **Impact:** Reads as a layout glitch rather than a helpful empty state.
- **Fix:** Render as a `SliverToBoxAdapter` with modest top padding under the results header.

### ⚪ Search clear button shifts the submit icon as the user types
- **Where:** `lib/features/home/screens/home_screen.dart:136-152`
- **Problem:** The suffix is a `Row(mainAxisSize: min)` where the clear button is conditionally inserted before the always-present submit button, so the submit icon's screen position shifts when the first character is typed/cleared. (The "controller desync" framing is speculative — no autofill/paste path exists.)
- **Impact:** The submit tap target jitters under the user's finger.
- **Fix:** Keep the submit position stable (fixed-width clear slot or `AnimatedOpacity`); drive the suffix from a `ValueListenableBuilder`.

### ⚪ Note sheet: empty save silently no-ops; double-container nesting
- **Where:** `lib/features/reader/widgets/note_sheet.dart:76-82` (empty no-op); `:43-51` (redundant container)
- **Problem:** The save `FilledButton` is always enabled-looking; on empty/whitespace it does nothing (no error/feedback), and an existing note can't be cleared/deleted from here. Separately, `NoteSheet` wraps its own container with background+28px radius even though `BaseBottomSheet` already draws an identical one. *(A close X *does* exist via `BaseBottomSheet`, so users aren't trapped.)*
- **Impact:** "Dead button" confusion on empty save; redundant container (cosmetically harmless).
- **Fix:** Disable the button (or show a hint) on empty input; add a delete-on-edit path; remove the outer decorative container.

### ⚪ Reduced-motion toggle is an orphaned, ungrouped setting; Reading section lacks a title
- **Where:** `lib/features/settings/screens/settings_screen.dart:41-47` (orphan toggle); `:27-52` (missing Reading title + inconsistent separators)
- **Problem:** The 'تقليل الحركة' `SwitchListTile` sits bare in the root `ListView` between Audio and Backup, while every other control lives in a titled section. `ReadingSection` has no group header (unlike Appearance/Audio/Backup), and separators mix `SizedBox(24)` with `Divider(height:32)`. *(Two settings-organization findings merged.)*
- **Impact:** Settings feel ungrouped; the large Reading block has no anchor and the reduced-motion toggle looks misplaced.
- **Fix:** Add a "القراءة" header, move reduced-motion into Appearance/a new Accessibility section, and use one consistent separator.

### ⚪ Khatmah/thematic empty states omit the CTA the widget supports
- **Where:** `lib/features/khatmah/screens/khatmah_screen.dart:193-198`; `lib/core/widgets/empty_state_widget.dart:50-56` (reported twice, merged)
- **Problem:** `EmptyStateWidget` supports `actionLabel`/`onAction`, but the khatmah empty state passes neither — the only create path is the corner FAB (which is labeled "خطة جديدة", so it's discoverable).
- **Impact:** First-run CTA isn't actionable from where the eye lands.
- **Fix:** Pass `actionLabel: 'خطة جديدة', onAction: _showCreateDialog`.

### ⚪ List screens lack bottom-inset padding under the gesture bar
- **Where:** `lib/features/juz_navigator/screens/juz_navigator_screen.dart:17-24` (and notes/thematic/memorization scrollables)
- **Problem:** Pushed full-screen routes have no `bottomNavigationBar`, so Scaffold doesn't auto-inset; their scrollables use fixed padding with no `SafeArea`/`MediaQuery.padding.bottom` (khatmah ad-hoc pads 80 for its FAB).
- **Impact:** On gesture-nav devices the last row rests partially under the system gesture bar.
- **Fix:** Wrap bodies in `SafeArea(bottom: true)` or add `MediaQuery.padding.bottom` to list padding consistently.

### ⚪ Dead `hasHighlight` parameter in `buildVerseSpans`
- **Where:** `lib/features/reader/screens/mushaf_view.dart:434-482`
- **Problem:** `buildVerseSpans({bool hasHighlight = false})` is passed `true` at line 548 but never read; highlighting is computed per-span from `widget.highlightVerseKey`.
- **Impact:** Misleading API surface — a maintainer may rely on it and find it inert.
- **Fix:** Remove the unused parameter and its `true` argument.

### ⚪ Maintained hardcoded chapter→page table duplicates JSON data
- **Where:** `lib/features/reader/screens/reader_screen.dart:557-675` (reached at 328)
- **Problem:** A 114-entry `chapterToPage` map is the final fallback for the initial mushaf page, duplicating data derivable from `quran_pages.json` via `getPageForVerse('${id}:1')` (already used elsewhere in the same method). No current mismatches, but it's a second source of truth that can drift.
- **Impact:** Future drift risk; the fallback could open a wrong page if the JSON is updated.
- **Fix:** Drop the map and resolve exclusively through `getPageForVerse`.

---

## User Experience

### 🟠 Memorization verse-range `TextEditingController`s are recreated every build, breaking input
- **Where:** `lib/features/memorization/screens/memorization_screen.dart:100,112` (reported twice, merged)
- **Problem:** Both `TextField`s construct `TextEditingController(text: '$_fromVerse')` inline in `build()`; `onChanged` calls `setState`, recreating the controller each keystroke and resetting the caret (named ctor sets selection offset −1). Controllers are also never disposed (leak).
- **Impact:** Typing a multi-digit verse number is erratic (caret jumps, selection lost) — and most surahs have ≥10 verses, so this is the common case, not an edge case. This is the screen's only range-entry path.
- **Fix:** Create the controllers once as state fields in `initState`, dispose in `dispose` (or use `TextFormField` with `initialValue`).

### 🟠 Memorization word-hiding only ever applies to the first verse; scoring is broken
- **Where:** `lib/features/memorization/screens/memorization_screen.dart:193-198,257,263`
- **Problem:** `_hiddenWordIndices` is a single flat `Set<int>` populated once (gated on `index == 0`) from verse 1's word count, then applied to *every* verse's `Wrap`. Indices are reused blindly (out of range for shorter verses), `_total` counts only verse 1, yet `_score` increments across all verses (so score can exceed total), and revealing a word un-hides the same positional index in every verse.
- **Impact:** For multi-verse ranges the memorization exercise is essentially broken — wrong blanks, mismatched reveals, and incorrect scoring.
- **Fix:** Track hidden indices per verse (`Map<verseKey, Set<int>>`), compute per verse, and aggregate `_total`/`_score` across the range.

### 🟠 Thematic verse list never shows the actual verse text
- **Where:** `lib/features/thematic/screens/thematic_screen.dart:191-206`
- **Problem:** `_ThematicVersesScreen` is a `StatelessWidget` with no `ref`/provider access; each entry shows only `'سورة N - الآية M'` with the raw `verseKey` as subtitle. It never loads or previews the Arabic text.
- **Impact:** A "thematic index" of bare numeric references gives no idea what each verse says; users must tap into the reader for every entry.
- **Fix:** Load each verse's text (via a batched lookup) and show at least an Arabic snippet; replace the raw key subtitle with the chapter name.

### 🟠 Khatmah plans are exported but never restored on import (silent data loss)
- **Where:** `lib/features/settings/widgets/backup_section.dart:83-90` (export), `:133-146` (import omission)
- **Problem:** `_exportData` writes `khatmahPlans`, but `_importData` only iterates `bookmarks` and `notes`; there is no khatmah import method anywhere (`progressProvider` has none). The success snackbar reports only bookmark/note counts.
- **Impact:** Export → reinstall → import silently loses all khatmah plans, with a success message implying everything restored.
- **Fix:** Add a khatmah import path and call it for `data['khatmahPlans']` (or stop exporting what can't be restored); include plan count in the snackbar.

### 🟡 No font-size control in the reader
- **Where:** `lib/features/reader/screens/reader_screen.dart:352-374`
- **Problem:** The reader AppBar exposes only tajweed legend, view-mode toggle, and chapter audio — no in-context A+/A−. Changing size requires backing out to Settings and returning. Both modes already read `settings.fontSize`.
- **Impact:** The single most-used reading control forces a multi-screen round-trip on every adjustment.
- **Fix:** Add inline font-size +/− buttons (or a popup slider) to the reader AppBar calling `setFontSize(...)`, clamped 18–48, reflected live in both modes.

### 🟡 Audio bar shows no track identity and no reciter switch
- **Where:** `lib/features/reader/widgets/audio_player_bar.dart:54-105`
- **Problem:** The bar exposes seek/speed/repeat/play/stop but never shows what's playing and offers no reciter quick-pick; reciter is changeable only deep in Settings. (Mitigated somewhat — the reader AppBar shows the surah and the verse is highlighted, and the shell mini-player shows verse/chapter text.)
- **Impact:** Users can't switch reciter without leaving the reader; the bar reads as a generic media bar.
- **Fix:** Add a now-playing label (`currentVerseKey`) and a reciter quick-picker (`PopupMenu` like speed) that updates `selectedReciterId` and restarts playback.

### 🟡 Tab switching destroys Home/Bookmarks UI state (search, scroll, filter)
- **Where:** `lib/core/widgets/app_shell.dart:36-44`; `lib/features/bookmarks/screens/bookmarks_screen.dart:18`
- **Problem:** Tabs use `context.goNamed` + `NoTransitionPage` over a plain `ShellRoute` (no `StatefulShellRoute.indexedStack`/`IndexedStack`/keep-alive). Leaving and returning to a tab disposes its state, resetting Home's `_searchController`/`_submittedQuery`/scroll and Bookmarks' `_selectedCategory` and scroll. *(Two related findings merged.)*
- **Impact:** In-progress search, scroll position, and the selected category filter are silently lost on every tab round-trip. (Data is Riverpod-cached, so no refetch.)
- **Fix:** Use `StatefulShellRoute.indexedStack` so each branch keeps its own Navigator/state; or persist filter in a provider.

### 🟡 Daily verse-range targets are computed but never shown
- **Where:** `lib/features/khatmah/screens/khatmah_screen.dart:346-378`
- **Problem:** `_createPlan` builds a `DailyTarget(fromVerse, toVerse)` per day and persists it, but the day grid renders only the day number/checkmark; the range is shown nowhere. (An aggregate "~N verses/day" appears in the create dialog.)
- **Impact:** Users see numbered squares with no indication of *what* to read each day — the core value of a reading plan is hidden.
- **Fix:** Show the day's target range in/under each cell (formatted with `toArabicNumeral`).

### 🟡 'اليوم X' day counter runs past the plan length and ignores completion
- **Where:** `lib/features/khatmah/screens/khatmah_screen.dart:244` (compute), `:285` (render)
- **Problem:** `daysSinceStart` is an unclamped calendar diff rendered as `'اليوم ${n+1}'`. A 7-day plan opened 40 days later prints `اليوم ٤١`; a completed plan grows forever. (Progress tracking itself is correct — only this label.)
- **Impact:** Absurd labels make the plan look broken and undermine the sense of completion.
- **Fix:** Clamp to `plan.totalDays` and/or hide on completed plans, showing a 'مكتملة' state.

### 🟡 Create-plan and search dialogs accept invalid input with no feedback
- **Where:** `lib/features/khatmah/screens/khatmah_screen.dart:71-80` (empty name no-op); `lib/features/home/screens/home_screen.dart:65-72` (1-char query → misleading "no results")
- **Problem:** The khatmah "إنشاء" button silently returns on an empty name (no error/disable). On Home, submitting a 1-char query sets `_submittedQuery` but the provider returns `[]` for `< searchMinLength`, so the UI shows 'لا توجد نتائج' as if the search ran. *(Two validation-feedback findings grouped.)*
- **Impact:** Primary actions appear to do nothing or report false negatives.
- **Fix:** Show inline `errorText`/disable until valid; treat `< searchMinLength` like empty (or show 'أدخل حرفين على الأقل').

### 🟡 Bookmarks: filtered empty category shows "no bookmarks at all"
- **Where:** `lib/features/bookmarks/screens/bookmarks_screen.dart:72-77`
- **Problem:** When a selected category is empty, `allBookmarks.isEmpty` triggers the generic 'لا توجد مفضلات' + 'add verses while reading' message — even with many bookmarks in other categories. (Filter chips above show live counts, a partial cue.)
- **Impact:** Falsely tells a user with 50 bookmarks they have none.
- **Fix:** Branch on `_selectedCategory`: show 'لا توجد مفضلات في هذا التصنيف' for non-'all' filters.

### 🟡 Memorization view dead-ends on out-of-range/invalid ranges
- **Where:** `lib/features/memorization/screens/memorization_screen.dart:101-116` (no validation), `:149-156` (dead-end empty state)
- **Problem:** No check that `from <= to` or within `versesCount`; a bad range yields an empty list and the early-return `Center('لا توجد آيات في هذا النطاق')` — which renders *before* the controls bar that holds the 'رجوع' button, so there's no inline way back. *(Two related findings merged.)*
- **Impact:** Users land on a bare message with no actionable control to fix the range.
- **Fix:** Validate `from <= to <= versesCount` before starting; render the controls bar (with رجوع) above the empty message.

### 🟡 Memorization "show all" is a one-shot dead end
- **Where:** `lib/features/memorization/screens/memorization_screen.dart:174-178,193-198`
- **Problem:** After 'كشف الكل', the only control re-hides the *same* indices; `_hideRandomWords()` runs once (gated on `_hiddenWordIndices.isEmpty && index == 0`), so there's no "new round." To re-practice the user must back out and restart.
- **Impact:** The core practice loop is one-shot — exactly what a memorization tool should not be.
- **Fix:** Add a 'جولة جديدة' button calling `_hideRandomWords` (resetting `_score`/`_total`/`_showAll`); drive auto-hide from start, not a build-phase callback.

### 🟡 No global error handling around DB init; a failed initialize blocks launch
- **Where:** `lib/main.dart:11-40` (throw path via `database_initializer.dart:14` → `app_database.dart:159`)
- **Problem:** `main` awaits `initializeIfNeeded()` with no try/catch and no `runZonedGuarded`/`FlutterError.onError`. If the bundle population or DB open throws, `runApp` is never reached — blank/crashed app, no message or retry. (`localDataSource.initialize()` swallows its own errors, so only the initializer is the live throw path.)
- **Impact:** Any first-launch DB failure hard-locks the user out with zero feedback.
- **Fix:** Wrap init in try/catch; on failure still `runApp` with an error/retry screen (or online-only mode) and log via `AppLogger`.

### ⚪ Several "silent failure / no feedback" affordances
- **Where:** Daily verse card collapses to `SizedBox.shrink()` on error/null (`daily_verse_card.dart:23,152`); slider seekable while loading (`audio_player_bar.dart:45-51`); repeat badge never shows live progress (`audio_player_bar.dart:250-257`); no pull-to-refresh anywhere (`home_screen.dart:112-190`); Home search error has no retry button unlike the chapter-list path (`home_screen.dart:289-301`); reader flowing empty-verses path shows a generic "load failed/retry" for empty-success (`reader_screen.dart:382-389`); tafsir search doesn't unfocus or reset on chip change (`tafsir_sheet.dart:43-46,124-142`)
- **Problem:** A cluster of minor feedback/affordance gaps where failures or states are hidden, retries are missing or futile, or interactions are misleading. *(Grouped — all low severity, distinct files.)*
- **Impact:** Users encounter dead messages, futile retries, missing refresh, or controls that appear inert.
- **Fix:** Add fallbacks/retries/disabled-states per case (compact daily-verse fallback; disable slider while `isLoading`; show `currentRepeat+1/repeatCount`; add `RefreshIndicator`; add a retry to the search error sliver; distinguish empty-success from error; `FocusScope.unfocus()` and reset query on tafsir source change).

### ⚪ No undo after destructive swipe-delete
- **Where:** `lib/features/bookmarks/screens/bookmarks_screen.dart:110`; `lib/features/notes/screens/notes_screen.dart:59` (merged)
- **Problem:** `onDismissed` permanently deletes with no undo SnackBar. A confirm dialog exists (so no silent fat-finger loss), but notes are user-authored, irreplaceable text with no recovery path.
- **Impact:** An accidental confirm permanently loses a written note.
- **Fix:** Show a 'تراجع' SnackBar that re-inserts via `addNote`/`importBookmark`; finalize after timeout.

### ⚪ `ContinueReadingCard` parses verseKey unsafely (`int.parse(split(':')[1])`)
- **Where:** `lib/features/home/widgets/continue_reading_card.dart:75`
- **Problem:** Runs in the synchronous `data:` build body, so a malformed/legacy `verseKey` would throw `RangeError`/`FormatException` and red-screen the Home card (not caught by the AsyncValue error path). No live code path produces a bad key today, but the sibling `progress_provider.dart:57` already uses the safe `int.tryParse(...last) ?? 0`.
- **Impact:** A corrupted persisted key would crash the main screen with no recovery.
- **Fix:** Use a guarded parse / reuse `formatVerseReference`.

### ⚪ Division-by-zero risk in stats progress
- **Where:** `lib/features/stats/screens/stats_screen.dart:144,187`
- **Problem:** `versesRead / totalVerses` with no guard; a `totalVerses == 0` record yields NaN/Infinity (`.round()` throws, `LinearProgressIndicator` rejects non-finite). Entity already exposes a safe `progressPercent` getter that's ignored here. Not reachable via current write paths.
- **Impact:** A corrupted/zero-total record would crash the most data-driven screen.
- **Fix:** Guard the divisor: `ratio = totalVerses > 0 ? versesRead/totalVerses : 0.0`.

### ⚪ Recent-readings re-resolves `chaptersAsync` per row and drops rows while loading
- **Where:** `lib/features/stats/screens/stats_screen.dart:142-215`
- **Problem:** Each of up to 10 rows calls `chaptersAsync.whenOrNull(data:) ?? SizedBox.shrink()`, so during loading/error the entire 'آخر القراءات' section collapses under its still-rendered header.
- **Impact:** Transient (or permanent on failure) empty section with no spinner — looks like lost data.
- **Fix:** Resolve `chaptersAsync` once around the list with explicit loading/error states.

### ⚪ Performance: progress persisted from a postFrame callback on every flowing build
- **Where:** `lib/features/reader/screens/reader_screen.dart:391-411`
- **Problem:** The post-frame `_persistReadingPosition` is scheduled inside the `data:` builder, re-running on every rebuild (audio ticks, bookmark toggles). A de-dup guard prevents redundant I/O, but the scheduling/comparisons run per frame.
- **Impact:** Avoidable per-frame work during audio playback in a long list.
- **Fix:** Move initial persistence out of build (`ref.listen`/`initState`) and rely on the `ScrollEndNotification` handler.

### ⚪ Dialog `TextEditingController`s leaked (never disposed)
- **Where:** `lib/features/reader/screens/mushaf_view.dart:59`; `lib/features/khatmah/screens/khatmah_screen.dart:18`
- **Problem:** Page-jump and create-plan dialogs allocate method-local controllers that are never disposed. (The thematic dialog has no controller — that part of the original note was inaccurate; the memorization case is the worse `build()`-recreation bug covered above.)
- **Impact:** Minor repeatable resource leak per dialog open.
- **Fix:** Use a `StatefulWidget`/`StatefulBuilder` with a controller created in `initState` and disposed, or reuse one screen-owned controller.

---

## Theme & Color

### 🟠 Accent `#D97706` on sepia cream is a WCAG contrast failure for labels
- **Where:** `lib/core/theme/app_theme.dart:106-117`; rendered via `continue_reading_card.dart:70,96,105`, `daily_verse_card.dart:59,131`, `audio_player_bar.dart:40-255`
- **Problem:** The sepia background is `#FFFBEB` with primary `#D97706`. Small bold accent labels compute ~3.07:1 (`#D97706`) and ~1.97:1 (`Colors.amber[700]`/`#FFA000`) — below AA 4.5:1 for normal text. These accents are hardcoded onto the warm sepia surface.
- **Impact:** Accent labels and small text are hard to read in sepia — the very mode chosen for comfortable reading.
- **Fix:** Darken the sepia accent (e.g. `SepiaColors.textMuted` `#92400E` scores ~6.84:1) or route accent *text* through a higher-contrast theme token.

### 🟡 App-wide accent ignores theme tokens (~66 hardcoded `Color(0xFFD97706)`)
- **Where:** `lib/core/constants/theme_constants.dart:122-124` (tokens defined); hardcoded across ~21 files — heaviest in `lib/features/reader/widgets/audio_player_bar.dart:40,42,43,128,142,143,167,173,217,223,235,245,255`, plus `mushaf_view.dart:452,464,466,508`, `reader_screen.dart:701,710`, `chapter_header.dart:34`, `app_shell.dart:93,106,135,140`, `khatmah_screen.dart:47,78,188,300`, `stats_screen.dart:44,190`, `bookmarks_screen.dart:206,211,231`, `daily_verse_card.dart`, `continue_reading_card.dart:96`, `reciter_selector_sheet.dart:61,64,68,76,87`, `audio_section.dart:33`, `tafsir_sheet.dart:111`, `verse_card.dart:51,178,199`
- **Problem:** `appAccentColor` (#D97706), `appAccentColorLight` (#F59E0B), and `appAccentColorAmoled` (#FFB74D) are wired into each `ColorScheme.primary`, but ~66 literals bypass them. On AMOLED, where the theme deliberately uses the brighter `#FFB74D`, every hardcoded element stays the dimmer `#D97706`. *(A large family of token-bypass findings — including the mini-player, audio bar, reader, khatmah, stats, settings, and reader-sheet variants — consolidated here.)*
- **Impact:** The accent is inconsistent between these widgets and the rest of the app on AMOLED/sepia, and a future re-theme won't propagate; the white shimmer in the daily card (`daily_verse_card.dart:147`) even flashes bright on dark/AMOLED.
- **Fix:** Replace literals with `theme.colorScheme.primary` (or the per-theme `appAccentColor*` tokens); use a theme-derived surface for the shimmer. A single source of truth fixes AMOLED/sepia parity at once.

### 🟡 `Colors.amber[700]` is a second, divergent accent for labels
- **Where:** `lib/features/home/widgets/continue_reading_card.dart:70,105` (`:113` is amber[600]); also `daily_verse_card.dart:52,59,131`, `home_screen.dart:376` (amber[800]), `stats_screen.dart:56,201`, `notes_screen.dart:78,85`, `bookmarks_screen.dart:143`, `share_sheet.dart:66`, `khatmah_screen.dart:280`
- **Problem:** Labels/percentages use `Colors.amber[700]` (#FFA000) — a different, more yellow amber than the brand `#D97706` — sometimes adjacent to a `#D97706` control in the same card. Material amber is brightness-fixed.
- **Impact:** Two competing ambers appear side by side and never adapt to dark/AMOLED/sepia.
- **Fix:** Use a single accent token (`theme.colorScheme.primary`) for both labels and controls.

### 🟡 `Colors.green` completion state doesn't adapt and is dim on AMOLED
- **Where:** `lib/features/home/screens/home_screen.dart:351,360,374,452,458`; `stats_screen.dart:190,201`; `khatmah_screen.dart:300,316,358,362,367`; `memorization_screen.dart:324,332`
- **Problem:** Completion indicators use raw `Colors.green`/`green[700]`/`green[600]` with no theme variant. `green[700]` (#388E3C) text on a 0.1-alpha-green-over-black container is ~2.6:1 on AMOLED — below AA.
- **Impact:** Completion checks/labels/100% bars are hard to read on dark/AMOLED.
- **Fix:** Define a per-theme semantic "success" color (brighter for dark/AMOLED) and reference it.

### 🟡 Amber card tints use `Colors.amber.withValues` that don't adapt to brightness
- **Where:** `lib/features/home/widgets/daily_verse_card.dart:37-43`; `continue_reading_card.dart:53,56`, `verse_card.dart:162,166,220`, `share_sheet.dart:43,45`, `tafsir_sheet.dart:154,157`, `thematic_screen.dart:177,179`, `memorization_screen.dart:211,271`, `home_screen.dart:362`
- **Problem:** Card backgrounds, borders, and highlights use `Colors.amber` (#FFC107 — a different hue than the accent) at low alpha. A 0.08-alpha tint is nearly invisible on sepia cream and reads muddy on AMOLED black, off-brand vs `#FFB74D`.
- **Impact:** Highlighted verses and feature cards lose visual emphasis depending on theme.
- **Fix:** Derive tints from `theme.colorScheme.primary.withValues(alpha:...)` so hue/intensity track the active accent.

### 🟡 No `SystemUiOverlayStyle` / status-bar styling anywhere
- **Where:** `lib/app.dart:41-62`; AppBarTheme blocks in `lib/core/theme/app_theme.dart:12,60,118,193`
- **Problem:** No `systemOverlayStyle`, `AnnotatedRegion`, or `systemNavigationBarColor` is set anywhere. (AppBar auto-derives status-bar icon brightness from its background, mitigating most status-bar cases — so the original "unreadable everywhere" framing is overstated.) The real gaps: the Android navigation bar color stays at platform default and won't match the themed `NavigationBar`, and AppBar-less surfaces (mushaf reader) inherit a possibly-stale overlay style.
- **Impact:** Nav-bar color mismatch on edge-to-edge Android and potential stale overlay styling on AppBar-less screens.
- **Fix:** Set `systemOverlayStyle` per theme in `AppBarTheme` (light→dark icons, dark/amoled→light) and `systemNavigationBarColor` to match the nav surface.

### ⚪ Theme-agnostic color sets (categories, stat icons, tajweed legend pairing)
- **Where:** `lib/core/constants/theme_constants.dart:127-134` (bookmark category swatches) used at `bookmarks_screen.dart:52,83` + `mushaf_navigation_sheet.dart:397`; `stats_screen.dart:86-107` (raw `Colors.orange/green/amber/blue` icons); `tafsir_sheet.dart:111-113` + `khatmah_screen.dart:47-49` (white-on-`#D97706` chip text bypassing `onPrimary`); `app_shell.dart:93,106,135,140` (mini player uses `#D97706` not AMOLED `#FFB74D`)
- **Problem:** Several fixed color sets ignore the theme: category dots (grey `#A3A3A3` is weak on sepia cream), stat icons (a 3rd set of ambers/oranges), selected-chip white text relying on the accent staying dark instead of `onPrimary`, and the AMOLED mini-player accent. *(Grouped — all low.)*
- **Impact:** Minor per-theme legibility/consistency issues (worst: grey category dot on sepia ~2.3:1; mini-player accent off-brand on AMOLED).
- **Fix:** Use a curated semantic palette resolved from the theme, `primary`/`onPrimary` pairs for chips, and per-brightness variants (or outlines) for category dots.

### 🟡 Tajweed colors are fixed RGB, not theme-aware (poor contrast on light/sepia)
- **Where:** `lib/core/constants/theme_constants.dart:36-44`; used at `tajweed_text.dart:61`, `tajweed_legend.dart:52,62`
- **Problem:** `TajweedColors` are mid-tone constants used identically in every theme. On sepia `#FFFBEB` the pale colors fail even 3:1 (ikhfa 2.46, ikhfaMeem 2.20, silent 2.18, idghamMeem 1.79) — and the same applies to standard light. (AMOLED is actually the *best* case at 9–11:1, contrary to the original claim.)
- **Impact:** Silent-letter gray and pale meem-rule colors are hard to read in sepia/light, and legend swatches blend into the surface.
- **Fix:** Provide per-theme (or darker, higher-contrast) tajweed palettes for light-family themes.

---

## Accessibility

### 🟡 Sub-48dp tap targets across InkWell-based controls
- **Where:** `lib/features/reader/widgets/verse_card.dart:296-302` (`_ToolButton` ~36dp × 5 actions); `lib/core/widgets/app_shell.dart:126-159` (mini-player play/stop ~28–32dp); `lib/features/home/widgets/daily_verse_card.dart:63-83` (copy/share 16px icons, 32×32 constraints); `lib/features/memorization/screens/memorization_screen.dart:221-247` (verse audio ~30dp)
- **Problem:** Multiple controls are bare `InkWell`+`Padding` (or constrained smaller than 48), bypassing `IconButton`'s default 48dp tap target — below Material/WCAG 2.5.5. The five verse-action buttons sit adjacent with no spacing, compounding mis-taps. *(Several tap-target findings merged.)*
- **Impact:** Users with motor/visual impairments (and on high-DPI phones like the S25 Ultra) mis-tap or miss — e.g. Share instead of Note.
- **Fix:** Use `IconButton` (or wrap in `SizedBox(48,48)`/`ConstrainedBox(minWidth:48,minHeight:48)`); raise faint icon contrast (drop the alpha 0.6).

### 🟡 Icon-only controls lack tooltip/Semantics labels
- **Where:** `lib/core/widgets/app_shell.dart:126-159` (mini-player play/stop); `lib/features/khatmah/screens/khatmah_screen.dart:350-377` (day-completion grid); `lib/features/notes/screens/notes_screen.dart:44` + `bookmarks_screen.dart:95` (swipe-delete icon); `lib/features/memorization/screens/memorization_screen.dart:221-247` (verse audio)
- **Problem:** Several interactive controls are bare `Icon`s with no `Semantics` label or `Tooltip` — inconsistent with `audio_player_bar`/`verse_card`/reader AppBar which all set tooltips. Day cells convey neither action ("mark day N complete") nor toggle state; swipe-delete is a hidden gesture with no accessible alternative. *(Multiple a11y-label findings merged.)*
- **Impact:** TalkBack/VoiceOver users hear unlabeled "button"s and can't tell what controls do or how to delete; sighted users get no long-press hint.
- **Fix:** Add `Semantics(button: true, label/toggled: …)`/`Tooltip` to these controls and provide an explicit delete affordance alongside the swipe.

---

## Consistency (cross-cutting)

### 🟡 `UiConstants`/`QuranTypography` constants are defined but never referenced — all sizes are magic numbers
- **Where:** `lib/core/constants/ui_constants.dart:11-38`; `lib/core/constants/theme_constants.dart:11-19` (`QuranTypography`)
- **Problem:** Grep for `UiConstants.`/`QuranTypography.` returns zero matches. Every screen re-hardcodes sizes (42/28/22/20/18/24) and line heights (1.6/1.8/1.9/2.0/2.2/2.8), and the compact/normal/loose switch is duplicated verbatim in `verse_card.dart:35-44`, `reading_section.dart:16-25`, and `theme_constants.dart:4` (a 4th copy of the mapping) instead of calling `UiConstants.resolveLineHeight`.
- **Impact:** Typography is divergent across screens and the constants meant to enforce consistency have no effect, making it un-tunable.
- **Fix:** Replace magic numbers with `UiConstants`/`QuranTypography` references and call `resolveLineHeight` from one place.

### 🟡 Tajweed legend mislabels Iqlab / Ikhfa Shafawi as "Ikhfa Meem"
- **Where:** `lib/core/constants/theme_constants.dart:60-62` (mapping); surfaced at `tajweed_legend.dart:20-23` and `theme_constants.dart:72` (label)
- **Problem:** `colorMap` maps `iqlab` and `ikhfa_shafawi` to `ikhfaMeemSaakin` (light blue), whose only legend entry is 'إخفاء ميم ساكنة'. A learner reading an Iqlab letter and consulting the legend is taught the wrong rule. (The madd-grouping sub-claim is weaker — its label does include 'مد'.)
- **Impact:** In a tajweed-teaching feature where color-to-rule fidelity is the point, the legend can't truthfully explain merged-rule colors.
- **Fix:** Give iqlab/ikhfa_shafawi (and madd variants) their own colors + legend labels, or relabel the shared entry to the correct rule names.

### ⚪ Notes screen feels unfinished vs Bookmarks; word-by-word/tajweed/marker rendering inconsistencies
- **Where:** `lib/features/notes/screens/notes_screen.dart:19-21` (no count/actions); `lib/features/reader/widgets/word_by_word_widget.dart:40` (hardcoded `height: 1.6` ignores `lineHeight`); `lib/features/reader/widgets/tajweed_text.dart:29-33` (no `strutStyle`, unlike plain path); `lib/features/reader/widgets/verse_card.dart:68-89` (WBW marker detached on its own line, 8px vs tajweed 4px vs plain inline); `lib/features/bookmarks/screens/bookmarks_screen.dart:49-63` (`SizedBox` vs directional `Padding` chip separators)
- **Problem:** A cluster of small consistency gaps: the notes list lacks the count/actions its bookmarks sibling has; word-by-word hardcodes line height; the tajweed path drops the forced strut used everywhere else; the end-of-ayah marker is presented three different ways across modes; and chip separators mix mechanisms. *(Grouped — all low.)*
- **Impact:** Minor visual/typographic inconsistencies across parallel surfaces and reading modes.
- **Fix:** Surface a note count/sort action; pass `lineHeight` into `WordByWordWidget`; add the forced `StrutStyle` to `TajweedText`; unify the marker treatment and chip spacing.

---

## Recommended Fix Order

A prioritized punch-list (correctness/data-loss first, then high-leverage systemic fixes):

1. **Fix khatmah-plan import (🟠 data loss)** — restore `data['khatmahPlans']` in `backup_section.dart`, include count in the snackbar.
2. **Fix memorization controllers recreated in `build()` (🟠)** — move to `initState`/`dispose`; restores the range-entry flow.
3. **Fix memorization word-hiding + scoring (🟠)** — per-verse hidden-index map; aggregate `_total`/`_score`.
4. **Wrap `main()` DB init in try/catch + error screen (🟡 hard-lock)** — plus `runZonedGuarded`/`FlutterError.onError`.
5. **Show actual verse text in the thematic list (🟠)** — load text via batched lookup; replace raw-key subtitle with surah name.
6. **Restore audio controls on secondary screens (🟠)** — move routes into the `ShellRoute` or render the mini player app-level; fixes orphaned playback.
7. **Centralize the accent: replace ~66 `#D97706`/`amber[700]` literals with theme tokens (🟡/🟠)** — also fixes the sepia contrast failure and AMOLED parity in one sweep.
8. **Fix sepia accent-text contrast (🟠 a11y)** — darken accent text to clear AA on `#FFBEB`-family surfaces.
9. **Localize all numerals & pluralization (🟡)** — route every count/verse-key through `toArabicNumeral`/`formatVerseReference` + a plural helper; fixes the largest text-consistency cluster.
10. **Unify Quran-font usage and the dead typography constants (🟡)** — use `settings.quranFont` for all verse text; wire `UiConstants`/`QuranTypography`.
11. **Add `StatefulShellRoute.indexedStack` (🟡)** — preserves Home/Bookmarks search/scroll/filter across tabs.
12. **Improve discoverability + reader ergonomics (🟡)** — surface the 7 hidden features (More tab/grid + tooltips/icons), add in-reader font-size control, and bump core tap targets to 48dp.