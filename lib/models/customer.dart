class Customer {
  final int id;
  final String name;
  final String? imagePath;
  final String? mobile;
  final double balance;

  Customer({required this.id, required this.name, this.imagePath, this.mobile, required this.balance});

  factory Customer.fromJson(Map<String, dynamic> json) {
    // Try common keys, be defensive about types
    int id = 0;
    if (json['Id'] is int) id = json['Id'];
    else if (json['id'] is int) id = json['id'];
    else if (json['CustId'] is int) id = json['CustId'];
    else if (json['Id'] is String) id = int.tryParse(json['Id']) ?? 0;

    String name = '';
    if (json['Name'] != null) name = json['Name'].toString();
    else if (json['name'] != null) name = json['name'].toString();
    else if (json['CustName'] != null) name = json['CustName'].toString();

    String? img;
    if (json['Image'] != null) img = json['Image'].toString();
    else if (json['image'] != null) img = json['image'].toString();
    else if (json['ImagePath'] != null) img = json['ImagePath'].toString();

    String? mobile;
    if (json['Mobile'] != null) mobile = json['Mobile'].toString();
    else if (json['Contact'] != null) mobile = json['Contact'].toString();
    double balance = 0.0;
    final balVal = json['Balance'] ?? json['balance'] ?? json['Due'] ?? json['Amount'];
    if (balVal is num) balance = balVal.toDouble();
    if (balVal is String) balance = double.tryParse(balVal) ?? 0.0;
    return Customer(id: id, name: name, imagePath: img, mobile: mobile, balance: balance);
  }
}
