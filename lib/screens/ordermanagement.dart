import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch customer details
  Future<Map<int, Map<String, dynamic>>> _fetchCustomerDetails() async {
    final customerSnapshot = await _firestore.collection('Customer').get();
    final customerMap = <int, Map<String, dynamic>>{};

    for (var doc in customerSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      customerMap[data['customer_id']] = data;
    }

    return customerMap;
  }

  // Fetch orders with details
  Stream<List<Map<String, dynamic>>> _fetchOrdersWithDetails(String status) {
    return _firestore
        .collection('OrderMasters')
        .where('status', isEqualTo: status)
        .snapshots()
        .asyncMap((orderSnapshot) async {
      List<Map<String, dynamic>> ordersWithDetails = [];
      final customerData = await _fetchCustomerDetails();

      for (var orderDoc in orderSnapshot.docs) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final customerId = orderData['customer_id'];

        final orderDetailsSnapshot =
            await orderDoc.reference.collection('OrderDetails').get();

        List<Map<String, dynamic>> orderDetails = orderDetailsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        ordersWithDetails.add({
          ...orderData,
          'customer_name':
              customerData[customerId]?['customer_name'] ?? 'Unknown',
          'orderDetails': orderDetails,
        });
      }

      return ordersWithDetails;
    });
  }

  // Deliver Order
  Future<void> _deliverOrder(String orderId) async {
    await _firestore
        .collection('OrderMasters')
        .doc(orderId)
        .update({'status': 'Delivered'});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order marked as delivered!')),
    );
  }

  Widget _buildOrderList(String status) {
    return StreamBuilder(
      stream: _fetchOrdersWithDetails(status),
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No orders found."));
        }

        return ListView(
          children: snapshot.data!.map((orderData) {
            final customerId = orderData['customer_id'];
            final customerName = orderData['customer_name'];
            final orderId = orderData['order_id'];

            return ExpansionTile(
              title: Text('Customer ID: $customerId - $customerName'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order No: ${orderData['order_id']}'),
                  Text('Order Value: ₹${orderData['order_value']}'),
                  Text(
                    'Order Time: ${orderData['order_time'].toDate()}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              children: [
                Column(
                  children: (orderData['orderDetails'] as List).map((product) {
                    return ListTile(
                      title: Text(product['product_name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${product['category_name']}'),
                          Text('Quantity: ${product['quantity']}'),
                          Text('Price: ₹${product['selling_price']}'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if (status == 'Pending')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => _deliverOrder(orderId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Deliver',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Order Management'),
          backgroundColor: Colors.teal,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Delivered'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList('Pending'),
            _buildOrderList('Delivered'),
          ],
        ),
      ),
    );
  }
}
