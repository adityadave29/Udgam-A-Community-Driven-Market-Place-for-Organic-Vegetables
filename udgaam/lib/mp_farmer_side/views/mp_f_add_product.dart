import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:udgaam/mp_farmer_side/controller/add_product_controller.dart';
import 'package:udgaam/services/supabase_service.dart';
import 'package:udgaam/widgets/auth_input.dart';
import 'package:udgaam/widgets/registration_image_preview.dart';

class MpFAddProducts extends StatefulWidget {
  const MpFAddProducts({super.key});

  @override
  State<MpFAddProducts> createState() => _MpFAddProductsState();
}

class _MpFAddProductsState extends State<MpFAddProducts> {
  final TextEditingController productnamecontroller = TextEditingController();
  final TextEditingController pricecontroller = TextEditingController();
  final TextEditingController quantitycontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();
  final TextEditingController harvestDatecontroller = TextEditingController();
  final TextEditingController expiryDatecontroller = TextEditingController();

  final AddProductController controller = Get.put(AddProductController());
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  // Dropdown Options
  final List<String> categories = [
    "Vegetables",
    "Fruits",
    "Grains",
    "Pulses",
    "Herbs",
    "Dairy Products"
  ];

  final List<String> units = ["Gram", "Kilogram", "Liter", "Milliliter"];

  // Selected values for dropdown
  String? selectedCategory;
  String? selectedUnit;

  void clearFields() {
    productnamecontroller.clear();
    pricecontroller.clear();
    quantitycontroller.clear();
    descriptioncontroller.clear();
    harvestDatecontroller.clear();
    expiryDatecontroller.clear();
    selectedCategory = null;
    selectedUnit = null;
    controller.productImage.value = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            AuthInput(
              label: "Product Name",
              hintText: "Enter product name",
              controller: productnamecontroller,
              Validatorcallback: ValidationBuilder().required().build(),
            ),

            const SizedBox(height: 20),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              hint:
                  const Text("Select Category", style: TextStyle(fontSize: 14)),
              decoration: InputDecoration(
                labelText: "Category",
                labelStyle: const TextStyle(fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedCategory = value),
            ),

            const SizedBox(height: 20),

            AuthInput(
              label: "Price",
              hintText: "Enter product price",
              controller: pricecontroller,
              Validatorcallback: ValidationBuilder().required().build(),
            ),

            const SizedBox(height: 20),

            // Unit Dropdown
            DropdownButtonFormField<String>(
              value: selectedUnit,
              hint: const Text("Select Unit", style: TextStyle(fontSize: 14)),
              decoration: InputDecoration(
                labelText: "Unit",
                labelStyle: const TextStyle(fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              items: units.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Text(unit, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: (value) => setState(() => selectedUnit = value),
            ),

            const SizedBox(height: 20),

            AuthInput(
              label: "Quantity",
              hintText: "Enter product quantity",
              controller: quantitycontroller,
              Validatorcallback: ValidationBuilder().required().build(),
            ),

            const SizedBox(height: 20),

            AuthInput(
              label: "Description",
              hintText: "Enter product description",
              controller: descriptioncontroller,
              Validatorcallback: ValidationBuilder().required().build(),
            ),

            const SizedBox(height: 20),

            // Harvest Date Field
            TextFormField(
              controller: harvestDatecontroller,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Harvest Date",
                hintText: "Select harvest date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  harvestDatecontroller.text =
                      pickedDate.toIso8601String().split('T')[0];
                }
              },
            ),

            const SizedBox(height: 20),

            // Expiry Date Field
            TextFormField(
              controller: expiryDatecontroller,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Expiry Date",
                hintText: "Select expiry date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  expiryDatecontroller.text =
                      pickedDate.toIso8601String().split('T')[0];
                }
              },
            ),

            const SizedBox(height: 25),

            // Image Upload
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Upload an image of product",
                      style: TextStyle(fontSize: 15)),
                  TextButton(
                    onPressed: () => controller.pickProductImage(),
                    child: const Text("Upload"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Obx(
              () => Column(
                children: [
                  if (controller.productImage.value != null)
                    FarmerRegistrationPreview(
                        imageFile: controller.productImage),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size.fromHeight(40)),
              ),
              onPressed: () async {
                await controller.storeProduct(
                  userId: supabaseService.currentUser.value!.id,
                  productName: productnamecontroller.text,
                  category: selectedCategory ?? '',
                  price: double.tryParse(pricecontroller.text) ?? 0,
                  unit: selectedUnit ?? '',
                  quantity: int.tryParse(quantitycontroller.text) ?? 0,
                  description: descriptioncontroller.text,
                  harvestDate: harvestDatecontroller.text,
                  expiryDate: expiryDatecontroller.text,
                );
                clearFields();
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
