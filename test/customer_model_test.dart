import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/customer.dart';

void main() {
  test('Customer.fromJson handles common shapes', () {
    final json1 = {'Id': 123, 'Name': 'Alice', 'Balance': '45.6', 'Image': 'images/a.png'};
    final c1 = Customer.fromJson(json1);
    expect(c1.id, 123);
    expect(c1.name, 'Alice');
    expect(c1.balance, 45.6);
    expect(c1.imagePath, 'images/a.png');

    final json2 = {'id': 5, 'name': 'Bob', 'balance': 10.0};
    final c2 = Customer.fromJson(json2);
    expect(c2.id, 5);
    expect(c2.name, 'Bob');
    expect(c2.balance, 10.0);

    final json3 = {'CustId': 7, 'CustName': 'Eve', 'Balance': 0};
    final c3 = Customer.fromJson(json3);
    expect(c3.id, 7);
    expect(c3.name, 'Eve');
  });
}
