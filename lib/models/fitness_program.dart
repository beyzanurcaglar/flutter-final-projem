import 'package:flutter/material.dart';

class FitnessProgram {
  final AssetImage image;
  final String name;
  final String cals;
  final String time;

  FitnessProgram({
    required this.image,
    required this.name,
    required this.cals,
    required this.time,
  });
}
final List<FitnessProgram> fitnessPrograms =[

  FitnessProgram(
    image: AssetImage('photo/tennis.jpg'),
    name: 'tennis',
    cals: '460 kcal',
    time: '60min',
  ),
  FitnessProgram(
    image: AssetImage('photo/cardio.jpg'),
    name: 'cardio',
    cals: '660 kcal',
    time: '60min',
  ),
  FitnessProgram(
    image: AssetImage('photo/running.png'),
    name: 'running',
    cals: '460 kcal',
    time: '60min',
  ),
  FitnessProgram(
    image: AssetImage('photo/volleyball.jpg'),
    name: 'volleyball',
    cals: '360 kcal',
    time: '60min',
  ),
  FitnessProgram(
    image: AssetImage('photo/football.jpg'),
    name: 'football',
    cals: '600 kcal',
    time: '60min',
  ),
  FitnessProgram(
    image: AssetImage('photo/cycling.jpg'),
    name: 'cycling',
    cals: '600 kcal',
    time: '60min',
  ),
];




