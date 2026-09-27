// ЛР 1 — шесть независимых виджетов.

import 'package:flutter/material.dart';

void main() {
  runApp(const Lab1App());
}

class Lab1App extends StatelessWidget {
  const Lab1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ЛР 1')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task 1:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task1(),
              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 2:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task2(),

              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 3:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task3(),
              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 4:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task4(),
              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 5:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task5(),
              const SizedBox(height: 4),
              Divider(),
              const SizedBox(height: 4),
              Text(
                'Task 6:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              task6(),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. Заголовок — Text, крупный жирный текст чёрного цвета, обрезается в одну строку, если не помещается.
Widget task1() {
  return const Text(
    'Это очень длинный заголовок, который должен обрезаться в одну строку',
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  );
}

// 2. Подпись — небольшой, нежирный курсивный текст белого цвета, обрезается в две строки.
// Также реализуйте подложку из тёмно-серого контейнера с закруглениями, чтобы текст было видно
Widget task2() {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[800],
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Это подпись к фотографии, которая может быть достаточно длинной и занимать несколько строк, но обрезается после двух строк',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: Colors.white,
      ),
    ),
  );
}

// 3. Иконка — любая Icon на ваш вкус, с применением цвета и размером.
Widget task3() {
  return const Icon(
    Icons.star,
    color: Colors.amber,
    size: 48,
  );
}

// 4. Кнопка с иконкой избранного — большая иконка сердца красного цвета без фона.
// При нажатии пишет в консоль "Вы добавили в избранное"
Widget task4() {
  return IconButton(
    iconSize: 56,
    color: Colors.red,
    icon: const Icon(Icons.favorite),
    onPressed: () {
      print('Вы добавили в избранное');
    },
  );
}

// 5. Кнопка «Подробнее» — кнопка с текстом и обводкой, при нажатии пишет в консоль "Узнать детали"
Widget task5() {
  return OutlinedButton(
    onPressed: () {
      print('Узнать детали');
    },
    child: const Text('Подробнее'),
  );
}

// 6. Изображение в стиле Polaroid
Widget task6() {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.network(
          'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
          width: 300,
          height: 300,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 8),
        const Text(
          'Polaroid',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}