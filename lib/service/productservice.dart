import 'dart:convert';
import 'package:ecomapp/model/productmodel.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final String baseUrl = "http://localhost:5292/api/Product";

  Future<http.Response> addProduct(Products product) async {
    try {
      Map<String, dynamic> mappedData = {
        "productname": product.productname,
        "mrp": product.mrp,
        "stock": product.stock
      };
      var url = Uri.parse("$baseUrl/addproducts");
      var client = http.Client();

      http.Response response = await client.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(mappedData),
      );

      return response;
    } catch (e) {
      throw Exception("Error adding product: $e");
    }
  }

  Future<List<Products>> fetchProducts() async {
    try {
      var url = Uri.parse("$baseUrl/getallproduct");
      var client = http.Client();

      http.Response response =
          await client.get(url, headers: {"Content-Type": "application/json"});
      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((product) => Products.fromJson(product)).toList();
      } else {
        throw Exception(
            "Failed to fetch products. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  Future<Map<String, dynamic>> updateProduct({
    required int productid,
    required String productname,
    required double mrp,
    required int stock,
  }) async {
    final url = Uri.parse('$baseUrl/updateproduct');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'productid': productid,
          'productname': productname,
          'mrp': mrp,
          'stock': stock,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Product updated successfully'};
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['ErrorMessage'] ?? 'Failed to update product'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteProduct(int productId) async {
    if (productId <= 0) {
      return {
        'status': false,
        'message': 'Invalid product ID',
      };
    }

    final url = Uri.parse('$baseUrl/DeleteProduct/$productId');
    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'status': true,
          'message': data['Message'] ?? 'Product deleted successfully',
        };
      } else {
        return {
          'status': false,
          'message': 'Failed to delete Product. Please try again later.',
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
