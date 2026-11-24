import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

const _apiHost = 'api.legiapos.vn';
const _dohProviders = <_DohProvider>[
  _DohProvider(
    host: 'cloudflare-dns.com',
    bootstrapIps: ['1.1.1.1', '1.0.0.1'],
    path: '/dns-query',
  ),
  _DohProvider(
    host: 'dns.google',
    bootstrapIps: ['8.8.8.8', '8.8.4.4'],
    path: '/resolve',
  ),
];

class _DohProvider {
  const _DohProvider({
    required this.host,
    required this.bootstrapIps,
    required this.path,
  });

  final String host;
  final List<String> bootstrapIps;
  final String path;
}

class _DnsRecord {
  const _DnsRecord(this.address, this.expiresAt);

  final InternetAddress address;
  final DateTime expiresAt;
}

class _ApiHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = HttpClient(context: context);
    client.connectionTimeout = const Duration(seconds: 15);
    client.connectionFactory = (uri, proxyHost, proxyPort) async {
      final host = proxyHost ?? uri.host;
      final port = proxyPort ?? uri.port;
      final task = await Socket.startConnect(host, port);
      try {
        await task.socket.timeout(const Duration(seconds: 10));
        return task;
      } catch (error) {
        task.cancel();
        if (proxyHost != null || uri.host != _apiHost || !_isDnsError(error)) {
          rethrow;
        }
        final addresses = await _resolveApiHost();
        Object? lastError;
        for (final address in addresses) {
          final fallbackTask = await Socket.startConnect(address, uri.port);
          try {
            await fallbackTask.socket.timeout(const Duration(seconds: 10));
            return fallbackTask;
          } catch (fallbackError) {
            fallbackTask.cancel();
            lastError = fallbackError;
          }
        }
        throw SocketException(
          'Could not connect to $_apiHost using the DNS fallback: $lastError',
        );
      }
    };
    return client;
  }
}

bool _isDnsError(Object error) =>
    error is SocketException &&
    (error.osError?.errorCode == 7 ||
        error.message.toLowerCase().contains('lookup') ||
        error.message.toLowerCase().contains('resolve'));

Future<List<InternetAddress>> _resolveApiHost() async {
  final now = DateTime.now();
  final cached = _cachedAddresses
      .where((record) => record.expiresAt.isAfter(now))
      .map((record) => record.address)
      .toList();
  if (cached.isNotEmpty) return cached;

  Object? lastError;
  for (final provider in _dohProviders) {
    for (final bootstrapIp in provider.bootstrapIps) {
      final resolver = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);
      resolver.connectionFactory = (uri, proxyHost, proxyPort) {
        if (proxyHost != null) {
          return Socket.startConnect(proxyHost, proxyPort ?? uri.port);
        }
        return Socket.startConnect(
          InternetAddress(bootstrapIp),
          uri.port,
        );
      };
      try {
        final query = Uri.https(provider.host, provider.path, {
          'name': _apiHost,
          'type': 'A',
        });
        final request = await resolver.getUrl(query);
        if (provider.host == 'cloudflare-dns.com') {
          request.headers.set(HttpHeaders.acceptHeader, 'application/dns-json');
        }
        final response =
            await request.close().timeout(const Duration(seconds: 8));
        final body = await utf8.decoder.bind(response).join();
        if (response.statusCode != HttpStatus.ok) {
          throw HttpException('DNS resolver returned ${response.statusCode}');
        }
        final decoded = jsonDecode(body);
        final answers = decoded is Map ? decoded['Answer'] : null;
        if (answers is List) {
          final records = <_DnsRecord>[];
          for (final answer in answers.whereType<Map>()) {
            final data = answer['data']?.toString();
            final type = answer['type']?.toString();
            if (type == '1' && data != null) {
              try {
                final ttl = int.tryParse(answer['TTL']?.toString() ?? '') ?? 60;
                records.add(_DnsRecord(
                  InternetAddress(data),
                  now.add(Duration(seconds: ttl.clamp(30, 3600).toInt())),
                ));
              } on FormatException {
                // Ignore malformed DNS answer records.
              }
            }
          }
          if (records.isNotEmpty) {
            _cachedAddresses = records;
            return records.map((record) => record.address).toList();
          }
        }
        throw const SocketException('DNS returned no IPv4 address');
      } catch (error) {
        lastError = error;
      } finally {
        resolver.close(force: true);
      }
    }
  }
  throw SocketException('Secure DNS lookup failed: $lastError');
}

List<_DnsRecord> _cachedAddresses = const [];

http.Client createApiHttpClient() =>
    IOClient(_ApiHttpOverrides().createHttpClient(null));
