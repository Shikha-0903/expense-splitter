import 'package:bloc/bloc.dart';
import 'familia_state.dart';
import 'package:expense_splitter/src/feature/familia/data/repository/familia_repository.dart';

class FamiliaCubit extends Cubit<FamiliaState> {
  final FamiliaRepository _repository;

  FamiliaCubit(this._repository) : super(FamiliaInitial());

  Future<void> init() async {
    await fetchFamily();
  }

  Future<void> fetchFamily() async {
    emit(FamiliaLoading());
    try {
      final familyData = await _repository.getCurrentFamily();
      if (familyData == null) {
        emit(FamiliaNoFamily());
      } else {
        emit(
          FamiliaLoaded(
            family: familyData['family'],
            members: familyData['members'],
          ),
        );
      }
    } catch (e) {
      emit(FamiliaError(e.toString()));
    }
  }

  Future<void> createFamily(String name) async {
    emit(FamiliaLoading());
    try {
      await _repository.createFamily(name);
      await fetchFamily();
    } catch (e) {
      emit(FamiliaError(e.toString()));
    }
  }

  Future<void> searchMembers(String query) async {
    if (query.isEmpty) {
      emit(
        FamiliaInitial(),
      ); // Or preserve current Loaded state if we are in one
      return;
    }
    try {
      final results = await _repository.searchUsers(query);
      emit(FamiliaSearching(results));
    } catch (e) {
      emit(FamiliaError(e.toString()));
    }
  }

  Future<void> addMember(String familyId, String userId) async {
    try {
      await _repository.addMember(familyId, userId);
      await fetchFamily();
    } catch (e) {
      emit(FamiliaError(e.toString()));
    }
  }
}
