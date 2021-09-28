import 'package:delivery_alex_salcedo/src/pages/restaurant/categories/create/restaurant_categories_create_controller.dart';
import 'package:delivery_alex_salcedo/src/utils/my_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class RestaurantCategoriesCreatePage extends StatefulWidget {
  RestaurantCategoriesCreatePage({Key key}) : super(key: key);

  @override
  _RestaurantCategoriesCreatePageState createState() =>
      _RestaurantCategoriesCreatePageState();
}

class _RestaurantCategoriesCreatePageState
    extends State<RestaurantCategoriesCreatePage> {
  RestaurantCategoriesCreateController _con =
      new RestaurantCategoriesCreateController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context, refresh);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva categoría'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          _textFieldCategoryName(),
          _textFieldCategoryDescription(),
        ],
      ),
      bottomNavigationBar: _buttonCreate(),
    );
  }

  Container _buttonCreate() => Container(
        height: 50,
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        child: ElevatedButton(
          onPressed: _con.createCategory,
          child: Text('Crear categoría'),
          style: ElevatedButton.styleFrom(
              primary: MyColors.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: EdgeInsets.symmetric(vertical: 15)),
        ),
      );

  Container _textFieldCategoryName() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      decoration: BoxDecoration(
          color: MyColors.primaryOpacityColor,
          borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: _con.nameController,
        decoration: InputDecoration(
            hintText: 'Nombre de la categoría',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(color: MyColors.primaryColorDark),
            suffixIcon: Icon(
              Icons.list_alt,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  Container _textFieldCategoryDescription() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 50, vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: MyColors.primaryOpacityColor,
          borderRadius: BorderRadius.circular(20)),
      child: TextField(
        controller: _con.descriptionController,
        maxLength: 255,
        maxLines: 3,
        decoration: InputDecoration(
            hintText: 'Descripción de la categoría',
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(15),
            hintStyle: TextStyle(color: MyColors.primaryColorDark),
            suffixIcon: Icon(
              Icons.description,
              color: MyColors.primaryColor,
            )),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}
