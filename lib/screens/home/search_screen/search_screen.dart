import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import 'package:carive/models/car_model.dart';
import 'package:carive/providers/search_screen_provider.dart';
import 'package:carive/screens/home/transluscent_card/transluscent_card.dart';
import 'package:carive/services/auth.dart';
import 'package:carive/services/car_database_service.dart';
import 'package:carive/shared/cars_list.dart';
import 'package:carive/shared/constants.dart';
import 'package:carive/shared/custom_elevated_button.dart';
import 'package:carive/shared/custom_scaffold.dart';

import '../../../shared/circular_progress_indicator.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthService auth = AuthService();
  final CarService carService = CarService();
  late TextEditingController searchController;

  @override
  void initState() {
    searchController = TextEditingController();
    final searchScreenStateVariables =
        Provider.of<SearchScreenState>(context, listen: false);
    searchScreenStateVariables.selectedFuel = null;
    searchScreenStateVariables.selectedSeatCapacity = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchScreenStateVariables
          .updatePriceRange(const RangeValues(1000, 10000));
    });
    context.read<SearchScreenState>().searchQuery = '';

    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF3E515F),
                child: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text("Search"),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: buildSearchField(context),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.filter_alt_outlined,
                          color: themeColorGreen,
                        ),
                        onPressed: _showFilterDialog,
                      ),
                    ],
                  ),
                  hSizedBox20,
                  _buildCarGridView(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildSearchField(BuildContext context) {
    return TextFormField(
      autofocus: true,
      controller: searchController,
      onChanged: (value) {
        context.read<SearchScreenState>().updateSearchQuery(value);
      },
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        suffixIcon: IconButton(
          onPressed: () {
            context.read<SearchScreenState>().updateSearchQuery('');
            searchController.clear();
          },
          icon: Icon(
            Icons.clear,
            color: themeColorGreen,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: themeColorGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: themeColorGreen),
        ),
        hintText: "Search for Brand, Model",
        hintStyle: TextStyle(color: themeColorblueGrey),
      ),
    );
  }

  Widget _buildCarGridView() {
    return StreamBuilder<QuerySnapshot>(
      stream: carService.car,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CustomProgressIndicator();
        }

        final searchScreenState = Provider.of<SearchScreenState>(context);

        final List<CarModel> allCars = snapshot.data!.docs
            .map((doc) => CarModel.fromSnapshot(doc))
            .toList();

        final List<CarModel> filteredCars = allCars.where((car) {
          final carModel = car.carModel.toLowerCase();
          final carBrand = car.make.toLowerCase();
          final seatCapacity = car.seatCapacity;
          final selectedFuel = car.fuelType;
          final carPrice = car.amount;

          final searchQuery =
              context.read<SearchScreenState>().searchQuery!.toLowerCase();
          return (carModel.contains(searchQuery) ||
                  carBrand.contains(searchQuery)) &&
              (searchScreenState.selectedSeatCapacity == null ||
                  searchScreenState.selectedSeatCapacity == seatCapacity) &&
              (searchScreenState.selectedFuel == null ||
                  searchScreenState.selectedFuel == selectedFuel) &&
              (searchScreenState.minPrice != null &&
                  searchScreenState.maxPrice != null &&
                  carPrice >= searchScreenState.minPrice! &&
                  carPrice <= searchScreenState.maxPrice!);
        }).toList();

        if (filteredCars.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animation_lkgtssru.json',
                    height: MediaQuery.of(context).size.height / 4),
                const Text(
                  'No Search Result.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: filteredCars.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return TransluscentCard(
              latitude: filteredCars[index].latitude,
              longitude: filteredCars[index].longitude,
              carId: filteredCars[index].carId!,
              image: filteredCars[index].imageUrl,
              brand: filteredCars[index].make,
              model: filteredCars[index].carModel,
              location: filteredCars[index].location,
              price: filteredCars[index].amount,
              fuelType: filteredCars[index].fuelType,
              modelYear: filteredCars[index].modelYear,
              seatCapacity: filteredCars[index].seatCapacity,
              ownerId: filteredCars[index].userId,
              isAvailable: filteredCars[index].isAvailable,
              ownerFcmToken: filteredCars[index].ownerFcmToken,
            );
          },
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final searchScreenState = Provider.of<SearchScreenState>(context);
        return AlertDialog(
          backgroundColor: themeColorGrey,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Cars",
                style: TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Fuel Type",
                  style: TextStyle(
                    color: themeColorblueGrey,
                    fontSize: 18,
                  ),
                ),
                hSizedBox10,
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: themeColorGreen),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String?>(
                        validator: (value) =>
                            value == null ? "Field required" : null,
                        borderRadius: BorderRadius.circular(20),
                        isExpanded: true,
                        icon: const Visibility(
                          visible: false,
                          child: Icon(Icons.arrow_downward),
                        ),
                        dropdownColor: themeColorGrey,
                        style: const TextStyle(color: Colors.white),
                        value: searchScreenState.selectedFuel,
                        items: fuelType.map((e) {
                          return DropdownMenuItem<String?>(
                            value: e,
                            child: Center(child: Text(e)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          searchScreenState.updateSelectedFuel(value);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Seat Capacity",
                  style: TextStyle(
                    color: themeColorblueGrey,
                    fontSize: 18,
                  ),
                ),
                hSizedBox10,
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: themeColorGreen),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        borderRadius: BorderRadius.circular(20),
                        isExpanded: true,
                        icon: const Visibility(
                          visible: false,
                          child: Icon(Icons.arrow_downward),
                        ),
                        dropdownColor: themeColorGrey,
                        style: const TextStyle(color: Colors.white),
                        value: searchScreenState.selectedSeatCapacity,
                        items: seatCapacity.map((e) {
                          return DropdownMenuItem<String?>(
                            value: e,
                            child: Center(child: Text(e)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          searchScreenState.updateSelectedSeatCapacity(value);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Price Range",
                  style: TextStyle(
                    color: themeColorblueGrey,
                    fontSize: 18,
                  ),
                ),
                hSizedBox10,
                RangeSlider(
                  divisions: 180,
                  activeColor: themeColorGreen,
                  min: 100,
                  max: 10000,
                  values: searchScreenState.priceRange,
                  labels: searchScreenState.priceRangeLabels,
                  onChanged: (value) {
                    searchScreenState.updatePriceRange(value);
                  },
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹100",
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      "₹10000",
                      style: TextStyle(color: Colors.white),
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            CustomElevatedButton(
              onPressed: () {
                searchScreenState.updateSelectedFuel(null);
                searchScreenState.updateSelectedSeatCapacity(null);
                searchScreenState
                    .updatePriceRange(const RangeValues(1000, 10000));
                Navigator.pop(context);
              },
              text: "Clear filters",
              paddingHorizontal: 3,
              paddingVertical: 3,
            ),
          ],
        );
      },
    );
  }
}
