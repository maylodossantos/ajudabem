import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CepAddress {
  const CepAddress({
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  final String street;
  final String neighborhood;
  final String city;
  final String state;
}

abstract interface class CepService {
  Future<CepAddress?> lookup(String cep);
}

class HttpCepService implements CepService {
  HttpCepService(this._client);

  static const _timeout = Duration(seconds: 4);

  final http.Client _client;
  final _cache = <String, CepAddress>{};

  @override
  Future<CepAddress?> lookup(String cep) async {
    final digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return null;

    final cached = _cache[digits];
    if (cached != null) return cached;

    final address = await _viaCep(digits) ?? await _brasilApi(digits);
    if (address != null) _cache[digits] = address;
    return address;
  }

  Future<CepAddress?> _viaCep(String digits) async {
    final json = await _get('https://viacep.com.br/ws/$digits/json/');
    if (json == null || json['erro'] != null) return null;
    return CepAddress(
      street: _text(json['logradouro']),
      neighborhood: _text(json['bairro']),
      city: _text(json['localidade']),
      state: _text(json['uf']),
    );
  }

  Future<CepAddress?> _brasilApi(String digits) async {
    final json = await _get('https://brasilapi.com.br/api/cep/v1/$digits');
    if (json == null || json['city'] == null) return null;
    return CepAddress(
      street: _text(json['street']),
      neighborhood: _text(json['neighborhood']),
      city: _text(json['city']),
      state: _text(json['state']),
    );
  }

  Future<Map<String, dynamic>?> _get(String url) async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return json is Map<String, dynamic> ? json : null;
    } catch (_) {
      return null;
    }
  }

  static String _text(Object? value) => value is String ? value.trim() : '';
}
