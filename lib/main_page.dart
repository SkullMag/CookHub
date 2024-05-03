import 'package:cook/search.dart';
import 'package:cook/recipes_list.dart';
import 'package:pocketbase/pocketbase.dart';
import 'service/PocketbaseService.dart';
import 'package:cook/settings_screen.dart';
import 'package:flutter/material.dart';


class RecipeModel {
  final String title;
  final String description;
  final String instructions;
  final String photo;
  final int time;
  final String calorie;

  
  RecipeModel({required this.title, required this.description, required this.instructions, required this.photo, required this.time, required this.calorie});
  
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      title: json['title'],
      description: json['description'],
      instructions: json['instructions'],
      photo: json['photo'],
      time : json['time'],
      calorie: json['calorie'],

    );
  }
}

Future<List<RecipeModel>> getRecipes() async {
  final records = await PocketBaseService.pb.collection('recipes').getFullList(
    sort: '-created',
  );
  List<RecipeModel> recipes = [];
  for(int i = 0; i < records.length; ++i) {
      recipes.add(RecipeModel.fromJson(records[i].toJson()));
  }
  return recipes;
}
  

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _searchPage = SearchPage();
  final _recipesListPage = RecipesListPage(recipes: getRecipes());
  int _selectedIndex = 0;
  final pb = PocketBaseService.pb;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  static const colorNew = Color.fromARGB(255, 148, 205, 120);


  Future<String> getName() async {
    print(pb.authStore.model);
    final record =  await pb.collection('users').getOne(pb.authStore.model.id);
    //await pb.collection('users').delete(pb.authStore.model.id); // удаление пользователя
    // final records = await pb.collection('recipes').getFullList( // рецепты
    // sort: '-created',
    // );
    // print(records.length);
    final name = record.getDataValue<String>('name');  
    return name;
  }

  Future<String> getAbout() async {
    print(pb.authStore.model);
    final record =  await pb.collection('users').getOne(pb.authStore.model.id);
    //await pb.collection('users').delete(pb.authStore.model.id); // удаление пользователя
    // final records = await pb.collection('recipes').getFullList( // рецепты
    // sort: '-created',
    // );
    // print(records.length);
    final about = record.getDataValue<String>('about');  
    return about;
  }
  
  Widget _buildMainPage() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/png/chef.png", width: 100, height: 130),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: getName(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  print("snap error");
                  print(snapshot.error);
                  return Text('Имя');
                } else {
                  return Text(snapshot.data ?? 'Имя не найдено',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
                        FutureBuilder<String>(
              future: getAbout(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  print("snap error");
                  print(snapshot.error);
                  return Text('Обо мне');
                } else {
                  return Text(snapshot.data ?? 'Описание не найдено',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              },
            ),
 
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text("0",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                      Text("Рецепты",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                    ],
                  ),
                  Column(
                    children: [
                      Text("0",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                      Text("Подписчики",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                    ],
                  ),
                  Column(
                    children: [
                      Text("0",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                      Text("Подписки",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                    ],
            )
          ],
        ),
          ],
      ))
    );
  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorNew),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.settings, color: colorNew), 
              onPressed: () {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
    );
  },
)
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: _selectedIndex == 0 ? _buildMainPage() : _selectedIndex == 1 ? _searchPage  : _selectedIndex ==  4 ?  _recipesListPage : Container(), 
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home, color: colorNew),
            label: 'Домой',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search, color: colorNew),
            label: 'Поиск',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.add, color: colorNew),
            label: 'Добавить',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.star, color: colorNew),
            label: 'Избранное',
          ),
          BottomNavigationBarItem(
            icon: Image.asset("assets/png/chef_hat.png", width: 20, height: 20, color: colorNew),
            label: 'Рецепты',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorNew,
        onTap: _onItemTapped,
      ),
    );
  }
}







