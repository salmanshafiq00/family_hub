import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:flutter/material.dart';

/// The icon of a chore (P3-15).
///
/// This is the ONE literal icon map allowed in the chores feature (road map
/// 3.1): a chore template stores an `iconKey` (a short string, chosen from the
/// settings catalogs) and every screen resolves it here. An unknown key falls
/// back to a neutral checklist icon, so a family's data written by a newer
/// build never shows an empty slot.
///
/// The keys are NOT an option list the user edits: the picker (P3-16) lists
/// [knownIconKeys], and the catalogs (P3-06) store the same ids.
IconData choreIcon(String? key) => switch (key) {
  'kitchen' => Icons.kitchen_outlined,
  'cooking' => Icons.soup_kitchen_outlined,
  'cleaning' => Icons.cleaning_services_outlined,
  'water' => Icons.water_drop_outlined,
  'fridge' => Icons.ac_unit_outlined,
  'living' => Icons.weekend_outlined,
  'dishes' => Icons.local_dining_outlined,
  'laundry' => Icons.local_laundry_service_outlined,
  'trash' => Icons.delete_outline_rounded,
  'bed' => Icons.bed_outlined,
  'bath' => Icons.bathtub_outlined,
  'broom' => Icons.cleaning_services_rounded,
  'shopping' => Icons.shopping_basket_outlined,
  'plant' => Icons.local_florist_outlined,
  'pet' => Icons.pets_outlined,
  'study' => Icons.menu_book_outlined,
  'repair' => Icons.handyman_outlined,
  'child' => Icons.child_care_outlined,
  'car' => Icons.directions_car_outlined,
  'bike' => Icons.pedal_bike_outlined,
  'laundry_iron' => Icons.iron_outlined,
  'vacuum' => Icons.wind_power_outlined,
  'medicine' => Icons.medication_outlined,
  'bill' => Icons.receipt_long_outlined,
  'phone' => Icons.phone_in_talk_outlined,
  'door' => Icons.door_front_door_outlined,
  'fan' => Icons.mode_fan_off_outlined,
  'light' => Icons.lightbulb_outline_rounded,
  'tools' => Icons.build_outlined,
  'box' => Icons.inventory_2_outlined,
  'calendar' => Icons.event_outlined,
  'clock' => Icons.schedule_outlined,
  'checklist' => Icons.checklist_rtl_outlined,
  'star' => Icons.star_border_rounded,
  'heart' => Icons.favorite_border_rounded,
  'home' => Icons.home_outlined,
  'school' => Icons.school_outlined,
  'work' => Icons.work_outline_rounded,
  'gift' => Icons.card_giftcard_outlined,
  'other' => Icons.checklist_rounded,
  _ => Icons.checklist_rounded,
};

/// Every key [choreIcon] knows, in the order the picker shows them.
const List<String> knownIconKeys = <String>[
  'kitchen',
  'cooking',
  'cleaning',
  'broom',
  'dishes',
  'water',
  'fridge',
  'living',
  'laundry',
  'laundry_iron',
  'vacuum',
  'trash',
  'bed',
  'bath',
  'fan',
  'light',
  'door',
  'plant',
  'pet',
  'child',
  'study',
  'school',
  'medicine',
  'shopping',
  'bill',
  'phone',
  'repair',
  'tools',
  'car',
  'bike',
  'box',
  'calendar',
  'clock',
  'checklist',
  'star',
  'heart',
  'home',
  'work',
  'gift',
  'other',
];

/// The icon of one chore: its group's `iconKey`, else the fallback. Kept here
/// so the tile, the detail header and the calendar agree.
IconData choreIconFor(ChoreItem item) =>
    choreIcon(choreGroupIconKeys[item.groupId]);

/// Group id -> icon key (the built-in catalogs of P3-06). The picker and the
/// settings screen read it; a family's renamed group keeps its id, so the icon
/// follows the rename.
const Map<String, String> choreGroupIconKeys = <String, String>{
  'kitchen': 'kitchen',
  'cooking': 'cooking',
  'cleaning': 'cleaning',
  'water': 'water',
  'fridge': 'fridge',
  'living': 'living',
  'other': 'other',
};
