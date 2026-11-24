import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_client.dart';
import '../models/brand.dart';
import '../models/menu_item.dart';
import '../models/branch.dart';
import '../models/cart_item.dart';
import '../models/combo.dart';

enum FulfillmentMode { delivery, pickup, dinein }

class AppProvider with ChangeNotifier {
  final ApiClient _api = ApiClient.instance;
  Timer? _searchTimer;
  Timer? _shippingTimer;
  double _calculatedShippingFee = 0;
  bool _hasShippingQuote = false;
  bool isLoading = false;
  String? apiError;
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? loyaltyProfile;
  List<Map<String, dynamic>> promotions = [];
  List<Map<String, dynamic>> banners = [];
  List<Map<String, dynamic>> savedVouchers = [];
  List<Map<String, dynamic>> availableVouchers = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> toppings = [];
  List<Map<String, dynamic>> modifierGroups = [];
  List<Combo> combos = [];
  Map<String, dynamic>? flashSale;
  String get customerPhone => (currentUser?['phone'] ?? '').toString();
  String get customerId =>
      (currentUser?['id'] ?? currentUser?['_id'] ?? '').toString();
  String get memberNumber =>
      (loyaltyProfile?['memberId'] ?? (customerId.isNotEmpty ? customerId : ''))
          .toString();
  bool get isAuthenticated => _api.accessToken != null && currentUser != null;

  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  FulfillmentMode _fulfillmentMode = FulfillmentMode.delivery;
  FulfillmentMode get fulfillmentMode => _fulfillmentMode;

  String? _selectedBrandFilter;
  String? get selectedBrandFilter => _selectedBrandFilter;

  String? _selectedCategoryFilter;
  String? get selectedCategoryFilter => _selectedCategoryFilter;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int get unreadNotifications => notifications
      .where((item) => item['isRead'] != true && item['read'] != true)
      .length;

  int _memberPoints = 0;
  int get memberPoints => _memberPoints;
  String _memberTier = '';
  String get memberTier => _memberTier;
  String _memberName = 'Khách hàng';
  String get memberName => _memberName;

  late Branch _activeBranch;
  Branch get activeBranch => _activeBranch;

  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  int get cartCount => _cartItems.fold(0, (sum, i) => sum + i.quantity);
  double get cartSubtotal =>
      _cartItems.fold(0.0, (sum, i) => sum + i.totalPrice);
  double get deliveryFee => _fulfillmentMode == FulfillmentMode.delivery
      ? _calculatedShippingFee
      : 0.0;
  double get cartTotal => cartSubtotal + deliveryFee;

  late List<Brand> _brands;
  List<Brand> get brands => _brands;

  late List<MenuItem> _products;
  List<MenuItem> get products => _products;

  late List<Branch> _branches;
  List<Branch> get branches => _branches;

  AppProvider() {
    _initData();
    unawaited(refreshFromApi());
  }

  Future<void> refreshFromApi() async {
    isLoading = true;
    apiError = null;
    notifyListeners();
    final tasks = <Future<void>>[
      _loadCatalog(),
      _loadCampaigns(),
      _loadLoyalty(),
      if (isAuthenticated) _loadOrders(),
      if (isAuthenticated) _loadNotifications(),
    ];
    await Future.wait(tasks);
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCatalog() async {
    try {
      final catalogs = await Future.wait([
        _safeGet('/brands', query: const {'activeOnly': 'true'}),
        _safeGet('/branches', query: const {'activeOnly': 'true'}),
      ]);
      final remoteBrands = ApiClient.listOf(catalogs[0]['data'])
          .map(Brand.fromJson)
          .where((b) => b.id.isNotEmpty)
          .toList();
      final remoteBranches = ApiClient.listOf(catalogs[1]['data'])
          .map(Branch.fromJson)
          .where((b) => b.id.isNotEmpty)
          .toList();
      _brands = remoteBrands;
      _branches = remoteBranches;
      if (remoteBranches.isNotEmpty) {
        final selectedId = _activeBranch.id;
        _activeBranch = _branches.firstWhere((b) => b.id == selectedId,
            orElse: () => _branches.first);
        _scheduleShippingCalculation();
      } else {
        _activeBranch = Branch(
            id: '',
            name: 'Chưa chọn cơ sở',
            address: '',
            district: '',
            city: '',
            distance: '',
            rating: 0,
            reviews: 0);
        _scheduleShippingCalculation();
      }
      final results = await Future.wait([
        _safeGet('/products', query: {
          'availableOnly': 'true',
          if (_activeBranch.id.isNotEmpty) 'branchId': _activeBranch.id,
          if (_selectedBrandFilter != null) 'brandId': _selectedBrandFilter!,
          if (_selectedCategoryFilter != null)
            'category': _selectedCategoryFilter!,
          if (_searchQuery.trim().isNotEmpty) 'search': _searchQuery.trim(),
        }),
        _safeGet('/products/categories'),
        _safeGet('/products/toppings'),
        _safeGet('/modifier-groups', query: {
          if (_selectedBrandFilter != null) 'brandId': _selectedBrandFilter!
        }),
        _safeGet('/combos', query: {
          'activeOnly': 'true',
          if (_activeBranch.id.isNotEmpty) 'branchId': _activeBranch.id,
          if (_selectedBrandFilter != null) 'brandId': _selectedBrandFilter!,
        }),
      ]);
      final remoteProducts = ApiClient.listOf(results[0]['data'])
          .map(MenuItem.fromJson)
          .where((p) => p.id.isNotEmpty)
          .toList();
      _products = remoteProducts;
      categories = ApiClient.listOf(results[1]['data']);
      toppings = ApiClient.listOf(results[2]['data']);
      modifierGroups = ApiClient.listOf(results[3]['data']);
      combos = ApiClient.listOf(results[4]['data'])
          .map(Combo.fromJson)
          .where((combo) => combo.id.isNotEmpty && combo.isAvailable)
          .toList();
    } catch (error) {
      apiError = error.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> _safeGet(String path,
      {Map<String, String>? query}) async {
    try {
      return await _api.get(path, query: query);
    } catch (error) {
      apiError ??= error.toString().replaceFirst('Exception: ', '');
      return <String, dynamic>{};
    }
  }

  Future<void> _loadCampaigns() async {
    final outcomes = await Future.wait([
      _api.get('/promotions',
          query: const {'isActive': 'true'}).then((r) => r['data']),
      _api.get('/cms/banners',
          query: const {'placement': 'home_hero'}).then((r) => r['data']),
      _api.get('/cms/flash-sale/current').then((r) => r['data']),
      _api.get('/customers/vouchers').then((r) => r['data']),
    ].map((future) async {
      try {
        return await future;
      } catch (_) {
        return null;
      }
    }));
    promotions = ApiClient.listOf(outcomes[0]);
    banners = ApiClient.listOf(outcomes[1]);
    flashSale = outcomes[2] is Map
        ? Map<String, dynamic>.from(outcomes[2] as Map)
        : null;
    availableVouchers = ApiClient.listOf(outcomes[3]);
    notifyListeners();
  }

  Future<void> _loadLoyalty() async {
    try {
      final response = await _api.get('/loyalty');
      final data = response['data'];
      if (data is Map) {
        loyaltyProfile = Map<String, dynamic>.from(
            data['profile'] is Map ? data['profile'] : data);
        savedVouchers = ApiClient.listOf(data['vouchers']);
        _memberName = (loyaltyProfile?['memberName'] ?? _memberName).toString();
        _memberTier = (loyaltyProfile?['tier'] ?? _memberTier).toString();
        _memberPoints = _asInt(loyaltyProfile?['points'], _memberPoints);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _loadOrders() async {
    if (customerId.isEmpty) return;
    try {
      final response = await _api
          .get('/customers/${Uri.encodeComponent(customerId)}/orders');
      orders = ApiClient.listOf(response['data']);
    } catch (error) {
      apiError = error.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> _loadNotifications() async {
    if (!isAuthenticated) {
      notifications = [];
      notifyListeners();
      return;
    }
    try {
      final response = await _api.get('/notifications/inbox');
      notifications = ApiClient.listOf(response['data']);
    } catch (error) {
      apiError = error.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> markNotificationRead(String id) async {
    if (id.isEmpty) return;
    try {
      await _api.patch('/notifications/inbox/${Uri.encodeComponent(id)}/read');
      notifications = notifications.map((item) {
        final itemId = (item['id'] ?? item['_id'] ?? '').toString();
        return itemId == id ? {...item, 'isRead': true, 'read': true} : item;
      }).toList();
      notifyListeners();
    } catch (error) {
      apiError = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _api.patch('/notifications/inbox/mark-all-read');
      notifications = notifications
          .map((item) => {...item, 'isRead': true, 'read': true})
          .toList();
      notifyListeners();
    } catch (error) {
      apiError = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void _scheduleShippingCalculation() {
    _shippingTimer?.cancel();
    if (_fulfillmentMode != FulfillmentMode.delivery) {
      _hasShippingQuote = true;
      return;
    }
    _hasShippingQuote = false;
    _calculatedShippingFee = 0;
    if (_activeBranch.id.isEmpty) return;
    _shippingTimer = Timer(const Duration(milliseconds: 250), () async {
      try {
        final response = await _api.post('/shipping/calculate-fee', {
          'branchId': _activeBranch.id,
          'orderSubtotal': cartSubtotal,
        });
        final data = response['data'];
        if (data is Map) {
          _calculatedShippingFee =
              _asDouble(data['shippingFee'] ?? data['fee']);
          _hasShippingQuote =
              data['shippingFee'] != null || data['fee'] != null;
          notifyListeners();
        }
      } catch (_) {}
    });
  }

  Future<void> login(String identifier, String password) async {
    final response = await _api.post('/auth/login', {
      'phone': identifier.trim(),
      'password': password,
      'portal': 'CUSTOMER',
    });
    final data = response['data'];
    if (data is! Map || data['accessToken'] == null || data['user'] is! Map) {
      throw Exception('Máy chủ không trả về thông tin phiên đăng nhập.');
    }
    _api.accessToken = data['accessToken'].toString();
    _api.refreshToken = data['refreshToken']?.toString();
    loyaltyProfile = null;
    _memberPoints = 0;
    _memberTier = '';
    currentUser = Map<String, dynamic>.from(data['user']);
    _memberName =
        (currentUser?['name'] ?? currentUser?['fullName'] ?? 'Khách hàng')
            .toString();
    await Future.wait([_loadLoyalty(), _loadOrders()]);
    await _loadNotifications();
    notifyListeners();
  }

  Future<void> register(
      {required String name,
      required String phone,
      required String email,
      required String password}) async {
    await _api.post('/auth/register', {
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'password': password,
      'role': 'CUSTOMER',
    });
    await login(phone, password);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    _api.accessToken = null;
    _api.refreshToken = null;
    currentUser = null;
    orders = [];
    notifications = [];
    loyaltyProfile = null;
    savedVouchers = [];
    _memberName = 'Khách hàng';
    _memberTier = '';
    _memberPoints = 0;
    unawaited(_loadLoyalty());
    notifyListeners();
  }

  Future<Map<String, dynamic>> applyVoucher(String code) async {
    final common = <String, dynamic>{
      'code': code.trim().toUpperCase(),
      'orderAmount': cartSubtotal
    };
    if (customerPhone.isNotEmpty) common['customerPhone'] = customerPhone;
    try {
      final response = await _api.post('/customers/vouchers/validate', common);
      final data = response['data'] is Map
          ? Map<String, dynamic>.from(response['data'])
          : <String, dynamic>{};
      if (data['isValid'] == true || data['valid'] == true) return data;
    } catch (_) {}
    final response = await _api.post('/promotions/evaluate', {
      ...common,
      'branchId': _activeBranch.id,
      'items': _cartItems
          .map((item) => {'productId': item.item.id, 'quantity': item.quantity})
          .toList(),
    });
    final data = response['data'];
    if (data is Map &&
        (data['isValid'] == true || _asDouble(data['discountAmount']) > 0)) {
      return Map<String, dynamic>.from(data);
    }
    throw Exception(
        (response['message'] ?? 'Mã ưu đãi không hợp lệ hoặc đã hết hạn')
            .toString());
  }

  Future<void> redeemVoucher(String voucherId) async {
    if (!isAuthenticated)
      throw Exception('Vui lòng đăng nhập để lưu voucher vào ví.');
    await _api.post('/customers/redeem-voucher',
        {'customerId': customerId, 'voucherId': voucherId});
    await _loadLoyalty();
  }

  Future<Map<String, dynamic>> paymentStatus(String oid) =>
      _api.get('/payment/order-status/${Uri.encodeComponent(oid)}');

  Future<Map<String, dynamic>> checkout(
      {required String customerName,
      required String address,
      required String phone,
      String note = '',
      String paymentMethod = 'CASH',
      String? voucherCode,
      double discountAmount = 0}) async {
    if (!isAuthenticated) throw Exception('Vui lòng đăng nhập để đặt hàng.');
    if (_cartItems.isEmpty) throw Exception('Giỏ hàng đang trống.');
    if (customerName.trim().isEmpty)
      throw Exception('Vui lòng nhập tên người nhận.');
    if (phone.trim().length < 9)
      throw Exception('Vui lòng nhập số điện thoại hợp lệ.');
    if (_fulfillmentMode == FulfillmentMode.delivery && address.trim().isEmpty)
      throw Exception('Vui lòng nhập địa chỉ giao hàng.');
    if (_fulfillmentMode == FulfillmentMode.delivery && !_hasShippingQuote)
      throw Exception(
          'Chưa thể tính phí giao hàng. Vui lòng kiểm tra kết nối và thử lại.');
    if (_activeBranch.id.isEmpty)
      throw Exception('Vui lòng chọn cơ sở trước khi đặt món.');
    final grouped = <String, Map<String, dynamic>>{};
    for (final cart in _cartItems) {
      final branchId = _activeBranch.id;
      final brandId = cart.item.brandId ?? '';
      final key = '$branchId::$brandId';
      final unitPrice = cart.totalPrice / cart.quantity;
      final selectedModifiers = cart.toppings.map((name) {
        final match = _findTopping(name);
        return {
          'groupId': (match?['groupId'] ??
                  match?['modifierGroupId'] ??
                  match?['__groupId'] ??
                  '')
              .toString(),
          'groupName': (match?['groupName'] ?? 'Topping').toString(),
          'optionId': (match?['id'] ?? match?['_id'] ?? name).toString(),
          'optionName': name,
          'priceAdjustment': cart.toppingPrices[name] ?? 0,
        };
      }).toList();
      final item = {
        'id': cart.item.id,
        'productId': cart.item.id,
        'productName': cart.item.name,
        if (cart.isCombo) 'isCombo': true,
        'quantity': cart.quantity,
        'unitPrice': unitPrice,
        'totalPrice': unitPrice * cart.quantity,
        'size': cart.size,
        'note': cart.note ?? '',
        'selectedModifiers': selectedModifiers,
      };
      final group = grouped.putIfAbsent(
          key,
          () => {
                'branchId': branchId,
                'brandId': brandId,
                'items': <Map<String, dynamic>>[],
                'subtotal': 0,
                'shippingFee': 0,
                'discountAmount': 0,
                'notes': note.trim(),
              });
      (group['items'] as List<Map<String, dynamic>>).add(item);
      group['subtotal'] =
          (group['subtotal'] as num) + (unitPrice * cart.quantity);
    }
    final groupList = grouped.values.toList();
    final delivery = _fulfillmentMode == FulfillmentMode.delivery;
    final subtotal = groupList.fold<double>(
        0, (sum, group) => sum + _asDouble(group['subtotal']));
    for (final group in groupList) {
      group['shippingFee'] =
          delivery && group == groupList.first ? _calculatedShippingFee : 0;
      group['discountAmount'] = subtotal == 0
          ? 0
          : discountAmount * _asDouble(group['subtotal']) / subtotal;
      if (voucherCode != null) group['voucherCode'] = voucherCode;
    }
    final orderType = switch (_fulfillmentMode) {
      FulfillmentMode.delivery => 'DELIVERY',
      FulfillmentMode.pickup => 'TAKEAWAY',
      FulfillmentMode.dinein => 'DINE_IN',
    };
    final precheck = await _api.post('/orders/precheck', {
      'customerPhone': phone.trim(),
      'customerName': customerName.trim(),
      'orderType': orderType,
      'channel': 'APP',
      'deliveryAddress': delivery ? address.trim() : _activeBranch.address,
      'groupedOrders': groupList
          .map((group) => {
                'branchId': group['branchId'],
                'brandId': group['brandId'],
                'items': group['items'],
              })
          .toList(),
    });
    final precheckData = precheck['data'];
    if (precheckData is Map &&
        (precheckData['isValid'] == false ||
            precheckData['isFeasible'] == false)) {
      final errors = precheckData['errors'];
      throw Exception((errors is List && errors.isNotEmpty
              ? errors.join('\n')
              : precheckData['message'] ??
                  precheck['message'] ??
                  'Không thể phục vụ các món trong giỏ hàng.')
          .toString());
    }
    final result = await _api.post('/orders/batch-checkout', {
      'channel': 'APP',
      'customerName': customerName.trim(),
      'customerPhone': phone.trim(),
      'orderType': orderType,
      'deliveryAddress': delivery ? address.trim() : _activeBranch.address,
      'paymentMethod': paymentMethod,
      'paymentStatus': 'UNPAID',
      'groupedOrders': groupList,
      if (voucherCode != null) 'voucherCode': voucherCode,
    });
    _cartItems.clear();
    await _loadOrders();
    notifyListeners();
    return Map<String, dynamic>.from(
        result['data'] is Map ? result['data'] : result);
  }

  static int _asInt(dynamic value, [int fallback = 0]) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;
  static double _asDouble(dynamic value, [double fallback = 0]) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;

  void _initData() {
    _brands = [];
    _products = [];
    _branches = [];
    _activeBranch = Branch(
      id: '',
      name: 'Chưa chọn cơ sở',
      address: '',
      district: '',
      city: '',
      distance: '',
      rating: 0,
      reviews: 0,
    );
  }

  List<MenuItem> get bestSellers =>
      _products.where((p) => p.isBestSeller).toList();

  void setTabIndex(int index) {
    _currentTabIndex = index;
    if (index == 1) unawaited(_loadCampaigns());
    if (index == 3 && isAuthenticated) unawaited(_loadOrders());
    if (index == 4) unawaited(_loadLoyalty());
    if (index == 5) unawaited(_loadCatalog());
    if (index == 6 && isAuthenticated) unawaited(_loadNotifications());
    notifyListeners();
  }

  void setFulfillmentMode(FulfillmentMode mode) {
    _fulfillmentMode = mode;
    _scheduleShippingCalculation();
    notifyListeners();
  }

  void setSelectedBrandFilter(String? brandId) {
    _selectedBrandFilter = brandId;
    unawaited(_loadCatalog());
    notifyListeners();
  }

  void setSelectedCategoryFilter(String? categoryId) {
    _selectedCategoryFilter = categoryId;
    unawaited(_loadCatalog());
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(
        const Duration(milliseconds: 350), () => unawaited(_loadCatalog()));
    notifyListeners();
  }

  void setActiveBranch(Branch branch) {
    _activeBranch = branch;
    unawaited(_loadCatalog());
    _scheduleShippingCalculation();
    notifyListeners();
  }

  void addToCart(MenuItem item,
      {String size = '',
      double sizePriceAdjustment = 0,
      List<String> toppings = const [],
      int quantity = 1,
      String? note,
      bool isCombo = false}) {
    final toppingPrices = <String, double>{};
    for (final name in toppings) {
      final match = _findTopping(name);
      final price = match?['priceAdjustment'] ?? match?['price'];
      toppingPrices[name] = _asDouble(price);
    }
    final existingIndex = _cartItems.indexWhere(
      (ci) =>
          ci.item.id == item.id &&
          ci.isCombo == isCombo &&
          ci.size == size &&
          ci.toppings.join('|') == toppings.join('|') &&
          ci.note == note,
    );
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(
          item: item,
          size: size,
          sizePriceAdjustment: sizePriceAdjustment,
          toppings: toppings,
          toppingPrices: toppingPrices,
          quantity: quantity,
          note: note,
          isCombo: isCombo));
    }
    _scheduleShippingCalculation();
    notifyListeners();
  }

  Map<String, dynamic>? _findTopping(String name) {
    for (final group in modifierGroups) {
      final options = group['options'];
      if (options is List) {
        for (final option in options.whereType<Map>()) {
          if ((option['name'] ?? option['optionName']).toString() == name) {
            return {
              ...Map<String, dynamic>.from(option),
              '__groupId': group['id'] ?? group['_id'] ?? '',
              'groupName': group['name'] ?? group['groupName'] ?? 'Topping',
            };
          }
        }
      }
    }
    for (final topping in toppings) {
      if ((topping['name'] ?? topping['optionName']).toString() == name)
        return topping;
    }
    return null;
  }

  void updateQuantity(int index, int delta) {
    if (index < 0 || index >= _cartItems.length) return;
    _cartItems[index].quantity += delta;
    if (_cartItems[index].quantity <= 0) {
      _cartItems.removeAt(index);
    }
    _scheduleShippingCalculation();
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _scheduleShippingCalculation();
    notifyListeners();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _shippingTimer?.cancel();
    super.dispose();
  }
}
