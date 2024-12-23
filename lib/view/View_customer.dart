import 'package:ecomapp/customwidget/menuwidget.dart';
import 'package:ecomapp/model/customermodel.dart';
import 'package:ecomapp/service/customerservice.dart';
import 'package:ecomapp/view/addcustomer_page.dart';
import 'package:ecomapp/view/addproduct_page.dart';
import 'package:ecomapp/view/home_page.dart';
import 'package:ecomapp/view/order_page.dart';
import 'package:ecomapp/view/ordertetails.dart';
import 'package:ecomapp/view/viewproducts.dart';

import 'package:flutter/material.dart';

class ViewCustomer extends StatefulWidget {
  const ViewCustomer({super.key});

  @override
  State<ViewCustomer> createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer> {
  late Future<List<Customer>> _customersFuture;
  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    _customersFuture = _customerService.fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    List<MenuOption> menuOptions = [
      MenuOption(icon: Icons.home, text: 'Home Page', page: const HomePage()),
      MenuOption(
          icon: Icons.add_box_rounded,
          text: 'Add Product',
          page: const ProductPage()),
      MenuOption(
          icon: Icons.add, text: 'Add Customers', page: const AddCustomer()),
      MenuOption(
          icon: Icons.remove_red_eye,
          text: 'View products',
          page: const ViewProducts()),
      MenuOption(
          icon: Icons.shopping_basket, text: 'Place Order', page: Orderpage()),
    ];
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("View Customers"),
      ),
      drawer: CustomMenu(menuOptions: menuOptions),
      body: FutureBuilder<List<Customer>>(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No customers found."));
          }

          final customers = snapshot.data!;

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                elevation: 10,
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(customer.custname[0].toUpperCase()),
                  ),
                  title: Text(customer.custname,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      "City: ${customer.city}\nPhone: ${customer.phone}",
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
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
                                builder: (context) => AddCustomer(
                                  customer: customer,
                                ),
                              ));

                          if (shouldRefresh == true) {
                            setState(() {
                              _customersFuture =
                                  _customerService.fetchCustomers();
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          bool? confirmDelete = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Delete Customer"),
                              content: Text(
                                  "Are you sure you want to delete ${customer.custname}?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirmDelete == true) {
                            final result = await _customerService
                                .deleteCustomer(customer.custid!);

                            if (result['status']) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message'])),
                              );

                              setState(() {
                                _customersFuture =
                                    _customerService.fetchCustomers();
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result['message'])),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.shopping_cart, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(
                                customerId: customer.custid!,
                                customerName: customer.custname,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
