import 'dart:io';

import 'package:dars_82/utils/constans/product_graph_query.dart';
import 'package:dars_82/utils/constans/product_mutations.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  String _searchQuery = '';

  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  Future<void> _showProductDialog(BuildContext context,
      {Map<String, dynamic>? product}) async {
    final titleController =
        TextEditingController(text: product?['title'] ?? '');
    final priceController = TextEditingController(
        text: product != null ? product['price'].toString() : '');
    final descriptionController =
        TextEditingController(text: product?['description'] ?? '');
    final categoryIdController = TextEditingController(
        text: product != null ? product['category']['id'].toString() : '');
    final imagesController =
        TextEditingController(text: product?['images']?.join(', ') ?? '');

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: categoryIdController,
                  decoration: const InputDecoration(labelText: 'Category ID'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imagesController,
                  decoration: const InputDecoration(
                      labelText: 'Images (comma separated URLs)'),
                ),
                const SizedBox(height: 10),
                if (_pickedImage != null)
                  Image.file(
                    File(_pickedImage!.path),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Choose Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                final newProduct = {
                  'title': titleController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'description': descriptionController.text,
                  'categoryId': double.tryParse(categoryIdController.text) ?? 0,
                  'images': imagesController.text
                      .split(',')
                      .map((e) => e.trim())
                      .toList(),
                };
                if (_pickedImage != null) {
                  newProduct['images'] = [
                    _pickedImage!.path
                  ]; // Replace with your image upload logic
                }
                if (product == null) {
                  _addProduct(context, newProduct);
                } else {
                  newProduct['id'] = product['id'];
                  _editProduct(context, newProduct);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addProduct(
      BuildContext context, Map<String, dynamic> product) async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(addProduct),
          variables: {
            'title': product['title'],
            'price': product['price'],
            'description': product['description'],
            'categoryId': product['categoryId'],
            'images': product['images'],
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product added successfully"),
        ),
      );
      print(result);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
        ),
      );
    }
  }

  Future<void> _editProduct(
      BuildContext context, Map<String, dynamic> product) async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(updateProduct),
          variables: {
            'id': product['id'],
            'title': product['title'],
            'price': product['price'],
            'description': product['description'],
            'categoryId': product['categoryId'],
            'images': product['images'],
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product updated successfully"),
        ),
      );
      print(result);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
        ),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context, String productId) async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(deleteProduct),
          variables: {
            'id': productId,
          },
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product deleted successfully"),
        ),
      );
      print(result);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            Expanded(
              child: Query(
                options: QueryOptions(
                  document: gql(fetchProducts),
                ),
                builder: (QueryResult result,
                    {FetchMore? fetchMore, VoidCallback? refetch}) {
                  if (result.hasException) {
                    return Center(
                      child: Text(result.exception.toString()),
                    );
                  }

                  if (result.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List products = result.data!['products'];
                  List filteredProducts = products.where((product) {
                    final title = product['title'].toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return title.contains(query);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text("No products found"),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Image.network(
                            product['images']?.first ??
                                "https://www.ecosmob.com/wp-content/uploads/2023/05/Hire-Flutter-App-Developers.png",
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                          title: Text(product['title']),
                          subtitle: Text('${product['description']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showProductDialog(context, product: product);
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _deleteProduct(context, product['id']);
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        onPressed: () {
          _showProductDialog(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
