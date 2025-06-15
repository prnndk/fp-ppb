import 'package:final_project_ppb/components/custom_card.dart';
import 'package:final_project_ppb/components/custom_textfield.dart';
import 'package:final_project_ppb/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project_ppb/components/custom_button.dart';
import 'package:final_project_ppb/models/menu.dart';
import 'package:final_project_ppb/models/reservation.dart';
import 'package:final_project_ppb/services/menu_service.dart';
import 'package:final_project_ppb/screens/orderconfirm_screen.dart';
import 'package:final_project_ppb/screens/homepage.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({Key? key}) : super(key: key);

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final TextEditingController _guestCountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final MenuService _menuService = MenuService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _timeDisplayText = '';

  List<MenuItem> menuItems = [];
  List<MenuItem> allMenuItems = [];
  List<MenuItem> filteredMenuItems = [];
  bool _isLoadingMenus = true;
  String? _errorMessage;
  // String _selectedCategory = 'All';

  // Pagination state
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isSearchMode = false;

  Map<int, int> selectedItems = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoadingMenus = true;
        _errorMessage = null;
      });

      final allMenus = await _menuService.getAllMenus();
      final menuResponse = await _menuService.getMenus(page: 1);

      setState(() {
        allMenuItems = allMenus;
        menuItems = menuResponse.data.data;
        _totalPages = menuResponse.data.lastPage;
        _currentPage = 1;
        _isLoadingMenus = false;
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingMenus = false;
      });
    }
  }

  Future<void> _loadMenus() async {
    if (_isSearchMode) return;
    try {
      setState(() {
        _isLoadingMenus = true;
        _errorMessage = null;
      });

      final menuResponse = await _menuService.getMenus(page: _currentPage);

      setState(() {
        menuItems = menuResponse.data.data;
        _totalPages = menuResponse.data.lastPage;
        _isLoadingMenus = false;
        // Reset category filter when changing pages to avoid empty results
        // _selectedCategory = 'All';
        _applyFilters();
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingMenus = false;
      });
    }
  }

  Future<void> _goToPage(int page) async {
    if (page >= 1 &&
        page <= _totalPages &&
        page != _currentPage &&
        !_isLoadingMenus &&
        !_isSearchMode) {
      _currentPage = page;
      await _loadMenus();
    }
  }

  Future<void> _nextPage() async {
    if (_currentPage < _totalPages && !_isLoadingMenus && !_isSearchMode) {
      _currentPage++;
      await _loadMenus();
    }
  }

  Future<void> _previousPage() async {
    if (_currentPage > 1 && !_isLoadingMenus && !_isSearchMode) {
      _currentPage--;
      await _loadMenus();
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    List<MenuItem> sourceItems;

    // Buat search
    bool isSearching = query.isNotEmpty;
    setState(() {
      _isSearchMode = isSearching;
    });
    if (isSearching) {
      sourceItems = allMenuItems; // Search across all items
    } else {
      sourceItems = menuItems; // Use current page items
    }

    List<MenuItem> filtered = sourceItems;

    // if (_selectedCategory != 'All') {
    //   filtered =
    //       filtered.where((menu) => menu.category == _selectedCategory).toList();
    // }

    // Apply search filter
    if (query.isNotEmpty) {
      filtered =
          filtered.where((menu) {
            return menu.name.toLowerCase().contains(query) ||
                menu.category.toLowerCase().contains(query) ||
                (menu.description?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    setState(() {
      filteredMenuItems = filtered;
    });
  }

  // List<String> get _categories {
  //   Set<String> categorySet = {'All'};

  //   // Use appropriate data source for categories
  //   List<MenuItem> sourceItems = _isSearchMode ? allMenuItems : menuItems;

  //   for (var menu in sourceItems) {
  //     categorySet.add(menu.category);
  //   }
  //   return categorySet.toList();
  // }

  // Get all categories from all menu items (for search mode)
  // List<String> get _allCategories {
  //   Set<String> categorySet = {'All'};
  //   for (var menu in allMenuItems) {
  //     categorySet.add(menu.category);
  //   }
  //   return categorySet.toList();
  // }

  // Widget _buildCategoryPill(String category) {
  //   bool isSelected = _selectedCategory == category;
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         _selectedCategory = category;
  //         _applyFilters();
  //       });
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.only(right: 8),
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  //       decoration: BoxDecoration(
  //         color: isSelected ? const Color(0xFF8B4513) : Colors.white,
  //         borderRadius: BorderRadius.circular(25),
  //         border: Border.all(color: const Color(0xFF8B4513), width: 1),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.05),
  //             blurRadius: 4,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: Text(
  //         category,
  //         style: TextStyle(
  //           fontFamily: 'Montserrat',
  //           fontSize: 14,
  //           fontWeight: FontWeight.w600,
  //           color: isSelected ? Colors.white : const Color(0xFF8B4513),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPaginationButtons() {
    if (_totalPages <= 1 || _isSearchMode) return const SizedBox.shrink();

    List<Widget> buttons = [];

    // Previous button
    buttons.add(
      GestureDetector(
        onTap: _currentPage > 1 ? _previousPage : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                _currentPage > 1 ? const Color(0xFF8B4513) : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chevron_left,
            color: _currentPage > 1 ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
      ),
    );

    // Pagination
    int startPage = (_currentPage - 2).clamp(1, _totalPages);
    int endPage = (_currentPage + 2).clamp(1, _totalPages);

    for (int i = startPage; i <= endPage; i++) {
      buttons.add(_buildPageButton(i));
    }

    if (endPage < _totalPages) {
      if (endPage < _totalPages - 1) {
        buttons.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                color: Color(0xFF8B4513),
              ),
            ),
          ),
        );
      }
      buttons.add(_buildPageButton(_totalPages));
    }

    // Next button
    buttons.add(
      GestureDetector(
        onTap: _currentPage < _totalPages ? _nextPage : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                _currentPage < _totalPages
                    ? const Color(0xFF8B4513)
                    : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chevron_right,
            color: _currentPage < _totalPages ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            buttons
                .map(
                  (button) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: button,
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildPageButton(int pageNumber) {
    bool isCurrentPage = pageNumber == _currentPage;

    return GestureDetector(
      onTap: !isCurrentPage ? () => _goToPage(pageNumber) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentPage ? const Color(0xFF8B4513) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentPage ? const Color(0xFF8B4513) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isCurrentPage ? Colors.white : const Color(0xFF8B4513),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search menu items...',
          hintStyle: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                    },
                    child: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Color(0xFF000000),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
          _timeDisplayText =
              '${pickedDate.day}/${pickedDate.month}/${pickedDate.year} - ${pickedTime.format(context)}';
        });
      }
    }
  }

  void _onQuantityChanged(MenuItem item, int quantity) {
    setState(() {
      if (quantity > 0) {
        selectedItems[item.id] = quantity;
      } else {
        selectedItems.remove(item.id);
      }
    });
  }

  int _getQuantityForItem(MenuItem item) {
    return selectedItems[item.id] ?? 0;
  }

  void _proceedToOrderConfirmation() {
    if (_selectedDate == null || _selectedTime == null) {
      _showErrorSnackBar('Pilih waktu reservasi terlebih dahulu');
      return;
    }

    if (_guestCountController.text.isEmpty) {
      _showErrorSnackBar('Pilih jumlah tamu terlebih dahulu');
      return;
    }

    if (selectedItems.isEmpty) {
      _showErrorSnackBar('Pilih menu terlebih dahulu');
      return;
    }

    int numberOfGuests = int.tryParse(_guestCountController.text) ?? 0;
    if (numberOfGuests <= 0) {
      _showErrorSnackBar('Pilih jumlah tamu yang valid');
      return;
    }

    List<OrderItem> orderItems = [];
    double totalAmount = 0;

    for (var entry in selectedItems.entries) {
      MenuItem? menuItem;
      try {
        menuItem = allMenuItems.firstWhere((item) => item.id == entry.key);
      } catch (e) {
        _showErrorSnackBar(
          'Error: Menu item not found. Please refresh the page.',
        );
        return;
      }

      int quantity = entry.value;
      double itemTotal = menuItem.price * quantity;

      orderItems.add(
        OrderItem(
          menuId: menuItem.id,
          menuName: menuItem.name,
          quantity: quantity,
          price: menuItem.price,
          totalPrice: itemTotal,
        ),
      );

      totalAmount += itemTotal;
    }

    Reservation reservation = Reservation(
      reservationDate: _selectedDate!,
      reservationTime: _selectedTime!.format(context),
      numberOfGuests: numberOfGuests,
      orderItems: orderItems,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderConfirmationPage(
              reservation: reservation,
              menuItems: allMenuItems,
            ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showChatActionSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Get Menu Recommendation',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Chat with our bot to get personalized menu recommendations',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Color(0xFF643F04),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Cancel',
                              onPressed: () => Navigator.pop(context),
                              backgroundColor: Colors.grey[300],
                              textColor: const Color(0xFF643F04),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Start Chat',
                              onPressed: () {
                                Navigator.pop(context);
                                _navigateToChatPage();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAEE),
      body: Column(
        children: [
          // Header Section
          Container(
            height: 197,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/restoran.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B4513).withOpacity(0.7),
                    const Color(0xFF8B4513).withOpacity(0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Home',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Chev Au Restaurant',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Star michelin restaurant',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFFAEE),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pemesanan',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF643F04),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DateTime Picker
                    GestureDetector(
                      onTap: _selectDateTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Jam Pemesanan *',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF643F04),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF8B4513),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _timeDisplayText.isEmpty
                                      ? 'Pilih tanggal dan waktu'
                                      : _timeDisplayText,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    color:
                                        _timeDisplayText.isEmpty
                                            ? Colors.grey[600]
                                            : const Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                            if (_timeDisplayText.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text(
                                  'Contoh: 21/08/2025 - 19:00',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Guest Count Field
                    CustomTextField(
                      labelText: "Jumlah Tamu",
                      exampleText: "2",
                      controller: _guestCountController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of guests';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Menu Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Our Menu',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF643F04),
                          ),
                        ),
                        if (!_isLoadingMenus)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${filteredMenuItems.length} items',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Color(0xFF643F04),
                                ),
                              ),
                              if (!_isSearchMode)
                                Text(
                                  'Page $_currentPage of $_totalPages',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                              if (_isSearchMode)
                                const Text(
                                  'Search Results',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Bar
                    _buildSearchBar(),
                    const SizedBox(height: 16),

                    // if (!_isLoadingMenus &&
                    //     (_isSearchMode
                    //         ? allMenuItems.isNotEmpty
                    //         : menuItems.isNotEmpty)) ...[
                    //   SingleChildScrollView(
                    //     scrollDirection: Axis.horizontal,
                    //     child: Row(
                    //       children:
                    //           _categories.map(_buildCategoryPill).toList(),
                    //     ),
                    //   ),
                    //   const SizedBox(height: 20),
                    // ],

                    // Menu Items
                    if (_isLoadingMenus)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red[600],
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to load menu',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (filteredMenuItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              color: Colors.grey[400],
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No menu items found',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filter',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          ...filteredMenuItems.map((menuItem) {
                            return MenuCard(
                              menuItem: menuItem,
                              onQuantityChanged: _onQuantityChanged,
                              currentQuantity: _getQuantityForItem(
                                menuItem,
                              ), // Pass the current quantity
                            );
                          }).toList(),

                          // Pagination buttons (only show when not in search mode)
                          _buildPaginationButtons(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: _showChatActionSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'Not Sure What to Order?',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Chat with our bot to get menu recommendation',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Button Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              text: 'Lanjutkan ke Konfirmasi Pesanan',
              onPressed: _proceedToOrderConfirmation,
            ),
          ),
        ],
      ),
    );
  }
}
