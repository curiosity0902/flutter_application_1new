import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/room_info_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AllRoomsPage extends StatefulWidget {
  const AllRoomsPage({Key? key}) : super(key: key);

  @override
  State<AllRoomsPage> createState() => _AllRoomsPageState();
}

class _AllRoomsPageState extends State<AllRoomsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController searchController = TextEditingController();
  final CollectionReference roomsCol =
      FirebaseFirestore.instance.collection('rooms');

  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0.0;
  List<QueryDocumentSnapshot> filteredRooms = [];
  bool isSearching = false;
  String? selectedCategory;

  final List<String> categories = ['Все', 'Эконом', 'Комфорт', 'Люкс'];

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';

  // Map<String, bool> loadingFavorites = {};
  Map<String, bool> favorites = {};
  bool isLoaded = false;

  @override
  void initState() {
    loadFavoriteRooms();
    _restoreScrollPosition();
    _speech = stt.SpeechToText();
    super.initState();
  }

  void loadFavoriteRooms() async {
    favorites = {};
    var data = await roomsCol.get();
    for (var room in data.docs) {
      bool isFavor = await isFavorite(room.id);
      if (isFavor) {
        setState(() {
          favorites[room.id] = true;
        });
      } else {
        setState(() {
          favorites[room.id] = false;
        });
      }
    }
    setState(() {
      isLoaded = true;
    });
  }

  void _restoreScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollPosition != 0.0) {
        _scrollController.jumpTo(_scrollPosition);
      }
    });
  }

  void filterRooms(String query, String? category) async {
    QuerySnapshot snapshot = await roomsCol.get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;

    List<QueryDocumentSnapshot> filteredList = docs.where((room) {
      String name = room['name'].toLowerCase();
      String roomCategory = room['category'];
      bool matchesCategory =
          category == null || category == 'Все' || roomCategory == category;
      bool matchesName = name.contains(query.toLowerCase());
      return matchesCategory && matchesName;
    }).toList();

    setState(() {
      filteredRooms = filteredList;
      isSearching = query.isNotEmpty || (category != null && category != 'Все');
    });
  }

  void filterRoomsByQuery(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
      });
      return;
    }

    QuerySnapshot snapshot = await roomsCol.get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;

    List<QueryDocumentSnapshot> filteredList = docs.where((room) {
      String name = room['name'].toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredRooms = filteredList;
      isSearching = true;
    });
  }

  void filterRoomsByCategory(String category) async {
    if (category == 'Все') {
      setState(() {
        isSearching = false;
        selectedCategory = null;
      });
    } else {
      QuerySnapshot snapshot =
          await roomsCol.where('category', isEqualTo: category).get();
      setState(() {
        filteredRooms = snapshot.docs;
        selectedCategory = category;
        isSearching = true;
      });
    }
  }

  Future<void> toggleFavorite(String roomId) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    // setState(() {
    //   loadingFavorites[roomId] = true;
    // });

    final userFavoritesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(roomId);

    final DocumentSnapshot doc = await userFavoritesRef.get();
    if (doc.exists) {
  
      await userFavoritesRef.delete();
      setState(() {
        favorites[roomId] = false;
      });
    } else {

      await userFavoritesRef.set({'roomId': roomId});
      setState(() {
        favorites[roomId] = true;
      });
    }

    // setState(() {
    //   loadingFavorites[roomId] = false;
    // });
  }

  Future<bool> isFavorite(String roomId) async {
    final User? user = _auth.currentUser;
    // if (user == null) return false;

    final userFavoritesRef = _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('favorites')
        .doc(roomId);

    final DocumentSnapshot doc = await userFavoritesRef.get();
    return doc.exists;
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _voiceInput = val.recognizedWords;
            searchController.text = _voiceInput;
            filterRoomsByQuery(_voiceInput);
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF9F6),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 13.0, top: 30),
                child: Text(
                  'Номера',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    // fontFamily: 'MyCustomFont',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.92,
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: const Color(0xFF4A6157),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: 'Какой номер вас интересует?',
                        hintStyle: const TextStyle(
                            color: Color.fromARGB(113, 74, 97, 87)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 1.5),
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: _isListening
                                ? const Icon(
                                    Icons.search,
                                    color: Colors.red,
                                  )
                                : const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                            onPressed: _listen,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        filterRooms(value, selectedCategory);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    categories.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = categories[index];
                          filterRooms(searchController.text, selectedCategory);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(
                          width: 150,
                          height: 85,
                          decoration: BoxDecoration(
                            color: selectedCategory == categories[index]
                                ? Colors.black
                                : Color(0xFF4A6157),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Center(
                            child: Text(
                              categories[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 5),
                child: Text(
                  'Номера для проживания',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
           isLoaded
    ? StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A6157),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Нет данных'));
          }
          final rooms = isSearching ? filteredRooms : snapshot.data!.docs;
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.47,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                DocumentSnapshot room = rooms[index];

                final name = room['name'] ?? 'Unnamed';
                final photoUrl = room['image'] ?? '';
                final category = room['category'] ?? 'No category';
                final description = room['description'] ?? 'No description';
                final cost = room['cost'] ?? 'No cost';
                final isAvailable = room['isAvailable'] ?? true;

                bool isFav = favorites[room.id] != null
                    ? favorites[room.id]!
                    : false;

                return GestureDetector(
                  onTap: isAvailable
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomInfoPage(room: room),
                            ),
                          );
                        }
                      : null, // Отключаем нажатие для недоступных номеров
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      color: isAvailable ? Colors.grey.shade200 : Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: ColorFiltered(
                                    colorFilter: isAvailable
                                        ? ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                                        : ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                    child: Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      height: 180,
                                      width: double.infinity,
                                      loadingBuilder: (BuildContext context, Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF4A6157),
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                      (loadingProgress.expectedTotalBytes ?? 1)
                                                  : null,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isAvailable ? Colors.black : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isAvailable ? Colors.grey : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        description,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isAvailable ? Colors.black : Colors.grey.shade700,
                                        ),
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            '$cost рублей',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isAvailable ? Colors.black : Colors.grey.shade700,
                                            ),
                                          ),
                                          Spacer(),
                                          if (isAvailable)
                                            IconButton(
                                              icon: Icon(
                                                isFav ? Icons.favorite : Icons.favorite_outline,
                                                color: isFav ? Colors.white : Colors.grey,
                                                size: 15,
                                              ),
                                              onPressed: () async {
                                                await toggleFavorite(room.id);
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (!isAvailable)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: Colors.black.withOpacity(0.4),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'НЕДОСТУПНО',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      )
                  : Center(
                      child: Padding(
                      padding: const EdgeInsets.only(top: 48.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A6157),
                      ),
                    )),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
