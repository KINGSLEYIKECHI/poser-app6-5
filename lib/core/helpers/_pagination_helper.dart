import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PaginatedListModel<T> {
  final String? message;
  final PaginatedData<T>? data;

  const PaginatedListModel({this.message, this.data});

  factory PaginatedListModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedListModel<T>(
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : PaginatedData<T>.fromJson(
              json['data'] as Map<String, dynamic>,
              fromJsonT,
            ),
    );
  }

  const PaginatedListModel.empty() : this();

  PaginatedListModel<T> copyWith({
    String? message,
    PaginatedData<T>? data,
  }) {
    return PaginatedListModel<T>(
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}

class PaginatedData<T> {
  final int currentPage;
  final int lastPage;
  final List<T> data;
  final int perPage;
  final int total;

  const PaginatedData({
    this.currentPage = 1,
    this.lastPage = 1,
    this.data = const [],
    this.perPage = 0,
    this.total = 0,
  });

  bool get isLastPage => currentPage >= lastPage;

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedData<T>(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      data: [for (final item in json['data'] as List? ?? []) fromJsonT(item as Map<String, dynamic>)],
    );
  }

  PaginatedData<T> copyWith({
    int? currentPage,
    int? lastPage,
    List<T>? data,
    int? perPage,
    int? total,
  }) {
    return PaginatedData<T>(
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      data: data ?? this.data,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
    );
  }
}

mixin PaginatedControllerMixin<T> {
  late final pagingController = PagingController<int, T>(firstPageKey: 1);

  Future<PaginatedListModel<T>> fetchData(int page);

  void onPageError(Object error) {}
  void onRawData(PaginatedListModel<T> data) {}
  void initRefreshListener() {}
  void initPaging() {
    pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final _response = await fetchData(pageKey);
      final _data = _response.data ?? (throw Exception('No data found in the response.'));
      onRawData(_response);

      if (_data.isLastPage) {
        pagingController.appendLastPage(_data.data);
      } else {
        pagingController.appendPage(_data.data, _data.currentPage + 1);
      }
    } catch (error) {
      onPageError(error);
      pagingController.error = error;
    }
  }
}
