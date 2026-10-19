import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idds_flutter/idds_flutter.dart';

/// Beranda galeri: contoh dasbor seperti bagian "Pilih Tema" di situs IDDS.
/// Ganti tema untuk melihat seluruh komponen ikut berubah warna.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.brand, required this.onBrandChanged});

  final IddsBrand brand;
  final ValueChanged<IddsBrand> onBrandChanged;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<IddsBrand> _themes = <IddsBrand>[IddsBrand.inagov, IddsBrand.panrb, IddsBrand.lan, IddsBrand.bkn];

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    final String email = _email.text.trim();
    setState(() => _emailError = email.isEmpty
        ? 'Email wajib diisi'
        : !email.contains('@')
            ? 'Format email tidak sesuai'
            : null);
    if (_emailError != null) return;
    showIddsToast(
      context: context,
      title: const Text('Berhasil masuk'),
      description: const Text('Ini hanya contoh; tidak ada data yang dikirim.'),
      state: IddsToastState.positive,
    );
  }

  void _openSurvey() {
    Map<String, String> answers = <String, String>{};
    showIddsModal<void>(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModal) => IddsModal(
          size: IddsModalSize.lg,
          title: const Text('Survei Kepuasan Layanan'),
          actions: <Widget>[
            IddsButton(
              hierarchy: IddsButtonHierarchy.secondary,
              onPressed: () => Navigator.pop(context),
              child: const Text('Nanti saja'),
            ),
            IddsButton(
              onPressed: answers.length < 2
                  ? null
                  : () {
                      Navigator.pop(context);
                      showIddsToast(context: this.context, title: const Text('Terima kasih atas tanggapan Anda'));
                    },
              child: const Text('Kirim'),
            ),
          ],
          child: IddsChoiceGrid(
            columns: const <IddsChoiceGridItem>[
              IddsChoiceGridItem(id: '1', label: 'Kurang'),
              IddsChoiceGridItem(id: '2', label: 'Cukup'),
              IddsChoiceGridItem(id: '3', label: 'Baik'),
            ],
            rows: const <IddsChoiceGridItem>[
              IddsChoiceGridItem(id: 'kecepatan', label: 'Kecepatan layanan'),
              IddsChoiceGridItem(id: 'kemudahan', label: 'Kemudahan aplikasi'),
            ],
            selected: answers,
            onChanged: (Map<String, String> v) => setModal(() => answers = v),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final IddsColors c = theme.colors;
    final bool known = _themes.any((IddsBrand b) => b.id == widget.brand.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(IddsSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Lihat bagaimana setiap instansi menampilkan identitasnya',
            style: theme.textStyle(
              fontSize: IddsFontSize.xl2,
              lineHeight: IddsLineHeight.xl,
              fontWeight: IddsFontWeight.semibold,
              color: c.contentPrimary,
            ),
          ),
          const SizedBox(height: IddsSpacing.s8),
          Text(
            'Pilih tema penerapan untuk melihat perbedaannya. Brand lain dan brand kustom ada di menu Brand & Warna.',
            style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentSecondary),
          ),
          const SizedBox(height: IddsSpacing.s24),
          Wrap(
            spacing: IddsSpacing.s16,
            runSpacing: IddsSpacing.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                'Pilih Tema',
                style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentPrimary),
              ),
              IddsTabMenu<String>(
                variant: IddsTabVariant.buttonWhite,
                value: known ? widget.brand.id : null,
                onChanged: (String id) => widget.onBrandChanged(_themes.firstWhere((IddsBrand b) => b.id == id)),
                items: <IddsTabItem<String>>[
                  for (final IddsBrand b in _themes) IddsTabItem<String>(value: b.id, label: Text(b.name)),
                ],
              ),
            ],
          ),
          const SizedBox(height: IddsSpacing.s24),
          Container(
            padding: const EdgeInsets.all(IddsSpacing.s24),
            decoration: BoxDecoration(
              color: c.backgroundPrimary,
              borderRadius: BorderRadius.circular(IddsRadius.xl),
              border: Border.all(color: c.strokePrimary, width: 3),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 760;
                Widget pair(Widget a, int flexA, Widget b, int flexB) => wide
                    ? _EqualHeightRow(
                        flexes: <int>[flexA, flexB],
                        spacing: IddsSpacing.s24,
                        children: <Widget>[a, b],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: IddsSpacing.s24,
                        children: <Widget>[a, b],
                      );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: IddsSpacing.s24,
                  children: <Widget>[
                    pair(_loginCard(theme), 2, _pieCard(theme), 3),
                    pair(_barCard(theme), 3, _surveyCard(theme), 2),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _title(IddsThemeData theme) => theme.textStyle(
        fontSize: IddsFontSize.lg,
        lineHeight: IddsLineHeight.lg,
        fontWeight: IddsFontWeight.semibold,
        color: theme.colors.contentPrimary,
      );

  Widget _loginCard(IddsThemeData theme) {
    return IddsCardPlain(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: IddsSpacing.s16,
          children: <Widget>[
            _BrandLogo(brand: widget.brand),
            IddsTextField(
              controller: _email,
              label: const Text('Email'),
              placeholder: 'Masukkan email Anda',
              keyboardType: TextInputType.emailAddress,
              status: _emailError == null ? IddsTextFieldStatus.neutral : IddsTextFieldStatus.error,
              statusMessage: _emailError,
              onChanged: (_) {
                if (_emailError != null) setState(() => _emailError = null);
              },
            ),
            IddsPasswordField(
              controller: _password,
              label: const Text('Kata Sandi'),
              placeholder: 'Masukkan kata sandi Anda',
              onSubmitted: (_) => _login(),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IddsButton(
                hierarchy: IddsButtonHierarchy.link,
                size: IddsButtonSize.sm,
                onPressed: () => showIddsToast(context: context, title: const Text('Tautan atur ulang kata sandi telah dikirim')),
                child: const Text('Lupa Kata Sandi?'),
              ),
            ),
            SizedBox(width: double.infinity, child: IddsButton(onPressed: _login, child: const Text('Masuk'))),
          ],
        ),
      ),
    );
  }

  /// Warna grafik dari skala brand, seperti di situs IDDS.
  List<Color> _brandShades(IddsColors c) => <Color>[
        c.primary.shade600,
        c.primary.shade300,
        c.primary.shade900,
        c.primary.shade500,
        c.primary.shade800,
        c.primary.shade200,
      ];

  Widget _pieCard(IddsThemeData theme) {
    final List<Color> shades = _brandShades(theme.colors);
    const List<(String, double)> data = <(String, double)>[
      ('Admin Operasional', 10),
      ('Pengelola Produk', 20),
      ('Auditor', 5),
      ('Delivery / Implementasi', 10),
      ('Client Eksternal', 25),
      ('Pengguna Umum', 30),
    ];
    return IddsCardPlain(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: IddsSpacing.s24,
        children: <Widget>[
          Text('Distribusi Pengguna', style: _title(theme)),
          IddsPieChart(
            size: 180,
            valueFormat: (double v) => '${v.toStringAsFixed(0)}%',
            slices: <IddsChartSlice>[
              for (int i = 0; i < data.length; i++) IddsChartSlice(label: data[i].$1, value: data[i].$2, color: shades[i]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barCard(IddsThemeData theme) {
    final IddsColors c = theme.colors;
    return IddsCardPlain(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: IddsSpacing.s16,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: IddsSpacing.s4,
                  children: <Widget>[
                    Text(
                      'Total Transaksi',
                      style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentSecondary),
                    ),
                    Text(
                      '9.778.392',
                      style: theme.textStyle(
                        fontSize: IddsFontSize.xl3,
                        lineHeight: 38,
                        fontWeight: IddsFontWeight.semibold,
                        color: c.contentPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const IddsBadge(variant: IddsBadgeVariant.success, child: Text('+20.294 minggu ini')),
            ],
          ),
          IddsBarChart(
            height: 260,
            labels: const <String>['Minggu 1', 'Minggu 2', 'Minggu 3', 'Minggu 4', 'Minggu 5', 'Minggu 6'],
            valueFormat: (double v) => '${v.toStringAsFixed(0)} rb',
            series: <IddsChartSeries>[
              IddsChartSeries(name: 'Transaksi baru', values: const <double?>[12, 18, 25, 20, 30, 45], color: c.primary.shade600),
              IddsChartSeries(name: 'Transaksi selesai', values: const <double?>[10, 14, 22, 28, 26, 38], color: c.primary.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _surveyCard(IddsThemeData theme) {
    final IddsColors c = theme.colors;
    return IddsCardPlain(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(IddsRadius.lg - 1)),
            child: AspectRatio(
              aspectRatio: 310 / 187,
              child: SvgPicture.asset(
                'assets/illustrations/survey.svg',
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                colorMapper: _IllustrationMapper(c.primary),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(IddsSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: IddsSpacing.s8,
              children: <Widget>[
                Text('Survei Singkat dan Kuis Tersedia', style: _title(theme)),
                Text(
                  'Respon Anda sangat berharga bagi kami.',
                  style: theme.textStyle(fontSize: IddsFontSize.sm, lineHeight: IddsLineHeight.sm, color: c.contentSecondary),
                ),
                const SizedBox(height: IddsSpacing.s16),
                IddsButton(onPressed: _openSurvey, child: const Text('Lihat Survei dan Kuis')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo brand di kartu login. Brand tanpa berkas logo (Neutral, INApas,
/// INAku, BGN, brand kustom) ditampilkan sebagai teks nama brand.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.brand});

  final IddsBrand brand;

  static const Map<String, String> _assets = <String, String>{
    'inagov': 'assets/logos/inagov.svg',
    'panrb': 'assets/logos/panrb.svg',
    'lan': 'assets/logos/lan.svg',
    'bkn': 'assets/logos/bkn.svg',
  };

  @override
  Widget build(BuildContext context) {
    final IddsThemeData theme = IddsTheme.of(context);
    final String? asset = _assets[brand.id];
    if (asset == null) {
      return Text(
        brand.name,
        style: theme.textStyle(
          fontSize: IddsFontSize.xl2,
          lineHeight: IddsLineHeight.xl,
          fontWeight: IddsFontWeight.bold,
          color: theme.colors.primaryMain,
        ),
      );
    }
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: SvgPicture.asset(
        asset,
        height: 32,
        semanticsLabel: 'Logo ${brand.name}',
        // Teks logo PANRB hampir hitam (#231F20) dan tidak terbaca di mode
        // gelap, jadi diganti warna teks utama.
        colorMapper: theme.isDark ? _DarkTextMapper(theme.colors.contentPrimary) : null,
      ),
    );
  }
}

/// Mengganti warna hampir hitam pada logo dengan [color].
class _DarkTextMapper extends ColorMapper {
  const _DarkTextMapper(this.color);

  final Color color;

  @override
  Color substitute(String? id, String elementName, String attributeName, Color original) {
    final bool nearBlack = original.r < 0.2 && original.g < 0.2 && original.b < 0.2;
    return nearBlack ? color.withValues(alpha: original.a) : original;
  }

  @override
  bool operator ==(Object other) => other is _DarkTextMapper && other.color == color;

  @override
  int get hashCode => color.hashCode;
}

/// Mewarnai ulang ilustrasi survei mengikuti brand yang dipilih.
///
/// Ilustrasi asli digambar dengan skala primary LAN; tiap warna biru
/// diganti tingkat yang sama dari skala primary brand aktif (warna biru yang
/// tidak persis ada di skala LAN memakai tingkat terdekat). Warna kulit,
/// rambut, tanaman, dan abu-abu tidak diubah.
class _IllustrationMapper extends ColorMapper {
  const _IllustrationMapper(this.primary);

  final IddsColorScale primary;

  @override
  Color substitute(String? id, String elementName, String attributeName, Color original) {
    final Color? mapped = switch (original.toARGB32() & 0xFFFFFF) {
      0xF3F6FC => primary.shade25,
      0xD9E9F9 => primary.shade50,
      0x94BDE5 || 0x8DC1FF => primary.shade200,
      0x5B9BD5 => primary.shade300,
      0x3781C7 || 0x2978D6 => primary.shade400,
      0x1F4F85 => primary.shade600,
      0x083575 => primary.shade700,
      _ => null,
    };
    return mapped?.withValues(alpha: original.a) ?? original;
  }

  @override
  bool operator ==(Object other) => other is _IllustrationMapper && other.primary == primary;

  @override
  int get hashCode => primary.hashCode;
}

/// Baris berisi kartu yang tingginya disamakan dengan kartu tertinggi.
///
/// Tidak memakai `IntrinsicHeight` karena grafik memakai `LayoutBuilder`
/// (tidak mendukung ukuran intrinsik). Anak diukur dulu dengan tinggi bebas,
/// lalu diukur ulang dengan tinggi kartu tertinggi.
class _EqualHeightRow extends MultiChildRenderObjectWidget {
  const _EqualHeightRow({required this.flexes, required this.spacing, required super.children})
      : assert(flexes.length == children.length);

  /// Perbandingan lebar tiap anak, seperti `Expanded.flex`.
  final List<int> flexes;

  /// Jarak antaranak.
  final double spacing;

  @override
  _RenderEqualHeightRow createRenderObject(BuildContext context) =>
      _RenderEqualHeightRow(flexes: flexes, spacing: spacing);

  @override
  void updateRenderObject(BuildContext context, _RenderEqualHeightRow renderObject) {
    renderObject
      ..flexes = flexes
      ..spacing = spacing;
  }
}

class _EqualHeightParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderEqualHeightRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _EqualHeightParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _EqualHeightParentData> {
  _RenderEqualHeightRow({required List<int> flexes, required double spacing})
      : _flexes = flexes,
        _spacing = spacing;

  List<int> _flexes;
  set flexes(List<int> value) {
    if (listEquals(_flexes, value)) return;
    _flexes = value;
    markNeedsLayout();
  }

  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _EqualHeightParentData) child.parentData = _EqualHeightParentData();
  }

  @override
  void performLayout() {
    final double width = constraints.maxWidth;
    final int totalFlex = _flexes.fold(0, (int sum, int f) => sum + f);
    final double available = width - _spacing * (childCount - 1);
    final List<double> widths = <double>[for (final int f in _flexes) available * f / totalFlex];

    // Ukur dengan tinggi bebas untuk mencari kartu tertinggi.
    double height = 0;
    RenderBox? child = firstChild;
    int i = 0;
    while (child != null) {
      child.layout(BoxConstraints.tightFor(width: widths[i]), parentUsesSize: true);
      if (child.size.height > height) height = child.size.height;
      child = childAfter(child);
      i++;
    }
    height = constraints.constrainHeight(height);

    // Ukur ulang semua anak dengan tinggi yang sama.
    double x = 0;
    child = firstChild;
    i = 0;
    while (child != null) {
      child.layout(BoxConstraints.tightFor(width: widths[i], height: height));
      (child.parentData! as _EqualHeightParentData).offset = Offset(x, 0);
      x += widths[i] + _spacing;
      child = childAfter(child);
      i++;
    }
    size = constraints.constrain(Size(width, height));
  }

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
