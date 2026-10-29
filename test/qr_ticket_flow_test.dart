import 'package:flutter_test/flutter_test.dart';
import 'package:parkride/services/supabase_service.dart';

void main() {
  group('QR ticket flow', () {
    test('bloquea un código demo después de validarlo y marcarlo como usado', () async {
      final service = SupabaseService();

      final first = await service.validateTicketCode('URB-001');
      expect(first.isValid, isTrue);

      await service.markTicketAsUsed('URB-001');

      final second = await service.validateTicketCode('URB-001');
      expect(second.isValid, isFalse);
      expect(second.alreadyUsed, isTrue);
    });
  });
}
