import 'package:example/src/data/table_data.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
      const MegaColumn(title: 'Empresa', field: 'company', canHide: false),
      const MegaColumn(title: 'Tomador', field: 'borrower'),
      const MegaColumn(title: 'Parcela', field: 'installment'),
      const MegaColumn(title: 'Vencimento', field: 'deadline'),
      const MegaColumn(title: 'Valor', field: 'value', canHide: false),
    ];

    return MegaGrid(
      items: TableData().generateCompanyData(500),
      columns: columns,
      height: 400,
      width: 400,
      initialRowLimit: 10,
      increaseRowLimit: 10,
      isInfinityLoading: true,
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

  Widget _buildSecondTable() {
    final columns = [
      const MegaColumn(title: 'Empresa', field: 'company', canHide: false),
      const MegaColumn(title: 'Tomador', field: 'borrower'),
      const MegaColumn(title: 'Parcela', field: 'installment'),
      const MegaColumn(title: 'Vencimento', field: 'deadline'),
      const MegaColumn(title: 'Valor', field: 'value', canHide: false),
    ];

    return MegaGrid(
      items: TableData().generateCompanyData(20),
      columns: columns,
    );
  }

  Widget _buildThirdTable() {
    final columns = [
      const MegaColumn(title: 'Empresa', field: 'empresa', canHide: false),
      const MegaColumn(title: 'Tomador', field: 'tomador'),
      const MegaColumn(title: 'Parcela', field: 'nrParcela'),
      const MegaColumn(title: 'Vencimento', field: 'dtVencimento'),
      const MegaColumn(title: 'Valor', field: 'vlPrestacao', canHide: false),
    ];

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _items.isEmpty
            ? Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: MegaGrid(
                      items: _items,
                      columns: columns,
                      initialRowLimit: 1,
                      increaseRowLimit: 1,
                      isInfinityLoading: true,
                    ),
                  ),
                  const Text('No data found'),
                ],
              )
            : MegaGrid(
                items: _items,
                columns: columns,
                initialRowLimit: 1,
                increaseRowLimit: 1,
                isInfinityLoading: true,
              );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Grid Example'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Tabela 1'),
              Tab(text: 'Tabela 2'),
              Tab(text: 'Tabela 3'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFirstTable(),
            _buildSecondTable(),
            _buildThirdTable(),
          ],
        ),
      ),
    );
  }
}
