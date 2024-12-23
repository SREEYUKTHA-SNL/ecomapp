import 'package:ecomapp/model/order_model.dart';
import 'package:flutter/material.dart';

import 'package:ecomapp/service/orderservice.dart';

class OrderDetailsPage extends StatefulWidget {
  final int customerId;
  final String customerName;

  const OrderDetailsPage({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Future<List<Order>> _ordersFuture;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  Future<List<Order>> _fetchOrders() async {
    try {
      final ordersData =
          await _orderService.getOrdersByCustomer(widget.customerId);

      return ordersData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to load orders: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: Text("Orders for ${widget.customerName}",
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
        
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
           
            return const Center(child: Text("No orders found."));
          }

          final orders = snapshot.data!;

          orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(
                      16.0), 
                  child: SizedBox(
                    height: 80.0,
                    child: ListTile(
                      title: Text(
                        "Order Date: ${order.orderDate}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Net Amount: ${order.totalAmount}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        _showOrderDetails(context, order);
                      },
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

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Order Details",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...order.orderDetails.map((product) {
                return ListTile(
                  title: Text(
                    "productid: ${product.productId}",
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "Quantity: ${product.quantity}\nTotalamount:${product.total},",
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  isThreeLine: true,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
