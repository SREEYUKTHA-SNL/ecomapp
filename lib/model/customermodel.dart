class Customer {
  int? custid;
  String custname;
  String phone;
  String city;

  Customer({
    this.custid,
    required this.custname,
    required this.phone,
    required this.city,
  });


  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      custid: json['custid'], 
      custname: json['custname'],
      phone: json['phone'],
      city: json['city'],
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'custid': custid, 
      'custname': custname,
      'phone': phone,
      'city': city,
    };
  }
}
