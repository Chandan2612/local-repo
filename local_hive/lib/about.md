Here’s a tiny CRUD cheat-sheet for Hive (key–value + objects):

Key–value (no adapter)
Open box: final box = await Hive.openBox('userBox');

Create/Add:

auto key: final key = await box.add('Alice');

named key: await box.put('username', 'Alice');

Read:

one: box.get('username', defaultValue: '')

all: box.values.toList()

Update:

overwrite same key: await box.put('username', 'Bob');

Delete:

one: await box.delete('username');

all: await box.clear();

Reactive: box.watch(key: 'username').listen((e) { /* e.value */ });





box.watch(key: 'username') gives you a stream of change events for that key. It fires every time 'username' is added/updated (put) or deleted.

What you get in each event (e):

e.key → 'username'

e.value → the new value (or null if deleted)

e.deleted → true if it was deleted

Important: it doesn’t emit the current value on start—only future changes. Read once with box.get('username') for the initial state, then “watch” for updates.
