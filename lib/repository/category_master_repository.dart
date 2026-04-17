import '../data/network/base_api_services.dart';
import '../data/network/network_api_services.dart';
import '../database/app_database.dart';
import '../model/category_master_model.dart';
import '../res/widgets/app_urls.dart';
import 'package:drift/drift.dart';

class CategoryMasterRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  final AppDatabase _db = AppDatabase();


  Future<List<CategoryMasterModel>> fetchCategoryMasters() async {
    try {
      final String url = AppUrls.getCategoryMasterUrl;

      dynamic response = await _apiServices.getGetApiResponse(url);

      List<CategoryMasterModel> apiList =
      (response as List).map((e) => CategoryMasterModel.fromJson(e)).toList();

      final driftList = apiList.map((e) {
        return CategoriesCompanion(
          cateId: Value(e.CateId ?? 0),
          cateName: Value(e.CateName),
          cateShortName: Value(e.CateShortName),
          isHardware: Value(e.IsHardware),
        );
      }).toList();

      await _db.clearCategories();
      await _db.insertCategories(driftList);

      return apiList;
    } catch (e) {
      print("API failed, loading Categories from local DB");

      final localData = await _db.getAllCategories();

      return localData.map((e) {
        return CategoryMasterModel(
          CateId: e.cateId,
          CateName: e.cateName,
          CateShortName: e.cateShortName,
          IsHardware: e.isHardware,
        );
      }).toList();
    }
  }
}
