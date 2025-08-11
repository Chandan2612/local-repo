import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

const String kUserBox = 'userBox';
const String kUsernameKey = 'username';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Init Hive (works on Android/iOS/Web/Desktop)
  await Hive.openBox(kUserBox); // Open a simple box
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Username Demo',
      theme: ThemeData(useMaterial3: true),
      home: const NameScreen(),
    );
  }
}

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});
  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  late final Box _box;
  final TextEditingController _controller = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _box = Hive.box(kUserBox);
    final saved = _box.get(kUsernameKey) as String?;
    _controller.text = saved ?? '';
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      _showSnack('Name can’t be empty');
      return;
    }
    await _box.put(kUsernameKey, name);
    setState(() => _editing = false);
    _showSnack('Saved');
  }

  Future<void> _delete() async {
    await _box.delete(kUsernameKey);
    setState(() {
      _controller.clear();
      _editing = true; // Switch to input mode after delete
    });
    _showSnack('Deleted');
  }

  void _startEdit() {
    setState(() => _editing = true);
  }

  void _cancelEdit() {
    final saved = _box.get(kUsernameKey) as String?;
    setState(() {
      _controller.text = saved ?? '';
      _editing = false;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final savedName = _box.get(kUsernameKey) as String?;
    final hasName = savedName != null && savedName.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Hello with Hive')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasName && !_editing) ...[
                  Text('Welcome, $savedName 👋', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(onPressed: _startEdit, child: const Text('Edit')),
                      const SizedBox(width: 12),
                      OutlinedButton(onPressed: _delete, child: const Text('Delete')),
                    ],
                  ),
                ] else ...[
                  Text('Enter your name', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Your name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton(onPressed: _save, child: const Text('Save')),
                      if (hasName) ...[
                        const SizedBox(width: 12),
                        OutlinedButton(onPressed: _cancelEdit, child: const Text('Cancel')),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
