import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/order_model.dart';

class OrderService {
  final String baseUrl = "http://localhost:5292/api/Order";

  OrderService();

  // Method to save an order
  Future<dynamic> saveOrder(Order order) async {
    try {
      List<Map<String, dynamic>> orderDetailsMapped =
          order.orderDetails.map((detail) {
        return {
          "order_productid": detail.productId,
          "quantity": detail.quantity,
          "totalamount": detail.total
        };
      }).toList();

      Map<String, dynamic> mappedData = {
        "customerid": order.customerId,
        "orderdate": order.orderDate.toString(),
        "Netamount": order.totalAmount,
        "OrderDetails": orderDetailsMapped
      };

      var url = Uri.parse("$baseUrl/addorder");
      var client = http.Client();
      http.Response response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(mappedData),
      );
      return response;
    } catch (e) {
      throw Exception("Error adding order: $e");
    }
  }

  Future<List<Order>> fetchOrders() async {
    try {
      var url = Uri.parse("$baseUrl/getorders");
      var client = http.Client();
      http.Response response = await client.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body) as List;
        List<Order> orders = decodedResponse.map((orderData) {
          List<ProductOrder> productOrders = (orderData['OrderDetails'] as List)
              .map((productData) => ProductOrder(
                    productId: productData['order_productid'],
                    quantity: productData['quantity'],
                    total: productData['totalamount'],
                  ))
              .toList();

          return Order(
            customerId: orderData['CustomerId'],
            orderDate: orderData['OrderDate'],
            totalAmount: orderData['NetAmount'],
            orderDetails: productOrders,
          );
        }).toList();

        return orders;
      } else {
        throw Exception(
            "Failed to fetch orders. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching orders: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getOrdersByCustomer(int customerId) async {
    final url = Uri.parse('$baseUrl/getorders/$customerId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('kkkkk');
        print(data);

        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 404) {
        throw Exception("No orders found for the given customer ID.");
      } else {
        throw Exception("Failed to load orders: ${response.reasonPhrase}");
      }
    } catch (e) {
      throw Exception("An error occurred: $e");
    }
  }
}
