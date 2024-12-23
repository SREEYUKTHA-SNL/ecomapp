import 'dart:convert';
import 'package:ecomapp/model/customermodel.dart';
import 'package:http/http.dart' as http;

class CustomerService {
  final String baseUrl = "http://localhost:5292/api/Customer";

  // Add a customer
  Future<http.Response> addCustomer(Customer customer) async {
    try {
      Map<String, dynamic> mappedData = {
        "custname": customer.custname,
        "city": customer.city,
        "phone": customer.phone,
      };

      var url = Uri.parse("$baseUrl/AddCustomer");
      var client = http.Client();

      http.Response response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(mappedData),
      );

      return response;
    } catch (e) {
      throw Exception("Error adding customer: $e");
    }
  }

  Future<List<Customer>> fetchCustomers() async {
    try {
      var url = Uri.parse("$baseUrl/GetAllCustomers");
      var client = http.Client();

      http.Response response =
          await client.get(url, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((customer) => Customer.fromJson(customer)).toList();
      } else {
        throw Exception(
            "Failed to fetch customers. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching customers: $e");
    }
  }

  Future<Map<String, dynamic>> updateCustomer({
    required int custId,
    required String custName,
    required String phone,
    required String city,
  }) async {
    final url = Uri.parse('$baseUrl/UpdateCustomer');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'custid': custId,
          'custname': custName,
          'phone': phone,
          'city': city,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Customer updated successfully'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['ErrorMessage'] ?? 'Failed to update customer'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteCustomer(int customerId) async {
    if (customerId <= 0) {
      return {
        'status': false,
        'message': 'Invalid customer ID',
      };
    }

    final url = Uri.parse('$baseUrl/DeleteCustomer/$customerId');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': true,
          'message': data['Message'] ?? 'Customer deleted successfully',
        };
      } else {
        return {
          'status': false,
          'message': 'Failed to delete customer. Please try again later.',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'An error occurred: $e',
      };
    }
  }
}
