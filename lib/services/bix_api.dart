import 'dart:convert';
import 'package:crypto/crypto.dart' show sha256;
import 'package:http/http.dart' as http;

/// Response from any BIX System API call.
class BixResponse {
  final String requestedService;
  final String status; // 'Success', 'Info', or 'Error'
  final List<String> data;
  final String messageLine1;
  final String messageLine2;

  const BixResponse({
    required this.requestedService,
    required this.status,
    required this.data,
    required this.messageLine1,
    required this.messageLine2,
  });

  bool get isSuccess => status == 'Success';
  bool get isInfo => status == 'Info';
  bool get isError => status == 'Error';

  /// For login: data[0] = "userId,Person|Business", data[1] = authKey
  String? get userId {
    if (data.isNotEmpty && data[0].contains(',')) {
      return data[0].split(',').first;
    }
    return data.isNotEmpty ? data[0] : null;
  }

  String? get userType {
    if (data.isNotEmpty && data[0].contains(',')) {
      return data[0].split(',').last;
    }
    return null;
  }

  String? get authorizationKey => data.length > 1 ? data[1] : null;
  String? get userEmail => data.length > 3 ? data[3] : null;

  String get displayMessage {
    final parts = <String>[];
    if (messageLine1.isNotEmpty) parts.add(messageLine1.trim());
    if (messageLine2.isNotEmpty) parts.add(messageLine2.trim());
    return parts.join('\n');
  }

  factory BixResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List<String> dataList;
    if (rawData is List) {
      dataList = rawData.map((e) => e?.toString() ?? '').toList();
    } else {
      dataList = [];
    }

    return BixResponse(
      requestedService: json['requestedService']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Error',
      data: dataList,
      messageLine1: json['messageLine1']?.toString() ?? '',
      messageLine2: json['messageLine2']?.toString() ?? '',
    );
  }
}

/// BIX System API client.
class BixApi {
  static const String _baseUrl = 'https://bixwallet.com';

  /// SHA-256 hash of the PIN for secure transmission.
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register a new user.
  ///
  /// Per API spec: POST to /registerUser with query parameters.
  /// PIN is sent as SHA-256 hash for security.
  static Future<BixResponse> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String pin,
    String mobileNo = '',
  }) async {
    final hashedPin = hashPin(pin);
    final senderName = '$firstName $lastName';

    final uri = Uri.parse('$_baseUrl/registerUser').replace(
      queryParameters: {
        'senderName': senderName,
        'senderEmail': email,
        'senderPIN': hashedPin,
        'senderMobileNo': mobileNo.isNotEmpty ? mobileNo : '-',
      },
    );

    return _postRequest(uri);
  }

  /// Login an existing user.
  ///
  /// Per API spec: POST to /loginUser with query parameters.
  /// PIN is sent as SHA-256 hash.
  static Future<BixResponse> loginUser({
    required String email,
    required String pin,
    bool forgotPin = false,
  }) async {
    final hashedPin = hashPin(pin);

    final uri = Uri.parse('$_baseUrl/loginUser').replace(
      queryParameters: {
        'senderName': '-',
        'senderEmail': email,
        'senderPIN': hashedPin,
        'privateKey': '-',
        'forgotPIN': forgotPin ? 'true' : '',
        'sender': 'browser',
      },
    );

    return _postRequest(uri);
  }

  /// Logout the current session.
  static Future<BixResponse> logout({
    required String authorizationKey,
    required String email,
  }) async {
    final uri = Uri.parse('$_baseUrl/logout').replace(
      queryParameters: {
        'authorizationKey': authorizationKey,
        'senderEmail': email,
        'sender': 'browser',
      },
    );

    return _postRequest(uri);
  }

  /// Internal: execute POST request and parse JSON response.
  static Future<BixResponse> _postRequest(Uri uri) async {
    try {
      final response = await http.post(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return BixResponse.fromJson(json);
      } else {
        return BixResponse(
          requestedService: '',
          status: 'Error',
          data: const ['', '', '', ''],
          messageLine1: 'Server error (${response.statusCode})',
          messageLine2: 'Please try again later.',
        );
      }
    } catch (e) {
      return BixResponse(
        requestedService: '',
        status: 'Error',
        data: const ['', '', '', ''],
        messageLine1: 'Connection error',
        messageLine2: 'Please check your internet connection and try again.',
      );
    }
  }
}
