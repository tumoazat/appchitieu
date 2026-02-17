import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Get transactions collection for a user
  CollectionReference _getTransactionsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('transactions');
  }

  // Add transaction
  Future<String> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _getTransactionsCollection(transaction.userId)
          .add(transaction.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Update transaction
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _getTransactionsCollection(transaction.userId)
          .doc(transaction.id)
          .update(transaction.toFirestore());
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String userId, String transactionId) async {
    try {
      await _getTransactionsCollection(userId)
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // Get transactions stream with optional date range
  Stream<List<TransactionModel>> getTransactions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      Query query = _getTransactionsCollection(userId)
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date', 
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date', 
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }

  // Get transactions by month
  Stream<List<TransactionModel>> getTransactionsByMonth(
    String userId,
    int year,
    int month,
  ) {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      return getTransactions(
        userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw Exception('Failed to get transactions by month: $e');
    }
  }

  // Get recent transactions (limited)
  Stream<List<TransactionModel>> getRecentTransactions(
    String userId, {
    int limit = 5,
  }) {
    try {
      return _getTransactionsCollection(userId)
          .orderBy('date', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get recent transactions: $e');
    }
  }

  // Get transaction by id
  Future<TransactionModel?> getTransactionById(
    String userId,
    String transactionId,
  ) async {
    try {
      final doc = await _getTransactionsCollection(userId)
          .doc(transactionId)
          .get();

      if (!doc.exists) return null;

      return TransactionModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  // Get transactions by category
  Stream<List<TransactionModel>> getTransactionsByCategory(
    String userId,
    String categoryId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      Query query = _getTransactionsCollection(userId)
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get transactions by category: $e');
    }
  }

  // Get total amount by type and date range
  Future<double> getTotalAmount(
    String userId, {
    required TransactionType type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _getTransactionsCollection(userId)
          .where('type', isEqualTo: type == TransactionType.income ? 'income' : 'expense');

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('date',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query.get();
      
      double total = 0;
      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        total += transaction.amount;
      }

      return total;
    } catch (e) {
      throw Exception('Failed to get total amount: $e');
    }
  }
}
