import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

// ================= App =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MeetHomePage(),
    );
  }
}

// ================= الصفحة الرئيسية =================
class MeetHomePage extends StatelessWidget {
  const MeetHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        endDrawer: const MeetDrawer(),

        // ================= AppBar =================
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F1F1F),
          elevation: 0,
          title: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Text(
                  'البحث في جهات الاتصال',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),

        // ================= Body =================
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.groups, size: 120, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                'سيظهر أحدث نشاط لك هنا',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        // ================= زر جديد =================
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blue,
          icon: const Icon(Icons.videocam),
          label: const Text('جديد'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NewMeetingPage(),
              ),
            );
          },
        ),
      ),
    );
  }

  // ================= زر موحد =================
  static Widget actionButton(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF0B4F6C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= إنشاء رابط =================
  static String generateMeetLink() {
    const chars = 'abcdefghijklmnopqrstuvwxyz';
    final rand = Random();

    String part(int len) =>
        List.generate(len, (_) => chars[rand.nextInt(chars.length)]).join();

    return 'https://meet.google.com/${part(3)}-${part(4)}-${part(3)}';
  }
}

// ================= الصفحة الثانية =================
class NewMeetingPage extends StatelessWidget {
  const NewMeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),

        // ================= AppBar مع سهم واحد =================
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          title: const Text('بدء مكالمة'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context), // سهم واحد للرجوع للقائمة الرئيسية
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: 'البحث في جهات الاتصال أو الاتصال',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  MeetHomePage.actionButton(
                    context,
                    Icons.groups,
                    'مكالمة جماعية',
                    () => _showContacts(context),
                  ),
                  const SizedBox(width: 10),
                  MeetHomePage.actionButton(
                    context,
                    Icons.calendar_today,
                    'تحديد موعد',
                    () async {
                      final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        initialDate: DateTime.now(),
                      );
                      if (date == null) return;

                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time == null) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'الموعد: ${date.year}/${date.month}/${date.day} - ${time.format(context)}',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  MeetHomePage.actionButton(
                    context,
                    Icons.link,
                    'إنشاء رابط',
                    () => _showLinkOptions(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= نافذة الرابط =================
  void _showLinkOptions(BuildContext context) {
    final link = MeetHomePage.generateMeetLink();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('رابط الاجتماع'),
        content: Text(link),
        actions: [
          TextButton(
            child: const Text('نسخ الرابط'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('مشاركة الرابط'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ================= جهات الاتصال =================
  void _showContacts(BuildContext context) {
    final contacts = [
      'Ahmed Ali',
      'Mohammed Saleh',
      'Fatima Hassan',
      'Aisha Omar',
      'Yousef Ahmed',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      builder: (_) => ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(child: Text(contacts[i][0])),
          title: Text(contacts[i]),
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم بدء مكالمة مع ${contacts[i]}'),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ================= Drawer =================
class MeetDrawer extends StatelessWidget {
  const MeetDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1F1F1F),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Google Meet',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('الإعدادات'),
            ),
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('المساعدة والملاحظات'),
            ),
          ],
        ),
      ),
    );
  }
}