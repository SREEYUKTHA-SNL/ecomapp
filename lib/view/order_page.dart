import 'package:ecomapp/customwidget/menuwidget.dart';
import 'package:ecomapp/model/customermodel.dart';
import 'package:ecomapp/model/productmodel.dart';
import 'package:ecomapp/model/order_model.dart';
import 'package:ecomapp/service/customerservice.dart';
import 'package:ecomapp/service/productservice.dart';
import 'package:ecomapp/service/orderservice.dart';
import 'package:ecomapp/view/View_customer.dart';
import 'package:ecomapp/view/addcustomer_page.dart';
import 'package:ecomapp/view/addproduct_page.dart';
import 'package:ecomapp/view/home_page.dart';
import 'package:ecomapp/view/viewproducts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Orderpage extends StatefulWidget {
  @override
  _OrderpageState createState() => _OrderpageState();
}

class _OrderpageState extends State<Orderpage> {
  String? _selectedCustomerId;
  List<Customer> _customers = [];
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();
  CustomerService _customerService = CustomerService();
  List<Products> _products = [];
  bool _showProducts = false;
  TextEditingController _searchController = TextEditingController();
  List<Products> _filteredProducts = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    fetchProducts();
  }

  Future<void> fetchCustomers() async {
    List<Customer> customers = await _customerService.fetchCustomers();
    setState(() {
      _customers = customers;
    });
  }

  Future<void> fetchProducts() async {
    try {
      List<Products> products = await ProductService().fetchProducts();
      setState(() {
        _products = products.map((product) {
          product.quantity = product.stock > 0 ? product.quantity : 0;
          return product;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch products')),
      );
    }
  }

  double _calculateGrandTotal() {
    return _products
        .where((product) => product.selected)
        .fold(0, (sum, product) => sum + (product.mrp * product.quantity));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate.toString()) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _filterProducts(String query) {
    final filtered = _products.where((product) {
      final productName = product.productname.toLowerCase();
      final searchQuery = query.toLowerCase();
      return productName.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _scrollToCard() {
    final cardContext = _cardKey.currentContext;
    if (cardContext != null) {
      Scrollable.ensureVisible(
        cardContext,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MenuOption> menuOptions = [
      MenuOption(icon: Icons.home, text: 'Home Page', page: const HomePage()),
      MenuOption(
          icon: Icons.add_box_rounded, text: 'Add Product', page: const ProductPage()),
      MenuOption(
          icon: Icons.remove_red_eye, text: 'View Customers', page: const ViewCustomer()),
      MenuOption(
          icon: Icons.remove_red_eye_outlined, text: 'View products', page: const ViewProducts()),
      MenuOption(icon: Icons.add, text: 'Add Customer', page: AddCustomer()),
    ];
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('order', style: TextStyle(color: Colors.white)),
      ),
      drawer: CustomMenu(menuOptions: menuOptions),
      body: 
      SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            _customers.isEmpty
                ? const CircularProgressIndicator()
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6.0,
                          spreadRadius: 1.0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Customer',
                        labelStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      ),
                      value: _selectedCustomerId,
                      items: _customers.map((customer) {
                        return DropdownMenuItem<String>(
                          value: customer.custid.toString(),
                          child: Text(
                            customer.custname,
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomerId = value;
                        });
                      },
                      dropdownColor: Colors.white,
                    ),
                  ),
            const SizedBox(height: 16.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: 'Select Date',
                  border: InputBorder.none, // Remove TextField border
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.grey),
                    onPressed: () => _selectDate(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_selectedCustomerId == null ||
                    _dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Please select a customer and date first!')),
                  );
                } else {
                  setState(() {
                    _showProducts = true;
                  });
                }
              },
              child: const Text('Show Products',
                  style: TextStyle(color: Colors.black)),
            ),
            Divider(),
            if (_showProducts) ...[
              const SizedBox(height: 16.0),
              const Text(
                'All Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white, // White container
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6.0,
                      spreadRadius: 1.0,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Products',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (value) {
                    _filterProducts(value);
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              const Text(
                'Selected Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              _products.any((product) => product.selected)
                  ? Card(
                      key: _cardKey,
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Table Heading
                            Table(
                              border: TableBorder.all(
                                  color: Colors.black54, width: 1),
                              children: [
                                TableRow(
                                  decoration:
                                      BoxDecoration(color: Colors.grey[300]),
                                  children: const [
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Product Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Quantity',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Price',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(
                                          'Total',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Table Content
                            Table(
                              border: TableBorder.all(
                                  color: Colors.black54, width: 1),
                              children: _products
                                  .where((product) => product.selected)
                                  .map(
                                    (product) => TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              product.productname,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${product.quantity}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${product.mrp}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${(product.mrp * product.quantity).toStringAsFixed(2)}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 16.0),

                            Text(
                              'Grand Total: ${_calculateGrandTotal().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Text('No products selected'),
              const SizedBox(height: 16.0),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedCustomerId == null ||
                        _selectedDate == null ||
                        !_products.any((product) => product.selected)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please complete all required fields!'),
                        ),
                      );
                      return;
                    }

                    List<ProductOrder> productOrders = _products
                        .where((product) => product.selected)
                        .map((product) => ProductOrder(
                              productId: product.productid!,
                              quantity: product.quantity,
                              total: product.mrp * product.quantity,
                            ))
                        .toList();

                    Order order = Order(
                      customerId: int.parse(_selectedCustomerId!),
                      orderDate: _dateController.text,
                      totalAmount: _calculateGrandTotal(),
                      orderDetails: productOrders,
                    );

                    try {
                      final response = await OrderService().saveOrder(order);

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Order saved successfully!')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save order')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle:
                        const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 3 / 4.2,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredProducts.isEmpty
                    ? _products.length
                    : _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts.isEmpty
                      ? _products[index]
                      : _filteredProducts[index];
                  return GestureDetector(
                    onTap: () {
                      if (product.stock > 0) {
                        setState(() {
                          product.selected = !product.selected;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Product is out of stock!')),
                        );
                      }
                    },
                    child: Card(
                      color: product.stock > 0
                          ? (product.selected ? Colors.teal : Colors.white)
                          : Colors.grey[300],
                      elevation: 25,
                      margin: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              "https://plus.unsplash.com/premium_photo-1672883551967-ab11316526b4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8c2hvcHBpbmclMjBiYWd8ZW58MHx8MHx8fDA%3D",
                              height: 90, // Adjust image height
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              'Name: ${product.productname}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Price: ${product.mrp.toString()}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'stock: ${product.stock}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                                "Description:This product is 100 percentage natural"),
                            if (product.stock == 0)
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.black54),
                              width: 120,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove,
                                        color: Colors.white),
                                    onPressed: product.stock > 0 &&
                                            product.quantity > 1
                                        ? () {
                                            setState(() {
                                              product.quantity--;
                                            });
                                          }
                                        : null,
                                  ),
                                  Text(
                                    '${product.quantity}',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (product.quantity < product.stock) {
                                          product.quantity++;
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Quantity cannot exceed stock!')),
                                          );
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: _scrollToCard,
        child: const Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
    );
  }
}
