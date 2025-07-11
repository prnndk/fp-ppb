import 'package:final_project_ppb/models/preferensi.dart';
import 'package:final_project_ppb/services/preferences_service.dart';
import 'package:final_project_ppb/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:final_project_ppb/screens/homepage.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';

const List<Widget> halal = <Widget>[
  Text('Halal'),
  Text('Non Halal'),
  Text('Kosher'),
];
const List<Widget> lactose = <Widget>[
  Text('Bebas Gluten'),
  Text('Bebas Laktosa'),
  Text('Tidak Bebas Gluten dan Laktosa'),
];
const List<Widget> vegetarian = <Widget>[
  Text('Vegetarian'),
  Text('Non-Vegetarian'),
];

List<MultiSelectCard> allergyOptions = [
  MultiSelectCard(value: 'kacang', label: 'Kacang-kacangan', selected: false),
  MultiSelectCard(
    value: 'susu',
    label: 'Susu/Produk Olahan Susu',
    selected: false,
  ),
  MultiSelectCard(value: 'telur', label: 'Telur', selected: false),
  MultiSelectCard(value: 'kedelai', label: 'Kedelai', selected: false),
  MultiSelectCard(value: 'gluten', label: 'Gandum/Gluten', selected: false),
  MultiSelectCard(value: 'ikan', label: 'Ikan', selected: false),
  MultiSelectCard(value: 'kerang', label: 'Kerang-kerangan', selected: false),
  MultiSelectCard(value: 'seafood', label: 'Seafood lainnya', selected: false),
  MultiSelectCard(value: 'biji', label: 'Biji-bijian', selected: false),
  MultiSelectCard(value: 'jagung', label: 'Jagung', selected: false),
  MultiSelectCard(value: 'mustard', label: 'Mustard', selected: false),
  MultiSelectCard(value: 'seledri', label: 'Seledri', selected: false),
  MultiSelectCard(value: 'lupin', label: 'Lupin', selected: false),
  MultiSelectCard(value: 'sulfites', label: 'Sulfites', selected: false),
  MultiSelectCard(
    value: 'buah',
    label: 'Buah-buahan tertentu',
    selected: false,
  ),
  MultiSelectCard(value: 'sayuran', label: 'Sayuran tertentu', selected: false),
];

class UserPreferenceScreen extends StatefulWidget {
  const UserPreferenceScreen({super.key});

  @override
  State<UserPreferenceScreen> createState() => _UserPreferenceScreen();
}

class _UserPreferenceScreen extends State<UserPreferenceScreen> {
  final List<bool> _selectedHalal = <bool>[false, false, false];
  final List<bool> _selectedLactose = <bool>[false, false, false];
  final List<bool> _selectedVegetarian = <bool>[false, false];

  final MultiSelectController _multiSelectController = MultiSelectController(
    deSelectPerpetualSelectedItems: false,
  );

  final noteTextController = TextEditingController();

  late Future<Preferensi?> dataUser;

  bool _isEditingHalal = false;
  bool _isEditingLactose = false;
  bool _isEditingVegetarian = false;

  bool _isEditedHalal = false;
  bool _isEditedLactose = false;
  bool _isEditedVegetarian = false;

  UserService us = UserService();
  PreferencesService ps = PreferencesService();

  @override
  void initState() {
    super.initState();
    dataUser = ps.getPreferensiByUserId(us.getCurrentUser()?.uid ?? '');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void continueProcess() async {
    Preferensi? currentPreference = await dataUser;

    if (currentPreference != null) {
      _updatePreferences();
    } else {
      _createPreferences();
    }
  }

  void _loadPreferences() {
    setState(() {
      dataUser = ps.getPreferensiByUserId(us.getCurrentUser()?.uid ?? '');
    });
  }

  void _updatePreferences() async {
    Preferensi? currentPreference = await dataUser;

    if (currentPreference == null) {
      _showErrorSnackBar("No existing preferences found to update");
      return;
    }

    Preferensi preferensi = Preferensi(
      id: currentPreference.id,
      userId: us.getCurrentUser()!.uid,
      seafoodPreference: (halal[_selectedHalal.indexOf(true)] as Text).data!,
      lactosePreference:
          (lactose[_selectedLactose.indexOf(true)] as Text).data!,
      vegetarianPreference:
          (vegetarian[_selectedVegetarian.indexOf(true)] as Text).data!,
      allergies:
          _multiSelectController.getSelectedItems().isEmpty
              ? currentPreference.allergies ?? []
              : _multiSelectController
                  .getSelectedItems()
                  .map((item) => item is String ? item : item.value.toString())
                  .toList()
                  .toSet()
                  .toList(),
      note: noteTextController.text.trim(),
    );

    ps.updatePreferensi(preferensi);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferensi berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createPreferences() {
    Preferensi preferensi = Preferensi(
      id: UniqueKey().toString(),
      userId: us.getCurrentUser()!.uid,
      seafoodPreference: (halal[_selectedHalal.indexOf(true)] as Text).data!,
      lactosePreference:
          (lactose[_selectedLactose.indexOf(true)] as Text).data!,
      vegetarianPreference:
          (vegetarian[_selectedVegetarian.indexOf(true)] as Text).data!,
      allergies:
          _multiSelectController
              .getSelectedItems()
              .map((item) => item is String ? item : item.value.toString())
              .toList(),
      note: noteTextController.text.trim(),
    );

    ps.createPreferensi(preferensi);

    // success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferensi berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );

    _loadPreferences();
  }

  void _processDeletion() async {
    Preferensi? currentPreference = await dataUser;

    if (currentPreference == null) {
      _showErrorSnackBar("No existing preferences found to delete");
      return;
    }

    await ps.deletePreferensi(currentPreference.id, currentPreference.userId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferensi berhasil dihapus'),
        backgroundColor: Colors.green,
      ),
    );

    // go back to home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _markAsEdited(String section) {
    setState(() {
      switch (section) {
        case 'halal':
          _isEditedHalal = true;
          break;
        case 'lactose':
          _isEditedLactose = true;
          break;
        case 'vegetarian':
          _isEditedVegetarian = true;
          break;
      }
    });
  }

  void _triggerDelete() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Hapus Preferensi Pengguna',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF643F04),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Apakah Anda yakin ingin menghapus preferensi pengguna? Tindakan ini tidak dapat dibatalkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                        _processDeletion();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Hapus Preferensi',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _proceedPreferences() {
    if (_selectedHalal.every((element) => !element) ||
        _selectedLactose.every((element) => !element) ||
        _selectedVegetarian.every((element) => !element)) {
      _showErrorSnackBar("Pastikan memilih salah satu preferensi makanan");
      return;
    }

    if (_multiSelectController.getSelectedItems().isEmpty ||
        noteTextController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text(
              'Anda belum memilih alergi makanan. Apakah Anda yakin tidak memiliki alergi?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  continueProcess();
                },
                child: const Text('Ya, Lanjutkan'),
              ),
            ],
          );
        },
      );
      return;
    } else {
      continueProcess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
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
                      // Restaurant Title
                      const Text(
                        'Preferensi Pengguna',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<Preferensi?>(
              future: dataUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (snapshot.hasData && snapshot.data != null) {
                    final preferensi = snapshot.data!;
                    final allergiesList = preferensi.allergies;

                    for (var card in allergyOptions) {
                      card.selected = allergiesList.contains(card.value);
                    }

                    if (!_isEditedHalal) {
                      int halalIndex = halal.indexWhere(
                        (e) => (e as Text).data == preferensi.seafoodPreference,
                      );
                      if (halalIndex != -1) {
                        _selectedHalal[halalIndex] = true;
                      }
                    }

                    if (!_isEditedLactose) {
                      int lactoseIndex = lactose.indexWhere(
                        (e) => (e as Text).data == preferensi.lactosePreference,
                      );
                      if (lactoseIndex != -1) {
                        _selectedLactose[lactoseIndex] = true;
                      }
                    }

                    if (!_isEditedVegetarian) {
                      int vegetarianIndex = vegetarian.indexWhere(
                        (e) =>
                            (e as Text).data == preferensi.vegetarianPreference,
                      );
                      if (vegetarianIndex != -1) {
                        _selectedVegetarian[vegetarianIndex] = true;
                      }
                    }
                  }
                  noteTextController.text = snapshot.data?.note ?? '';

                  return Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFAEE),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    transform: Matrix4.translationValues(0, -20, 0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Data Pengguna',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF643F04),
                                ),
                              ),
                              if (snapshot.hasData && snapshot.data != null)
                                IconButton(
                                  onPressed: () {
                                    _triggerDelete();
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Color(0xFF643F04),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              preferenceSection(
                                'Preferensi Halal',
                                halal,
                                _selectedHalal,
                                theme,
                                isEdited: _isEditedHalal,
                              ),
                              preferenceSection(
                                'Preferensi Vegetarian',
                                vegetarian,
                                _selectedVegetarian,
                                theme,
                                isEdited: _isEditedVegetarian,
                              ),
                              preferenceSection(
                                'Preferensi Laktosa dan Gluten',
                                lactose,
                                _selectedLactose,
                                theme,
                                vertical: true,
                                isEdited: _isEditedLactose,
                              ),
                              const SizedBox(height: 32),

                              const Text(
                                'Alergi Makanan',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF643F04),
                                ),
                              ),

                              const SizedBox(height: 16),

                              MultiSelectContainer(
                                itemsDecoration: MultiSelectDecorations(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: const Color(0xFF643F04),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                controller: _multiSelectController,
                                items: allergyOptions,
                                onChange: (allSelectedItems, selectedItem) {},
                              ),
                              const SizedBox(height: 32),

                              const Text(
                                'Note Tambahan',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF643F04),
                                ),
                              ),

                              const SizedBox(height: 16),

                              TextField(
                                maxLines: 2,
                                controller: noteTextController,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan catatan tambahan',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: const Color(0xFF643F04),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _proceedPreferences,
        backgroundColor: const Color(0xFF4A2C2A),
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }

  Widget preferenceSection(
    String title,
    List<Widget> options,
    List<bool> selectedValues,
    ThemeData theme, {
    bool vertical = false,
    bool isEdited = false,
  }) {
    bool isEditing;
    Function(bool) updateIsEditing;

    if (title.contains('Halal')) {
      isEditing = _isEditingHalal;
      updateIsEditing = (value) => setState(() => _isEditingHalal = value);
    } else if (title.contains('Vegetarian')) {
      isEditing = _isEditingVegetarian;
      updateIsEditing = (value) => setState(() => _isEditingVegetarian = value);
    } else {
      isEditing = _isEditingLactose;
      updateIsEditing = (value) => setState(() => _isEditingLactose = value);
    }

    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.check : Icons.edit,
                    size: 18,
                    color: const Color(0xFF643F04),
                  ),
                  onPressed: () {
                    updateIsEditing(!isEditing);
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: double.infinity,
              child: Center(
                child: AbsorbPointer(
                  absorbing: !isEditing,
                  child: ToggleButtons(
                    direction: vertical ? Axis.vertical : Axis.horizontal,
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < selectedValues.length; i++) {
                          selectedValues[i] = i == index;
                        }
                      });

                      if (title.contains('Halal')) {
                        _markAsEdited('halal');
                      } else if (title.contains('Vegetarian')) {
                        _markAsEdited('vegetarian');
                      } else {
                        _markAsEdited('lactose');
                      }
                    },

                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor:
                        isEditing
                            ? Colors.grey.shade400
                            : const Color(0xFF643F04),
                    borderColor: Colors.grey.shade400,
                    selectedColor: Colors.white,
                    fillColor: const Color(0xFF643F04),
                    color: isEditing ? Colors.black87 : Colors.black54,
                    constraints: BoxConstraints(
                      minHeight: 40.0,
                      minWidth: vertical ? 250.0 : 120.0,
                    ),
                    isSelected: selectedValues,
                    children: options,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
