import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewService {
  final String _baseUrl = 'https://server.pgbee.in';
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  // Create a review - POST /review
  Future<Map<String, dynamic>> createReview({
    required String name,
    required double rating,
    required String text,
    required String date,
    required String hostelId,
    String? image,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/review');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final body = jsonEncode({
        'name': name,
        'rating': rating,
        'text': text,
        'date': date,
        'hostelId': hostelId,
        if (image != null) 'image': image,
      });
      final response = await http.post(url, headers: headers, body: body);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': data,
        'message': 'Review created successfully',
      };
    } catch (e) {
      print('Review Service Error - Create: $e');
      return {
        'success': false,
        'error': 'Failed to create review',
      };
    }
  }

  // Get reviews by authenticated user - GET /review/user
  Future<Map<String, dynamic>> getUserReviews() async {
    try {
      final url = Uri.parse('$_baseUrl/review/user');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.get(url, headers: headers);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200,
        'data': data,
      };
    } catch (e) {
      print('Review Service Error - Get User Reviews: $e');
      // Return mock data for testing
      return {
        'success': true,
        'data': getMockUserReviews(),
      };
    }
  }

  // Get reviews for a specific hostel - GET /review/review/hostel/:id
  Future<Map<String, dynamic>> getHostelReviews(String hostelId) async {
    try {
      final url = Uri.parse('$_baseUrl/review/review/hostel/$hostelId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.get(url, headers: headers);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200,
        'data': data,
      };
    } catch (e) {
      print('Review Service Error - Get Hostel Reviews: $e');
      // Return mock data for testing
      return {
        'success': true,
        'data': getMockHostelReviews(hostelId),
      };
    }
  }

  // Get a specific review - GET /review/:id
  Future<Map<String, dynamic>> getReview(String reviewId) async {
    try {
      final url = Uri.parse('$_baseUrl/review/$reviewId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.get(url, headers: headers);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Review not found',
        };
      }
      return {
        'success': response.statusCode == 200,
        'data': data,
      };
    } catch (e) {
      print('Review Service Error - Get Review: $e');
      return {
        'success': false,
        'error': 'Failed to get review',
      };
    }
  }

  // Update a review - PUT /review/:id
  Future<Map<String, dynamic>> updateReview({
    required String reviewId,
    required String name,
    required double rating,
    required String text,
    String? image,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/review/$reviewId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final body = jsonEncode({
        'name': name,
        'rating': rating,
        'text': text,
        if (image != null) 'image': image,
      });
      final response = await http.put(url, headers: headers, body: body);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      return {
        'success': response.statusCode == 200,
        'data': data,
        'message': 'Review updated successfully',
      };
    } catch (e) {
      print('Review Service Error - Update: $e');
      return {
        'success': false,
        'error': 'Failed to update review',
      };
    }
  }

  // Delete a review - DELETE /review/:id
  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final url = Uri.parse('$_baseUrl/review/$reviewId');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Review not found',
        };
      }
      return {
        'success': response.statusCode == 200,
        'message': 'Review deleted successfully',
      };
    } catch (e) {
      print('Review Service Error - Delete: $e');
      return {
        'success': false,
        'error': 'Failed to delete review',
      };
    }
  }

  // Mock data for testing purposes
  List<Map<String, dynamic>> getMockUserReviews() {
    return [
      {
        'id': 'review_1',
        'name': 'John Doe',
        'rating': 4.5,
        'text': 'Great place to stay! Clean and well-maintained.',
        'date': '2025-01-15',
        'image': 'https://example.com/review_image1.jpg',
        'hostelId': 'hostel_1',
        'createdAt': '2025-01-15T10:00:00Z',
        'updatedAt': '2025-01-15T10:00:00Z',
      },
      {
        'id': 'review_2',
        'name': 'John Doe',
        'rating': 4.0,
        'text': 'Good facilities and friendly staff.',
        'date': '2025-01-10',
        'image': null,
        'hostelId': 'hostel_2',
        'createdAt': '2025-01-10T10:00:00Z',
        'updatedAt': '2025-01-10T10:00:00Z',
      },
    ];
  }

List<Map<String, dynamic>> getMockHostelReviews(String hostelId) {
  return [
    {
      'id': 'review_1',
      'name': 'John Doe',
      'rating': 4.5,
      'text': 'Great place to stay! Clean and well-maintained.',
      'date': '2025-01-15',
      'image': 'https://example.com/review_image1.jpg',
      'hostelId': hostelId,
      'createdAt': '2025-01-15T10:00:00Z',
      'updatedAt': '2025-01-15T10:00:00Z',
    },
    {
      'id': 'review_3',
      'name': 'Jane Smith',
      'rating': 5.0,
      'text': 'Excellent hostel with all amenities!',
      'date': '2025-01-12',
      'image': null,
      'hostelId': hostelId,
      'createdAt': '2025-01-12T10:00:00Z',
      'updatedAt': '2025-01-12T10:00:00Z',
    },
    {
      'id': 'review_4',
      'name': 'Mike Johnson',
      'rating': 3.5,
      'text': 'Decent place, could improve the kitchen facilities.',
      'date': '2025-01-08',
      'image': 'https://example.com/review_image3.jpg',
      'hostelId': hostelId,
      'createdAt': '2025-01-08T10:00:00Z',
      'updatedAt': '2025-01-08T10:00:00Z',
    },
  ];
}
}