import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/note.dart';
import '../../services/local/hive_helper.dart';

final noteNotifierProvider =
StateNotifierProvider<NoteNotifier, AsyncValue<List<Note>>>(
      (ref) => NoteNotifier()..fetchAllNotes(),
);

class NoteNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final _hiveHelper = HiveHelper();
  final _uuid = const Uuid();

  NoteNotifier() : super(const AsyncLoading());

  Future<void> fetchAllNotes() async {
    try {
      await _hiveHelper.init();
      final notes = await _hiveHelper.getNotes();
      state = AsyncData(notes);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> add(Note note) async {
    try {
      await _hiveHelper.init();
      final newNote = note.copyWith(id: _uuid.v4());
      await _hiveHelper.addOrUpdate(newNote);
      await fetchAllNotes();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> update(Note note) async {
    try {
      await _hiveHelper.init();
      await _hiveHelper.addOrUpdate(note);
      await fetchAllNotes();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _hiveHelper.init();
      await _hiveHelper.delete(id);
      await fetchAllNotes();
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
