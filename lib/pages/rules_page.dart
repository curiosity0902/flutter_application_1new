import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RulesPage extends StatefulWidget {
  const RulesPage({super.key});

  @override
  State<RulesPage> createState() => _RulesPageState();
}

class _RulesPageState extends State<RulesPage> {
  String _selectedRuleName = '';
  String _selectedRuleDescription = '';

  Future<List<Map<String, dynamic>>> _fetchRules() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('rules').get();
    return querySnapshot.docs.map((doc) {
      return {
        'name': doc['name'],
        'description': doc['description'],
      };
    }).toList();
  }

  void _showBottomSheet(String name, String description) {
    setState(() {
      _selectedRuleName = name;
      _selectedRuleDescription = description;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _selectedRuleName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedRuleDescription,
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A6157),
            ),
            onPressed: () => Navigator.pop(context),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 90.0, vertical: 5),
              child: const Text(
                'Понятно, спасибо',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Правила посещения отеля'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: const Color(0xFF4A6157),
            ));
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ошибка при загрузке данных.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет данных.'));
          }
          List<Map<String, dynamic>> rules = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(top: 18.0),
            child: ListView.builder(
              itemCount: rules.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  child: ListTile(
                    title: Text(
                      rules[index]['name'],
                      style: const TextStyle(color: Colors.black),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      _showBottomSheet(
                          rules[index]['name'], rules[index]['description']);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
