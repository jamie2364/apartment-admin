import 'package:flutter/material.dart';
import 'package:cleaning_app/models/cleaning_details.dart';
import 'package:cleaning_app/services/api_service.dart';
import 'package:cleaning_app/screens/apartment_inventory_list_page.dart';

class ProductInventoryPage extends StatefulWidget {
  const ProductInventoryPage({super.key});

  @override
  State<ProductInventoryPage> createState() => _ProductInventoryPageState();
}

class _ProductInventoryPageState extends State<ProductInventoryPage> {
  late Future<List<CleaningDetails>> _apartmentsFuture;

  @override
  void initState() {
    super.initState();
    _apartmentsFuture = ApiService.fetchCleaningDetails();
  }

  void _navigateToInventoryList(
    BuildContext context,
    String apartmentId,
    String apartmentName,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApartmentInventoryListPage(
          apartmentId: apartmentId,
          apartmentName: apartmentName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8CB2A4),
      ),
      body: FutureBuilder<List<CleaningDetails>>(
        future: _apartmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No apartments found.'));
          }

          final apartments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: apartments.length,
            itemBuilder: (context, index) {
              final apartment = apartments[index];
              return SizedBox(
                height: 260,
                child: GestureDetector(
                  onTap: () => _navigateToInventoryList(
                    context,
                    apartment.id,
                    apartment.name,
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: apartment.imageUrl.isNotEmpty
                                ? NetworkImage(apartment.imageUrl)
                                : null,
                            child: apartment.imageUrl.isEmpty
                                ? const Icon(
                                    Icons.apartment,
                                    color: Colors.grey,
                                    size: 70,
                                  )
                                : null,
                          ),
                          const SizedBox(height: 20),
                          // This Row places the title and arrow side-by-side
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize:
                                MainAxisSize.min, // Keeps the row centered
                            children: [
                              Text(
                                apartment.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey.shade500,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
