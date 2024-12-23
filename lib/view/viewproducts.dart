import 'package:ecomapp/customwidget/menuwidget.dart';
import 'package:ecomapp/model/productmodel.dart';
import 'package:ecomapp/service/productservice.dart';
import 'package:ecomapp/view/View_customer.dart';
import 'package:ecomapp/view/addcustomer_page.dart';
import 'package:ecomapp/view/addproduct_page.dart';
import 'package:ecomapp/view/home_page.dart';
import 'package:ecomapp/view/order_page.dart';
import 'package:flutter/material.dart';

class ViewProducts extends StatefulWidget {
  const ViewProducts({Key? key}) : super(key: key);

  @override
  State<ViewProducts> createState() => _ViewProductsState();
}

class _ViewProductsState extends State<ViewProducts> {
  final ProductService _productService = ProductService();
  late Future<List<Products>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    List<MenuOption> menuOptions = [
      MenuOption(icon: Icons.add, text: 'Home Page', page: const HomePage()),
      MenuOption(
          icon: Icons.add, text: 'Add Product', page: const ProductPage()),
      MenuOption(
          icon: Icons.add, text: 'View Customers', page: const ViewCustomer()),
      MenuOption(
          icon: Icons.add, text: 'Add Customers', page: const AddCustomer()),
      MenuOption(icon: Icons.add, text: 'Place Order', page: Orderpage()),
    ];
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: CustomMenu(menuOptions: menuOptions),
      body: FutureBuilder<List<Products>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products available'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: SizedBox(
                  height: 120, 
                  child: Padding(
                    padding: const EdgeInsets.all(
                        8.0),
                    child: ListTile(
                      title: Text(
                        product.productname,
                        style: const TextStyle(
                            fontSize:
                                18),
                      ),
                      subtitle: Text(
                        'Price: ${product.mrp},\nStock: ${product.stock}',
                        style: const TextStyle(
                            fontSize:
                                16), 
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final shouldRefresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductPage(products: product),
                                ),
                              );

                              if (shouldRefresh == true) {
                                setState(() {
                                  _productsFuture =
                                      _productService.fetchProducts();
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              bool? confirmDelete = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Product"),
                                  content: Text(
                                      "Are you sure you want to delete ${product.productname}?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmDelete == true) {
                                final result = await _productService
                                    .deleteProduct(product.productid!);

                                if (result['status']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'])),
                                  );

                                  setState(() {
                                    _productsFuture =
                                        _productService.fetchProducts();
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'])),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
