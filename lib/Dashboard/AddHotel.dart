import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../main.dart';

class AddHotel extends StatefulWidget {
  @override
  _AddHotelFormState createState() => _AddHotelFormState();
}

class _AddHotelFormState extends State<AddHotel> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _chargesController = TextEditingController();
  double _rating = 0.0; // Changed to double for rating
  List<File> _images = [];
  List<dynamic> _cities = [];
  String? _selectedCityId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  Future<void> fetchCities() async {
    final response = await http.get(Uri.parse('${Url}/dropdownhotal.php'));
    if (response.statusCode == 200) {
      setState(() {
        _cities = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load cities');
    }
  }

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    setState(() {
      if (pickedFiles != null) {
        _images = pickedFiles.map((file) => File(file.path)).toList();
      } else {
        print('No images selected.');
      }
    });
  }

  Future<void> uploadImages() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String hotelName = _nameController.text;
      String cityId = _selectedCityId!;
      String description = _descriptionController.text;
      String address = _addressController.text;
      String charges = _chargesController.text;
      String rating = _rating.toString(); // Convert rating to string
      String roomType = _selectedRoomType ?? ''; // Ensure roomType is included

      var request = http.MultipartRequest('POST', Uri.parse('${Url}/addhotal.php'));
      for (var image in _images) {
        String fileName = image.path.split('/').last;
        request.files.add(await http.MultipartFile.fromPath('images[]', image.path));
      }
      request.fields['name'] = hotelName;
      request.fields['city_id'] = cityId;
      request.fields['description'] = description;
      request.fields['address'] = address;
      request.fields['charges'] = charges;
      request.fields['rating'] = rating; // Add this line to include rating
      request.fields['room_type'] = roomType; // Add this line to include room type

      var response = await request.send();

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hotel added successfully')),
        );
        clearForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add hotel')),
        );
      }
    }
  }

  void clearForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _descriptionController.clear();
    _addressController.clear();
    _chargesController.clear();
    setState(() {
      _rating = 0.0; // Reset rating
      _images = [];
      _selectedCityId = null;
    });
  }

  List<String> _roomTypes = ['Single', 'Double', 'Suite']; // Example room types
  String? _selectedRoomType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Hotel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Hotel Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter Hotel Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the hotel name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'City',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedCityId,
                hint: Text('Select City'),
                items: _cities.map<DropdownMenuItem<String>>((city) {
                  return DropdownMenuItem<String>(
                    key: UniqueKey(),
                    value: city['id'].toString(),
                    child: Text(city['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCityId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a city';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter Description',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Address',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'Enter Address',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Per Day Charges',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _chargesController,
                decoration: const InputDecoration(
                  hintText: 'Enter Per Day Charges',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the per day charges';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Room Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _selectedRoomType,
                hint: Text('Select Room Type'),
                items: _roomTypes.map<DropdownMenuItem<String>>((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a room type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Rating',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 0,
                maxRating: 5,
                itemSize: 40,
                allowHalfRating: true,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: _images.isEmpty
                    ? Text('No images selected.')
                    : Wrap(
                  spacing: 10,
                  children: _images.map((image) => Image.file(image, width: 100, height: 100)).toList(),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: getImage,
                  icon: Icon(Icons.image),
                  label: Text('Select Images'),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : uploadImages,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

