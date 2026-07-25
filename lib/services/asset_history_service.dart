import '../data/models/asset_history_model.dart';
import '../data/repositories/asset_history_repository.dart';
import 'financial_service.dart';

class AssetHistoryService {
  // Gunakan repository agar cara save & get seirama dengan FinancialService
  static final AssetHistoryRepository _repository = AssetHistoryRepository();

  /// Mencatat total aset saat ini ke dalam histori Hive via Repository
  static Future<void> recordCurrentAsset() async {
    final double currentAsset = FinancialService.getTotalAsset();
    final DateTime now = DateTime.now();

    // Ambil data hari ini saja (tanpa jam/menit/detik) untuk perbandingan harian
    final DateTime today = DateTime(now.year, now.month, now.day);

    // Ambil list history yang sudah ada dari repository
    final List<AssetHistoryModel> histories = _repository.getAll();

    int existingIndex = -1;

    // Cari tahu apakah sudah ada record untuk hari ini di dalam list
    for (int i = 0; i < histories.length; i++) {
      final recordDate = DateTime(
        histories[i].date.year,
        histories[i].date.month,
        histories[i].date.day,
      );
      if (recordDate.isAtSameMomentAs(today)) {
        existingIndex = i;
        break;
      }
    }

    if (existingIndex != -1) {
      // Jika sudah ada record hari ini dan jumlahnya berubah, kita perbarui datanya
      if (histories[existingIndex].amount != currentAsset) {
        histories[existingIndex] = AssetHistoryModel(
          date: now,
          amount: currentAsset,
        );
      } else {
        // Jika nilainya sama, tidak perlu save ulang ke disk (menghemat write)
        return;
      }
    } else {
      // Jika belum ada record untuk hari ini, kita tambahkan ke list
      histories.add(AssetHistoryModel(date: now, amount: currentAsset));
    }

    // Membatasi data agar tidak membengkak (Max 365 hari terakhir)
    if (histories.length > 365) {
      histories.removeAt(0);
    }

    // Simpan kembali seluruh list terupdate ke dalam satu key "history" via Repository
    await _repository.save(histories);

    // Sinkronisasi data runtime yang dipegang FinancialService agar UI langsung berubah
    FinancialService.assetHistory = histories;
  }
}
