import 'package:ecomapp/model/productmodel.dart';
import 'package:ecomapp/service/productservice.dart';
import 'package:ecomapp/view/View_customer.dart';
import 'package:ecomapp/view/addcustomer_page.dart';
import 'package:ecomapp/customwidget/menuwidget.dart';
import 'package:ecomapp/view/home_page.dart';
import 'package:ecomapp/view/order_page.dart';
import 'package:ecomapp/view/viewproducts.dart';
import 'package:flutter/material.dart';


class ProductPage extends StatefulWidget {
  final Products? products;
  const ProductPage({super.key, this.products});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _mrpController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final ProductService _productService = ProductService();

  @override
  void dispose() {
    _nameController.dispose();
    _mrpController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required String labelText,
    required Icon icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          icon: icon,
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Future<void> _saveproducts() async {
    final name = _nameController.text.trim();
    final mrp = _mrpController.text.trim();
    final stock = _stockController.text.trim();

    if (name.isEmpty || mrp.isEmpty || stock.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      if (widget.products == null) {
        final newProduct = Products(productname: name, mrp: mrp, stock: stock);
        final response = await _productService.addProduct(newProduct);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully!')),
          );
          _clearFields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to add product: ${response.statusCode}')),
          );
        }
      } else {
        final response = await _productService.updateProduct(
          productid: widget.products!.productid!,
          mrp: double.parse(mrp),
          stock: int.parse(stock),
          productname: name,
        );
        print(response);

        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully!')),
          );
          Navigator.pop(context, true); // Close and refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update product')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void _clearFields() {
    _nameController.clear();
    _mrpController.clear();
    _stockController.clear();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.products != null) {
      _nameController.text = widget.products!.productname;
      _mrpController.text = widget.products!.mrp.toString();
      _stockController.text = widget.products!.stock.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MenuOption> menuOptions = [
      MenuOption(icon: Icons.home,text: 'Home Page', page: const HomePage()),
      MenuOption(icon: Icons.person_add_alt,text: 'Add customer', page: const AddCustomer()),
      MenuOption(icon: Icons.remove_red_eye_sharp,text: 'View Customers', page: const ViewCustomer()),
      MenuOption(icon: Icons.remove_red_eye_outlined,text: 'View products', page: const ViewProducts()),
      MenuOption(icon: Icons.shopping_basket,text: 'Place Order', page: Orderpage()),
    ];
    final isUpdating = widget.products != null;
    return Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text(
            'Add Product',
            style: TextStyle(color: Colors.white),
          ),
        ),
        drawer: CustomMenu(menuOptions: menuOptions),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    buildTextField(
                      icon: const Icon(Icons.shopping_bag),
                      labelText: 'Product Name',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      icon: const Icon(Icons.monetization_on),
                      labelText: 'Price',
                      controller: _mrpController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      icon: const Icon(Icons.inventory),
                      labelText: 'Stock',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _saveproducts,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isUpdating ? 'Update' : 'Save',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
