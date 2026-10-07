import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  runApp(const EcoWalkApp());
}

class EcoWalkApp extends StatelessWidget {
  const EcoWalkApp({super.key});

  static const hijau = Color(0xFF176B5A);
  static const biruLink = Color(0xFF20A8D8);
  static const abu = Color(0xFF858585);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ECOWALK',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: hijau),
        ),
        // Bar status untuk tampil di SEMUA halaman
        builder: (context, child) => Stack(
          fit: StackFit.expand,
          children: [
            child!,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'lib/images/barphone.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
        home: const SplashScreen(),
      );
}

// =====================================================
// KOMPONEN YANG DIPAKAI BERSAMA (Login & Daftar)
// =====================================================

void snack(BuildContext context, String pesan, {Color? warna}) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: warna),
    );


Widget logoHijau() => Center(
      child: SizedBox(
        width: 238,
        height: 60,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(<double>[
            0, 0, 0, 0, 23, // R hijau
            0, 0, 0, 0, 107, // G hijau
            0, 0, 0, 0, 90, // B hijau
            0, 0, 0, 4, -380, // alpha: buang piksel samar
          ]),
          child: Image.asset(
            'lib/images/logoecowalk.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );

Widget judulHalaman(String teks) => Text(
      teks,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: EcoWalkApp.hijau,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );

Widget tombolHijau(String teks, VoidCallback onPressed) => SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: EcoWalkApp.hijau,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          teks,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );

// Teks biasa dan teks link biru, dipakai di bagian bawah halaman
Widget barisLink(String teks, String link, VoidCallback onTap) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          teks,
          style: const TextStyle(color: Color(0xFF777777), fontSize: 12),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            link,
            style: const TextStyle(
              color: EcoWalkApp.biruLink,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

// Kerangka halaman: isi diberi jarak atas & bawah yang proporsional
Widget kerangkaHalaman({
  required List<Widget> children,
  int flexAtas = 3,
  int flexBawah = 2,
}) =>
    Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Spacer(flex: flexAtas),
                      ...children,
                      Spacer(flex: flexBawah),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );


Widget headerMiring({String? judul, String? judulGambar}) => LayoutBuilder(
      builder: (context, c) {
        final h = c.maxWidth * 0.66;
        final teksJudul = Text(
          judul ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: EcoWalkApp.hijau,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        );
        return SizedBox(
          height: h,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipPath(
                  clipper: _DiagonalClipper(),
                  child: const ColoredBox(color: Color(0xFFD9E5E2)),
                ),
              ),
              // pusat logo di 67% tinggi header
              Positioned(
                top: h * 0.67 - 30,
                left: 0,
                right: 0,
                child: logoHijau(),
              ),
              // pusat judul di 82% tinggi header
              if (judul != null)
                Positioned(
                  top: h * 0.82 - 12,
                  left: 0,
                  right: 0,
                  child: judulGambar == null
                      ? teksJudul
                      : Center(
                          child: SizedBox(
                            width: 208,
                            height: 24,
                            child: Image.asset(
                              judulGambar,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => teksJudul,
                            ),
                          ),
                        ),
                ),
            ],
          ),
        );
      },
    );

// true  = judul "LUPA KATA SANDI" 
// false = judul memakai teks biasa 
const bool pakaiGambarLupaSandi = true;

Widget headerLupaSandi() => headerMiring(
      judul: 'LUPA KATA SANDI',
      judulGambar: pakaiGambarLupaSandi ? 'lib/images/lupasandi.png' : null,
    );

// Tinggi area bar status ~ 18,8% lebar layar 
double tinggiBarPhone(BuildContext context) =>
    MediaQuery.of(context).size.width * 0.188;

// Kolom input 
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? icon;
  final bool garis; // true = gaya garis bawah
  final String? label;
  final String? hint;
  final bool obscure;
  final VoidCallback? onToggle; // jika diisi akan muncul ikon mata
  final TextInputType? keyboardType;
  final TextInputAction action;
  final ValueChanged<String>? onSubmitted;
  final double height;

  const AuthField({
    super.key,
    required this.controller,
    this.icon,
    this.garis = false,
    this.label,
    this.hint,
    this.obscure = false,
    this.onToggle,
    this.keyboardType,
    this.action = TextInputAction.next,
    this.onSubmitted,
    this.height = 55,
  });

  OutlineInputBorder _border(Color warna, [double lebar = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: warna, width: lebar),
      );

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 7),
          ],
          SizedBox(
            height: height,
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: keyboardType,
              textInputAction: action,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: EcoWalkApp.abu,
                ),
                prefixIcon: icon == null
                    ? null
                    : Icon(icon, size: garis ? 18 : 21, color: EcoWalkApp.abu),
                suffixIcon: onToggle == null
                    ? null
                    : IconButton(
                        onPressed: onToggle,
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          size: 20,
                          color: EcoWalkApp.abu,
                        ),
                      ),
                filled: !garis,
                fillColor: const Color(0xFFFAFAFA),
                contentPadding: garis
                    ? const EdgeInsets.symmetric(vertical: 14)
                    : const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                enabledBorder: garis
                    ? const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF666666)))
                    : _border(const Color(0xFFCCCCCC)),
                focusedBorder: garis
                    ? const UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: EcoWalkApp.hijau, width: 1.5))
                    : _border(EcoWalkApp.hijau, 1.2),
              ),
            ),
          ),
        ],
      );
}

// =====================================================
// SPLASH SCREEN
// =====================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 8), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: EcoWalkApp.hijau,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/images/logoecowalk.png',
                  width: 240,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 10),
                const Text(
                  '“Bandingkan, pilih, liburan tanpa ragu !”',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

// =====================================================
// LOGIN PAGE
// =====================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool sandiTersembunyi = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void prosesLogin() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      snack(context, 'Nama pengguna dan kata sandi harus diisi.');
      return;
    }
    snack(context, 'Login berhasil. Selamat datang, $username!',
        warna: EcoWalkApp.hijau);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilPage(nama: username.toUpperCase()),
      ),
    );
  }

  Widget garis() => Expanded(child: Divider(color: Colors.grey.shade300));

  @override
  Widget build(BuildContext context) => kerangkaHalaman(
        flexAtas: 3,
        flexBawah: 2,
        children: [
          judulHalaman('MASUK'),
          const SizedBox(height: 8),
          logoHijau(),
          const SizedBox(height: 56),

          AuthField(
            label: 'Nama Pengguna',
            controller: usernameController,
            icon: Icons.person,
          ),
          const SizedBox(height: 18),

          AuthField(
            label: 'Kata Sandi',
            controller: passwordController,
            icon: Icons.lock,
            obscure: sandiTersembunyi,
            onToggle: () =>
                setState(() => sandiTersembunyi = !sandiTersembunyi),
            action: TextInputAction.done,
            onSubmitted: (_) => prosesLogin(),
          ),
          const SizedBox(height: 30),

          tombolHijau('MASUK', prosesLogin),
          const SizedBox(height: 12),

          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LupaSandiPage()),
              ),
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  color: EcoWalkApp.biruLink,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              garis(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Atau',
                  style: TextStyle(color: Color(0xFF666666), fontSize: 11),
                ),
              ),
              garis(),
            ],
          ),
          const SizedBox(height: 27),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () =>
                  snack(context, 'Login Google belum dihubungkan.'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7F7F7),
                foregroundColor: Colors.black,
                elevation: 4,
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/google.png', width: 24, height: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Lanjutkan dengan Google',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 44),

          barisLink(
            'Tidak punya akun? ',
            'Daftar disini',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterPage()),
            ),
          ),
        ],
      );
}

// =====================================================
// REGISTER PAGE (BUAT AKUN)
// =====================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final hpController = TextEditingController();
  final sandiController = TextEditingController();
  final konfirmasiController = TextEditingController();

  bool sandiTersembunyi = true;
  bool konfirmasiTersembunyi = true;
  bool setuju = false;

  @override
  void dispose() {
    for (final c in [
      usernameController,
      emailController,
      hpController,
      sandiController,
      konfirmasiController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void prosesDaftar() {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final hp = hpController.text.trim();
    final sandi = sandiController.text;
    final konfirmasi = konfirmasiController.text;

    String? error;
    if ([username, email, hp, sandi, konfirmasi].any((e) => e.isEmpty)) {
      error = 'Semua data harus diisi.';
    } else if (!email.contains('@') || !email.contains('.')) {
      error = 'Format email tidak valid.';
    } else if (sandi.length < 6) {
      error = 'Kata sandi minimal 6 karakter.';
    } else if (sandi != konfirmasi) {
      error = 'Konfirmasi kata sandi tidak sama.';
    } else if (!setuju) {
      error = 'Kamu harus menyetujui persyaratan dan privasi pengguna.';
    }

    if (error != null) {
      snack(context, error);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifikasiPage(email: email, hp: hp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const jarak = SizedBox(height: 14);

    return kerangkaHalaman(
      flexAtas: 5,
      flexBawah: 4,
      children: [
        judulHalaman('BUAT AKUN'),
        const SizedBox(height: 8),
        logoHijau(),
        const SizedBox(height: 40),

        AuthField(
          hint: 'Nama Pengguna',
          controller: usernameController,
          icon: Icons.person,
          height: 50,
        ),
        jarak,
        AuthField(
          hint: 'Email',
          controller: emailController,
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          height: 50,
        ),
        jarak,
        AuthField(
          hint: 'Nomor Hp',
          controller: hpController,
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          height: 50,
        ),
        jarak,
        AuthField(
          hint: 'Kata Sandi',
          controller: sandiController,
          icon: Icons.lock,
          obscure: sandiTersembunyi,
          onToggle: () => setState(() => sandiTersembunyi = !sandiTersembunyi),
          height: 50,
        ),
        jarak,
        AuthField(
          hint: 'Konfirmasi Kata Sandi',
          controller: konfirmasiController,
          icon: Icons.lock,
          obscure: konfirmasiTersembunyi,
          onToggle: () =>
              setState(() => konfirmasiTersembunyi = !konfirmasiTersembunyi),
          action: TextInputAction.done,
          onSubmitted: (_) => prosesDaftar(),
          height: 50,
        ),
        const SizedBox(height: 18),

        // Checkbox persyaratan
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: setuju,
                onChanged: (v) => setState(() => setuju = v ?? false),
                activeColor: EcoWalkApp.hijau,
                side: const BorderSide(color: EcoWalkApp.abu, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                  children: [
                    TextSpan(text: 'Saya telah membaca dan menyetujui '),
                    TextSpan(
                      text: 'persyaratan dan privasi pengguna',
                      style: TextStyle(color: EcoWalkApp.biruLink),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        tombolHijau('BUAT AKUN', prosesDaftar),
        const SizedBox(height: 18),

        barisLink('Sudah punya akun? ', 'Masuk', () => Navigator.pop(context)),
      ],
    );
  }
}

// =====================================================
// VERIFIKASI PAGE
// =====================================================

// Potongan header miring (sisi kiri lebih tinggi dari sisi kanan)
class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..lineTo(s.width, 0)
    ..lineTo(s.width, s.height)
    ..lineTo(0, s.height * 0.44)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class VerifikasiPage extends StatefulWidget {
  final String email;
  final String hp;
  final bool lupaSandi; // true = alur Lupa Kata Sandi

  const VerifikasiPage({
    super.key,
    required this.email,
    required this.hp,
    this.lupaSandi = false,
  });

  @override
  State<VerifikasiPage> createState() => _VerifikasiPageState();
}

class _VerifikasiPageState extends State<VerifikasiPage> {
  final kontrol = List.generate(4, (_) => TextEditingController());
  final fokus = List.generate(4, (_) => FocusNode());
  // true = kode dikirim ke No. Hp, false = ke Email
  late bool lewatHp = widget.hp.isNotEmpty;

  @override
  void dispose() {
    for (final c in kontrol) {
      c.dispose();
    }
    for (final f in fokus) {
      f.dispose();
    }
    super.dispose();
  }

  // 0812... -> +62812...
  String get nomorHp {
    final d = widget.hp.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('0')) return '+62${d.substring(1)}';
    if (d.startsWith('62')) return '+$d';
    return '+62$d';
  }

  String get tujuan => lewatHp ? nomorHp : widget.email;

  void gantiMetode() {
    setState(() => lewatHp = !lewatHp);
    for (final c in kontrol) {
      c.clear();
    }
  }

  void kirim() {
    final kode = kontrol.map((c) => c.text).join();
    if (kode.length < 4) {
      snack(context, 'Masukkan 4 digit kode verifikasi.');
      return;
    }
    if (widget.lupaSandi) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SandiBaruPage()),
      );
      return;
    }
    snack(context, 'Verifikasi berhasil. Silakan masuk.',
        warna: EcoWalkApp.hijau);
    Navigator.popUntil(context, (route) => route.isFirst); // kembali ke login
  }

  Widget kotakKode(int i) => Expanded(
        child: SizedBox(
          height: 78,
          child: TextField(
            controller: kontrol[i],
            focusNode: fokus[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            onChanged: (v) {
              if (v.isNotEmpty && i < 3) fokus[i + 1].requestFocus();
              if (v.isEmpty && i > 0) fokus[i - 1].requestFocus();
            },
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF8F8F8),
              contentPadding: const EdgeInsets.symmetric(vertical: 26),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: EcoWalkApp.hijau, width: 1.2),
              ),
            ),
          ),
        ),
      );

  // Ikon ponsel dengan gelembung chat kecil
  Widget get ikonPonsel => SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          children: [
            const Icon(Icons.smartphone_outlined,
                size: 34, color: Colors.black87),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.chat_bubble, size: 9, color: Colors.white),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // Header miring + logo
              headerMiring(),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check, size: 22, color: Colors.black87),
                        SizedBox(width: 10),
                        Text(
                          'VERIFIKASI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ikonPonsel,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Colors.black87,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'Periksa dan ketik kode verifikasi yang telah dikirimkan ke ',
                                ),
                                TextSpan(
                                  text: tujuan,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 42),

                    // 4 kotak kode
                    Row(
                      children: [
                        for (int i = 0; i < 4; i++) ...[
                          if (i > 0) const SizedBox(width: 14),
                          kotakKode(i),
                        ],
                      ],
                    ),
                    const SizedBox(height: 33),

                    // Link ganti metode hanya muncul kalau No. Hp & Email sama-sama ada
                    if (widget.hp.isNotEmpty && widget.email.isNotEmpty)
                      GestureDetector(
                      onTap: gantiMetode,
                      child: Text(
                        lewatHp
                            ? 'Verifikasi menggunakan Email'
                            : 'Verifikasi menggunakan No. Hp',
                        style: const TextStyle(
                          color: EcoWalkApp.biruLink,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      child: tombolHijau('KIRIM', kirim),
                    ),
                    const SizedBox(height: 4),

                    Center(
                      child: TextButton(
                        onPressed: () => snack(
                            context, 'Kode verifikasi dikirim ulang ke $tujuan.'),
                        child: const Text(
                          'Kirim Ulang Kode',
                          style: TextStyle(
                            color: EcoWalkApp.hijau,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// =====================================================
// LUPA KATA SANDI (via Email / via No. Hp)
// =====================================================

class LupaSandiPage extends StatefulWidget {
  const LupaSandiPage({super.key});

  @override
  State<LupaSandiPage> createState() => _LupaSandiPageState();
}

class _LupaSandiPageState extends State<LupaSandiPage> {
  final kontrol = TextEditingController();
  bool lewatEmail = true;

  @override
  void dispose() {
    kontrol.dispose();
    super.dispose();
  }

  void gantiMetode() {
    setState(() => lewatEmail = !lewatEmail);
    kontrol.clear();
  }

  void kirim() {
    final v = kontrol.text.trim();
    String? error;

    if (v.isEmpty) {
      error = lewatEmail ? 'Alamat email harus diisi.' : 'Nomor HP harus diisi.';
    } else if (lewatEmail && (!v.contains('@') || !v.contains('.'))) {
      error = 'Format email tidak valid.';
    } else if (!lewatEmail && v.replaceAll(RegExp(r'\D'), '').length < 9) {
      error = 'Nomor HP tidak valid.';
    }

    if (error != null) {
      snack(context, error);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifikasiPage(
          email: lewatEmail ? v : '',
          hp: lewatEmail ? '' : v,
          lupaSandi: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              headerLupaSandi(),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 27, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_none,
                            size: 26, color: Colors.black),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lewatEmail
                                ? 'Periksa dan masukan alamat Email untuk mendapatkan kode verifikasi'
                                : 'Periksa dan masukan Nomor Hp untuk mendapatkan kode verifikasi',
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 56),

                    AuthField(
                      garis: true,
                      label: lewatEmail ? 'Alamat Email' : 'Nomor Hp',
                      controller: kontrol,
                      keyboardType: lewatEmail
                          ? TextInputType.emailAddress
                          : TextInputType.phone,
                      action: TextInputAction.done,
                      onSubmitted: (_) => kirim(),
                      height: 48,
                    ),
                    const SizedBox(height: 38),

                    GestureDetector(
                      onTap: gantiMetode,
                      child: Text(
                        lewatEmail ? 'Gunakan Nomor Hp' : 'Gunakan Email',
                        style: const TextStyle(
                          color: EcoWalkApp.biruLink,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 39),

                    SizedBox(
                      width: double.infinity,
                      child: tombolHijau('KIRIM', kirim),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// =====================================================
// KATA SANDI BARU
// =====================================================

class SandiBaruPage extends StatefulWidget {
  const SandiBaruPage({super.key});

  @override
  State<SandiBaruPage> createState() => _SandiBaruPageState();
}

class _SandiBaruPageState extends State<SandiBaruPage> {
  final sandiController = TextEditingController();
  final konfirmasiController = TextEditingController();
  bool sandiTersembunyi = true;
  bool konfirmasiTersembunyi = true;

  @override
  void dispose() {
    sandiController.dispose();
    konfirmasiController.dispose();
    super.dispose();
  }

  void ubahSandi() {
    final sandi = sandiController.text;
    final konfirmasi = konfirmasiController.text;

    String? error;
    if (sandi.isEmpty || konfirmasi.isEmpty) {
      error = 'Semua data harus diisi.';
    } else if (sandi.length < 6) {
      error = 'Kata sandi minimal 6 karakter.';
    } else if (sandi != konfirmasi) {
      error = 'Konfirmasi kata sandi tidak sama.';
    }

    if (error != null) {
      snack(context, error);
      return;
    }

    snack(context, 'Kata sandi berhasil diubah. Silakan masuk.',
        warna: EcoWalkApp.hijau);
    // Kembali ke halaman login 
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              headerLupaSandi(),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 45, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Masukan Kata Sandi Baru',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 28),

                    AuthField(
                      garis: true,
                      hint: 'Kata Sandi Baru',
                      controller: sandiController,
                      icon: Icons.lock,
                      obscure: sandiTersembunyi,
                      onToggle: () =>
                          setState(() => sandiTersembunyi = !sandiTersembunyi),
                      height: 52,
                    ),
                    const SizedBox(height: 23),

                    AuthField(
                      garis: true,
                      hint: 'Konfirmasi Kata Sandi',
                      controller: konfirmasiController,
                      icon: Icons.lock,
                      obscure: konfirmasiTersembunyi,
                      onToggle: () => setState(
                          () => konfirmasiTersembunyi = !konfirmasiTersembunyi),
                      action: TextInputAction.done,
                      onSubmitted: (_) => ubahSandi(),
                      height: 52,
                    ),
                    const SizedBox(height: 59),

                    SizedBox(
                      width: double.infinity,
                      child: tombolHijau('UBAH KATA SANDI', ubahSandi),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// =====================================================
// FOTO PROFIL 
// =====================================================

class FotoProfil extends StatelessWidget {
  final double ukuran;
  const FotoProfil({super.key, required this.ukuran});

  @override
  Widget build(BuildContext context) => ClipOval(
        child: SizedBox(
          width: ukuran,
          height: ukuran,
          child: Image.asset(
            'lib/images/fotoprofil.jpeg',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFFD9D9D9),
              child: Icon(Icons.person, size: ukuran * 0.6, color: EcoWalkApp.abu),
            ),
          ),
        ),
      );
}

// =====================================================
// PROFIL (menu AKUN)
// =====================================================

class ProfilPage extends StatefulWidget {
  final String nama;
  final String email;

  const ProfilPage({
    super.key,
    this.nama = 'Suci Lestari',
    this.email = 'lestarisuci0506@gmail.com',
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  late String nama = widget.nama;

  void belumAda(String halaman) =>
      snack(context, 'Halaman $halaman belum dibuat.');

  Future<void> editProfil() async {
    final hasil = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilPage()),
    );
    if (hasil != null && mounted) {
      setState(() => nama = hasil.toUpperCase());
    }
  }

  void keluar() {
    snack(context, 'Kamu telah keluar.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget menuItem(IconData ikon, String teks, VoidCallback onTap,
          {bool garis = true}) =>
      InkWell(
        onTap: onTap,
        child: Container(
          height: 59,
          decoration: BoxDecoration(
            border: garis
                ? const Border(
                    bottom: BorderSide(color: Color(0xFFD6D6D6)),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(ikon, size: 24, color: Colors.black),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  teks,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            ],
          ),
        ),
      );

  Widget navIkon(Widget ikon, String halaman) => Expanded(
        child: InkWell(
          onTap: () => belumAda(halaman),
          child: Center(child: ikon),
        ),
      );

  // Bar bawah hijau dan tombol AKUN bulat 
  Widget navBawah() => SizedBox(
        height: 62,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: ColoredBox(color: EcoWalkApp.hijau)),
            Row(
              children: [
                navIkon(
                  const Icon(Icons.home_outlined, size: 31, color: Colors.white),
                  'Beranda',
                ),
                navIkon(
                  const Icon(Icons.verified_user, size: 28, color: Colors.white),
                  'Verifikasi',
                ),
                navIkon(
                  const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.chat_bubble, size: 30, color: Colors.white),
                      Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Icon(Icons.favorite,
                            size: 13, color: EcoWalkApp.hijau),
                      ),
                    ],
                  ),
                  'Favorit',
                ),
                // AKUN (aktif)
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      Positioned(
                        top: -37,
                        child: Container(
                          width: 75,
                          height: 75,
                          decoration: const BoxDecoration(
                            color: EcoWalkApp.hijau,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              size: 38, color: Colors.white),
                        ),
                      ),
                      const Positioned(
                        bottom: 7,
                        child: Text(
                          'AKUN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: navBawah(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header hijau + foto profil (setengah menonjol ke bawah)
              SizedBox(
                height: 232,
                width: double.infinity,
                child: Stack(
                  children: [
                    Container(height: 169, color: EcoWalkApp.hijau),
                    Positioned(
                      top: 98,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 133,
                          height: 133,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const FotoProfil(ukuran: 123),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),

              Text(
                nama,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                height: 26,
                width: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: EcoWalkApp.hijau,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.email,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              const SizedBox(height: 26),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17),
                child: Column(
                  children: [
                    menuItem(Icons.settings_outlined, 'Pengaturan',
                        () => belumAda('Pengaturan')),
                    menuItem(Icons.edit_outlined, 'Edit Profil', editProfil),
                    menuItem(Icons.lock, 'Kebijakan Privasi',
                        () => belumAda('Kebijakan Privasi')),
                    menuItem(Icons.info_outline, 'Tentang Kami',
                        () => belumAda('Tentang Kami')),
                    menuItem(Icons.fact_check_outlined, 'Ketentuan Layanan',
                        () => belumAda('Ketentuan Layanan')),
                    menuItem(Icons.logout, 'Keluar', keluar, garis: false),
                  ],
                ),
              ),
              const SizedBox(height: 50), // ruang agar tidak tertutup tombol AKUN
            ],
          ),
        ),
      );
}

// =====================================================
// EDIT PROFIL
// =====================================================

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final namaController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    super.dispose();
  }

  void simpan() {
    final nama = namaController.text.trim();
    if (nama.isEmpty) {
      snack(context, 'Nama pengguna tidak boleh kosong.');
      return;
    }
    snack(context, 'Profil berhasil diperbarui.', warna: EcoWalkApp.hijau);
    Navigator.pop(context, nama); // nama baru dikirim balik ke halaman Profil
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // ruang untuk bar status (barphone.png)
              SizedBox(height: tinggiBarPhone(context)),

              // App bar hijau
              Container(
                height: 55,
                width: double.infinity,
                color: EcoWalkApp.hijau,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          size: 24, color: Colors.white),
                    ),
                    const SizedBox(width: 18),
                    const Text(
                      'Edit Profil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 33),

              // Foto + tombol pensil
              SizedBox(
                width: 126,
                height: 126,
                child: Stack(
                  children: [
                    const FotoProfil(ukuran: 126),
                    Positioned(
                      right: 4,
                      bottom: 3,
                      child: GestureDetector(
                        onTap: () =>
                            snack(context, 'Fitur ganti foto belum tersedia.'),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: EcoWalkApp.hijau,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AuthField(
                  garis: true,
                  hint: 'Nama Pengguna',
                  icon: Icons.person,
                  controller: namaController,
                  action: TextInputAction.done,
                  onSubmitted: (_) => simpan(),
                  height: 52,
                ),
              ),
              const SizedBox(height: 94),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: tombolHijau('SIMPAN', simpan),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
}