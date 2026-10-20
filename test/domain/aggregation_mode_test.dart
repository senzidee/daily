import 'package:daylog/domain/aggregation_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AggregationMode', () {
    test('has the three expected values', () {
      expect(AggregationMode.values, [AggregationMode.last, AggregationMode.sum, AggregationMode.avg]);
      expect(AggregationMode.last.name, 'last');
      expect(AggregationMode.sum.name, 'sum');
      expect(AggregationMode.avg.name, 'avg');
    });
  });
}
