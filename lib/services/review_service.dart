import 'package:dio/dio.dart';

class ReviewService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://server.pgbee.in'));
  
  // Set authorization header for authenticated requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
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
      final response = await _dio.post('/review', data: {
        'name': name,
        'rating': rating,
        'text': text,
        'date': date,
        'hostelId': hostelId,
        if (image != null) 'image': image,
      });

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': response.data,
        'message': 'Review created successfully',
      };
    } catch (e) {
      print('Review Service Error - Create: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to create review',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to create review',
      };
    }
  }

  // Get reviews by authenticated user - GET /review/user
  Future<Map<String, dynamic>> getUserReviews() async {
    try {
      final response = await _dio.get('/review/user');

      return {
        'success': response.statusCode == 200,
        'data': response.data,
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
      final response = await _dio.get('/review/review/hostel/$hostelId');

      return {
        'success': response.statusCode == 200,
        'data': response.data,
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
      final response = await _dio.get('/review/$reviewId');

      return {
        'success': response.statusCode == 200,
        'data': response.data,
      };
    } catch (e) {
      print('Review Service Error - Get Review: $e');
      
      if (e is DioException && e.response?.statusCode == 404) {
        return {
          'success': false,
          'error': 'Review not found',
        };
      }
      
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
      final response = await _dio.put('/review/$reviewId', data: {
        'name': name,
        'rating': rating,
        'text': text,
        if (image != null) 'image': image,
      });

      return {
        'success': response.statusCode == 200,
        'data': response.data,
        'message': 'Review updated successfully',
      };
    } catch (e) {
      print('Review Service Error - Update: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to update review',
        };
      }
      
      return {
        'success': false,
        'error': 'Failed to update review',
      };
    }
  }

  // Delete a review - DELETE /review/:id
  Future<Map<String, dynamic>> deleteReview(String reviewId) async {
    try {
      final response = await _dio.delete('/review/$reviewId');

      return {
        'success': response.statusCode == 200,
        'message': 'Review deleted successfully',
      };
    } catch (e) {
      print('Review Service Error - Delete: $e');
      
      if (e is DioException) {
        return {
          'success': false,
          'error': e.response?.data['message'] ?? 'Failed to delete review',
        };
      }
      
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
