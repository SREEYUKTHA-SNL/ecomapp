class Products {
  int? productid;
  String productname;
  dynamic mrp;
  bool selected;
  int quantity;
  dynamic stock;
  Products({
    this.productid,
    required this.productname,
    required this.mrp,
    required this.stock,
    this.selected = false,
    this.quantity = 1,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      productid: json['productid'],
      productname: json['productname'],
      mrp: json['mrp'],
       stock: json['stock'],
      selected: json['selected'] ?? false,
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productid': productid,
      'productname': productname,
      'mrp': mrp,
       'stock': stock,
      'selected': selected,
      'quantity': quantity,
    };
  }
}
