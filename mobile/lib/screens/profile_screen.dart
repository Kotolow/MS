// mobile/lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/models/user_stats.dart';
import 'package:mobile/widgets/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/auth_provider.dart';
import 'package:mobile/widgets/bottom_navigation.dart';

class ProfileScreen extends StatefulWidget {
  final int currentIndex;

  ProfileScreen({required this.currentIndex});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserStats? userStats;

  @override
  void initState() {
    super.initState();
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    final apiService = ApiService();
    final stats = await apiService.fetchUserStats();
    setState(() {
      userStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF141218),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: userStats == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  SizedBox(height: 16),
                  Text(
                    userStats!.username,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Статистика: ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            PieChartWidget(
              dataMap: {
                'Читаю: ${userStats!.readingCount}': userStats!.readingCount.toDouble(),
                'В планах: ${userStats!.planToReadCount}': userStats!.planToReadCount.toDouble(),
                'Прочитано: ${userStats!.completedCount}': userStats!.completedCount.toDouble(),
                'Избранное: ${userStats!.favoriteCount}': userStats!.favoriteCount.toDouble(),
              },
            ),
            SizedBox(height: 16),
            Text(
              'Прочитано глав: ${userStats!.chaptersReadCount}',
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: widget.currentIndex),
    );
  }
}
