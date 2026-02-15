import 'package:equatable/equatable.dart';

class ReaderSession extends Equatable {
  final int chapterId;
  final String verseKey;
  final int? mushafPage;
  final String viewMode;
  final int timestamp;

  const ReaderSession({
    required this.chapterId,
    required this.verseKey,
    required this.viewMode,
    required this.timestamp,
    this.mushafPage,
  });

  ReaderSession copyWith({
    int? chapterId,
    String? verseKey,
    int? mushafPage,
    String? viewMode,
    int? timestamp,
  }) {
    return ReaderSession(
      chapterId: chapterId ?? this.chapterId,
      verseKey: verseKey ?? this.verseKey,
      mushafPage: mushafPage ?? this.mushafPage,
      viewMode: viewMode ?? this.viewMode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'verseKey': verseKey,
      'mushafPage': mushafPage,
      'viewMode': viewMode,
      'timestamp': timestamp,
    };
  }

  factory ReaderSession.fromJson(Map<String, dynamic> json) {
    return ReaderSession(
      chapterId: json['chapterId'] as int? ?? 1,
      verseKey: json['verseKey'] as String? ?? '1:1',
      mushafPage: json['mushafPage'] as int?,
      viewMode: json['viewMode'] as String? ?? 'flowing',
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [chapterId, verseKey, mushafPage, viewMode, timestamp];
}
