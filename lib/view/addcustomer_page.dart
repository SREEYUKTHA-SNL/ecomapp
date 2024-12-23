import 'package:ecomapp/customwidget/actionbutton.dart';
import 'package:ecomapp/view/View_customer.dart';
import 'package:ecomapp/view/addproduct_page.dart';
import 'package:ecomapp/customwidget/menuwidget.dart';
import 'package:ecomapp/view/home_page.dart';
import 'package:ecomapp/view/order_page.dart';
import 'package:ecomapp/view/viewproducts.dart';
import 'package:flutter/material.dart';
import 'package:ecomapp/model/customermodel.dart';
import 'package:ecomapp/service/customerservice.dart';


class AddCustomer extends StatefulWidget {
  final Customer? customer;

  const AddCustomer({Key? key, this.customer}) : super(key: key);

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.custname;
      _phoneController.text = widget.customer!.phone;
      _cityController.text = widget.customer!.city;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
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
              fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  Future<void> _saveCustomer() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty || phone.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      final customers = await _customerService.fetchCustomers();

      if (widget.customer == null) {
        final phoneExists =
            customers.any((customer) => customer.phone == phone);

        if (phoneExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number already exists')),
          );
          return;
        }

        final newCustomer = Customer(custname: name, phone: phone, city: city);
        final response = await _customerService.addCustomer(newCustomer);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer added successfully!')),
          );
          _clearFields();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to add customer: ${response.statusCode}')),
          );
        }
      } else {
        final phoneExists = customers.any((customer) =>
            customer.phone == phone &&
            customer.custid != widget.customer!.custid);

        if (phoneExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number already exists')),
          );
          return;
        }

        final response = await _customerService.updateCustomer(
          custId: widget.customer!.custid!,
          custName: name,
          phone: phone,
          city: city,
        );

        if (response['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer updated successfully!')),
          );
          Navigator.pop(context, true); // Close and refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update customer')),
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
    _phoneController.clear();
    _cityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = widget.customer != null;
    List<MenuOption> menuOptions = [
      MenuOption(icon: Icons.home, text: 'Home Page', page: const HomePage()),
      MenuOption(
          icon: Icons.add_box_rounded,
          text: 'Add Product',
          page: const ProductPage()),
      MenuOption(
          icon: Icons.remove_red_eye_sharp,
          text: 'View Customers',
          page: const ViewCustomer()),
      MenuOption(
          icon: Icons.remove_red_eye_outlined,
          text: 'View products',
          page: const ViewProducts()),
      MenuOption(
          icon: Icons.shopping_basket, text: 'Place Order', page: Orderpage()),
    ];

    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text(
          isUpdating ? 'Update Customer' : 'Add Customer',
          style: const TextStyle(color: Colors.white),
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
                  SizedBox(height: 20),
                  buildTextField(
                    icon: const Icon(Icons.person),
                    labelText: 'Customer Name',
                    controller: _nameController,
                  ),
                  SizedBox(height: 20),
                  buildTextField(
                    icon: const Icon(Icons.phone),
                    labelText: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 20),
                  buildTextField(
                    icon: const Icon(Icons.location_city),
                    labelText: 'City',
                    controller: _cityController,
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
         BottomActionButton(onPressed: _saveCustomer, isUpdating: isUpdating)
        ],
      ),
    );
  }
}
