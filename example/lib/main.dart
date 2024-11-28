import 'package:flutter/material.dart';
import 'package:mega_grid/mega_grid.dart';
import 'http_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final HttpService _httpService = HttpService();
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _httpService.fetchParcelasAVencer();
      final transformedData = data.map((item) {
        final celula = item['dataTableCelula'];
        return {
          'empresa': celula['emprestimoTOsolicitacaoCreditoCartaoTOcartaoTOcontratoFilialEmpresaTOcontratoEmpresaTOempresaTO.txNomeReduzido'],
          'tomador': celula['emprestimoTOtomadorTOpessoaTO.txNome'],
          'nrParcela': celula['nrParcela'],
          'dtVencimento': celula['dtVencimento'],
          'vlPrestacao': celula['vlPrestacao'],
        };
      }).toList();

      setState(() {
        _items = transformedData.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildFirstTable() {
    final columns = [
      const MegaColumn(title: 'Empresa', field: 'empresa', canHide: false),
      const MegaColumn(title: 'Tomador', field: 'tomador'),
      const MegaColumn(title: 'Parcela', field: 'nrParcela'),
      const MegaColumn(title: 'Vencimento', field: 'dtVencimento'),
      const MegaColumn(title: 'Valor', field: 'vlPrestacao', canHide: false),
    ];

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : MegaGrid(
            items: _items,
            columns: columns,
            initialRowLimit: 1,
            increaseRowLimit: 1,
          );
  }

  Widget _buildSecondTable() {
    final columns = [
      const MegaColumn(title: 'Empresa', field: 'company', canHide: false),
      const MegaColumn(title: 'Tomador', field: 'borrower'),
      const MegaColumn(title: 'Parcela', field: 'installment'),
      const MegaColumn(title: 'Vencimento', field: 'deadline'),
      const MegaColumn(title: 'Valor', field: 'value', canHide: false),
    ];

    final List<TableItem> items = [
      {'company': 'Empresa 1', 'borrower': 'Pessoa 1', 'installment': 7, 'deadline': '15/09/2026', 'value': 1700.0},
      {'company': 'Empresa 2', 'borrower': 'Pessoa 2', 'installment': 3, 'deadline': '30/02/2026', 'value': 5000.0},
      {'company': 'Empresa 3', 'borrower': 'Pessoa 3', 'installment': 2, 'deadline': '01/01/2025', 'value': 3400.0},
      {'company': 'Empresa 4', 'borrower': 'Pessoa 4', 'installment': 5, 'deadline': '01/04/2026', 'value': 7100.0},
      {'company': 'Empresa 5', 'borrower': 'Pessoa 5', 'installment': 6, 'deadline': '07/05/2026', 'value': 1800.0},
      {'company': 'Empresa 6', 'borrower': 'Pessoa 6', 'installment': 7, 'deadline': '15/09/2026', 'value': 1600.0},
      {'company': 'Empresa 7', 'borrower': 'Pessoa 7', 'installment': 3, 'deadline': '30/02/2026', 'value': 4900.0},
      {'company': 'Empresa 8', 'borrower': 'Pessoa 8', 'installment': 2, 'deadline': '01/01/2025', 'value': 3300.0},
      {'company': 'Empresa 9', 'borrower': 'Pessoa 9', 'installment': 5, 'deadline': '01/04/2026', 'value': 7000.0},
      {'company': 'Empresa 10', 'borrower': 'Pessoa 10', 'installment': 6, 'deadline': '07/05/2026', 'value': 2000.0},
      {'company': 'Empresa 11', 'borrower': 'Pessoa 11', 'installment': 7, 'deadline': '15/09/2026', 'value': 1900.0},
      {'company': 'Empresa 12', 'borrower': 'Pessoa 12', 'installment': 3, 'deadline': '30/02/2026', 'value': 5200.0},
      {'company': 'Empresa 13', 'borrower': 'Pessoa 13', 'installment': 2, 'deadline': '01/01/2025', 'value': 3600.0},
      {'company': 'Empresa 14', 'borrower': 'Pessoa 14', 'installment': 5, 'deadline': '01/04/2026', 'value': 7300.0},
      {'company': 'Empresa 15', 'borrower': 'Pessoa 15', 'installment': 6, 'deadline': '07/05/2026', 'value': 2100.0},
      {'company': 'Empresa 16', 'borrower': 'Pessoa 16', 'installment': 7, 'deadline': '15/09/2026', 'value': 2000.0},
      {'company': 'Empresa 17', 'borrower': 'Pessoa 17', 'installment': 3, 'deadline': '30/02/2026', 'value': 5300.0},
      {'company': 'Empresa 18', 'borrower': 'Pessoa 18', 'installment': 2, 'deadline': '01/01/2025', 'value': 3700.0},
      {'company': 'Empresa 19', 'borrower': 'Pessoa 19', 'installment': 5, 'deadline': '01/04/2026', 'value': 7400.0},
      {'company': 'Empresa 20', 'borrower': 'Pessoa 20', 'installment': 6, 'deadline': '07/05/2026', 'value': 2200.0},
    ];

    return MegaGrid(
      items: items,
      columns: columns,
      feedback: (t) => customFeedback(t),
      customIncreaseRow: (VoidCallback onTap) {
        return customLoadButton(() {
          onTap();
        });
      },
      initialRowLimit: 5,
      increaseRowLimit: 2,
      style: MegaGridStyle(
        headerTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        cellTextStyle: const TextStyle(color: Colors.black),
        headerBackgroundColor: Colors.white,
        rowBackgroundColor: const Color(0xFFFAFAFA),
        rowTextStyle: const TextStyle(color: Colors.black),
        rowAlternateBackgroundColor: Colors.white,
        borderColor: Colors.transparent,
        borderWidth: 1.0,
        borderRadius: BorderRadius.circular(54),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Grid Example'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Tabela 1'),
              Tab(text: 'Tabela 2'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFirstTable(),
            _buildSecondTable(),
          ],
        ),
      ),
    );
  }
}

Widget Function(String) customFeedback = (String? value) {
  return Material(
    elevation: 4,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 114, 200, 219).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(value ?? ""),
        const Icon(Icons.query_stats),
      ]),
    ),
  );
};

Widget customLoadButton(VoidCallback onTap) {
  return Material(
    elevation: 4,
    borderRadius: BorderRadius.circular(12),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 114, 200, 219).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Carregar mais itens",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    ),
  );
}
