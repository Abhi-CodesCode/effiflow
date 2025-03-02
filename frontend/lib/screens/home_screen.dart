import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/app_clipboard_provider.dart';

import '../providers/auth_provider.dart';
import '../providers/tasks_provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userData = ref.watch(userProvider);
    final tasks = ref.watch(tasksProvider);
    final appClipboardData = ref.watch(appClipboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final auth = ref.read(authProvider.notifier);
              await auth.logout();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: userData.when(
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
                data: (user) => Text(
                  'Welcome to the Task Manager, ${user['name']}!',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            tasks.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (tasks) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(task.description),
                    leading: Checkbox(
                      value: task.status == 'completed',
                      onChanged: (value) {
                        // Handle task completion
                      },
                    ),
                  );
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Clipboard Data',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            appClipboardData.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (appClipboardData) => appClipboardData == null
                  ? const Center(child: Text('No clipboard data found'))
                  : ListTile(
                title: Text(appClipboardData.content),
                subtitle: Text('Timestamp: ${appClipboardData.createdAt}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}