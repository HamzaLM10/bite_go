import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.imageUrl,
    required this.rating,
    required this.deliveryMinutes,
    required this.deliveryFee,
    required this.isOpen,
  });

  final String id;
  final String name;
  final String cuisine;
  final String imageUrl;
  final double rating;
  final int deliveryMinutes;
  final double deliveryFee;
  final bool isOpen;

  @override
  List<Object?> get props => [
        id, name, cuisine, imageUrl, rating, deliveryMinutes, deliveryFee, isOpen,
      ];
}