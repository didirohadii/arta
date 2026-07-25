import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'auth_service.dart'; // Import AuthService untuk mengambil nama user
import 'financial_service.dart';
import 'report_service.dart';

class ExportService {
  // ==========================================
  // EXPORT KE EXCEL
  // ==========================================
  static Future<void> exportExcel() async {
    final report = ReportService.generate();
    final profile = FinancialService.getProfile();

    final excel = Excel.createExcel();

    // 1. SHEET: SUMMARY
    final summarySheet = excel['Summary'];
    summarySheet.appendRow([TextCellValue("ARTA Financial Report")]);
    summarySheet.appendRow([]);

    summarySheet.appendRow([
      TextCellValue("Total Asset"),
      DoubleCellValue(report.asset),
    ]);
    summarySheet.appendRow([
      TextCellValue("Income"),
      DoubleCellValue(report.income),
    ]);
    summarySheet.appendRow([
      TextCellValue("Expense"),
      DoubleCellValue(report.expense),
    ]);
    summarySheet.appendRow([
      TextCellValue("Cash Flow"),
      DoubleCellValue(report.balance),
    ]);

    // 2. SHEET: WALLET
    final walletSheet = excel['Wallet'];
    walletSheet.appendRow([
      TextCellValue("Nama"),
      TextCellValue("Jenis"),
      TextCellValue("Saldo Awal"),
      TextCellValue("Saldo Saat Ini"),
    ]);

    for (final wallet in report.wallets) {
      final currentBalance = FinancialService.getWalletBalance(wallet.id);

      walletSheet.appendRow([
        TextCellValue(wallet.name),
        TextCellValue(wallet.type.name),
        DoubleCellValue(wallet.initialBalance),
        DoubleCellValue(currentBalance),
      ]);
    }

    // 3. SHEET: TRANSACTION
    final transactionSheet = excel['Transaction'];
    transactionSheet.appendRow([
      TextCellValue("Tanggal"),
      TextCellValue("Jenis"),
      TextCellValue("Kategori"),
      TextCellValue("Wallet Asal"),
      TextCellValue("Wallet Tujuan"),
      TextCellValue("Nominal"),
      TextCellValue("Catatan"),
    ]);

    for (final trx in report.transactions) {
      transactionSheet.appendRow([
        TextCellValue(_formatDate(trx.date)),
        TextCellValue(trx.type.name),
        TextCellValue(trx.category),
        TextCellValue(getWalletName(trx.sourceWalletId)),
        TextCellValue(getWalletName(trx.destinationWalletId)),
        DoubleCellValue(trx.amount),
        TextCellValue(trx.note ?? "-"),
      ]);
    }

    // 4. SHEET: SAVING TARGET
    final savingSheet = excel['Saving Target'];
    savingSheet.appendRow([
      TextCellValue("Nama Target"),
      TextCellValue("Jenis"),
      TextCellValue("Target"),
      TextCellValue("Terkumpul"),
      TextCellValue("Progress"),
      TextCellValue("Deadline"),
    ]);

    for (final target in report.savingTargets) {
      final current = FinancialService.getSavingCurrent(target);
      final percent = FinancialService.getSavingPercent(
        current: current,
        target: target.targetAmount,
      );

      savingSheet.appendRow([
        TextCellValue(target.title),
        TextCellValue(target.unit.name),
        DoubleCellValue(target.targetAmount),
        DoubleCellValue(current),
        TextCellValue("${(percent * 100).toStringAsFixed(1)}%"),
        TextCellValue(_formatDate(target.targetDate)),
      ]);
    }

    // 5. SHEET: PROFILE
    final profileSheet = excel['Profile'];
    profileSheet.appendRow([TextCellValue("Field"), TextCellValue("Value")]);
    profileSheet.appendRow([
      TextCellValue("Nama"),
      TextCellValue(AuthService.userName), // Diubah ke AuthService
    ]);
    profileSheet.appendRow([
      TextCellValue("Financial Goal"),
      TextCellValue(profile.financialGoal),
    ]);
    profileSheet.appendRow([
      TextCellValue("Mulai Menggunakan"),
      TextCellValue(_formatDate(profile.createdAt)),
    ]);

    // Pembersihan & Share Excel
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final bytes = excel.save();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/ARTA_Report.xlsx");
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: "ARTA Financial Report");
  }

  // ==========================================
  // EXPORT KE PDF
  // ==========================================
  static Future<void> exportPdf() async {
    final report = ReportService.generate();
    final profile = FinancialService.getProfile();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              "ARTA Financial Report",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.SizedBox(height: 20),

          pw.Text(
            "Summary",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            data: [
              ["Total Asset", report.asset.toStringAsFixed(0)],
              ["Income", report.income.toStringAsFixed(0)],
              ["Expense", report.expense.toStringAsFixed(0)],
              ["Cash Flow", report.balance.toStringAsFixed(0)],
            ],
          ),

          pw.SizedBox(height: 25),

          pw.Text(
            "Wallet",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: ["Nama", "Jenis", "Saldo Awal", "Saldo Saat Ini"],
            data: report.wallets.map((wallet) {
              return [
                wallet.name,
                wallet.type.name,
                wallet.initialBalance.toStringAsFixed(0),
                FinancialService.getWalletBalance(wallet.id).toStringAsFixed(0),
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 25),

          pw.Text(
            "Saving Target",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: ["Target", "Progress"],
            data: report.savingTargets.map((target) {
              final current = FinancialService.getSavingCurrent(target);

              return [
                target.title,
                "${current.toStringAsFixed(0)} / ${target.targetAmount.toStringAsFixed(0)}",
              ];
            }).toList(),
          ),

          pw.SizedBox(height: 25),

          pw.Text(
            "Profile",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            data: [
              ["Nama", AuthService.userName], // Diubah ke AuthService
              ["Financial Goal", profile.financialGoal],
              ["Mulai", _formatDate(profile.createdAt)],
            ],
          ),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "ARTA_Report.pdf",
    );
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Mendapatkan nama wallet berdasarkan ID
  static String getWalletName(String? walletId) {
    if (walletId == null) return "-";

    try {
      return FinancialService.getWallets()
          .firstWhere((wallet) => wallet.id == walletId)
          .name;
    } catch (_) {
      return "-";
    }
  }

  /// Format tanggal (DD/MM/YYYY)
  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return "$day/$month/${date.year}";
  }
}
