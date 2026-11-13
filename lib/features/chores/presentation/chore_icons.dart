import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:flutter/material.dart';

/// One selectable chore icon: a stable key, its glyph and the two names the
/// picker searches by.
///
/// The names are catalog data (like `defaultGroups` in
/// `settings/domain/default_chore_settings.dart`), not screen copy: the family
/// never renames an icon, and the picker searches both languages.
@immutable
final class ChoreIconDef {
  const ChoreIconDef(this.key, this.icon, this.nameBn, this.nameEn);

  final String key;
  final IconData icon;
  final String nameBn;
  final String nameEn;

  String nameFor(String languageCode) => languageCode == 'bn' ? nameBn : nameEn;
}

/// Every chore icon, in the order the picker shows them.
///
/// This is the ONE literal icon map allowed in the chores feature (road map
/// 3.1): a chore template stores an `iconKey` and every screen resolves it
/// here. An unknown key falls back to a neutral checklist icon, so a family's
/// data written by a newer build never shows an empty slot.
const List<ChoreIconDef> choreIcons = <ChoreIconDef>[
  ChoreIconDef('kitchen', Icons.kitchen_outlined, 'রান্নাঘর', 'Kitchen'),
  ChoreIconDef('cooking', Icons.soup_kitchen_outlined, 'রান্না', 'Cooking'),
  ChoreIconDef(
    'cleaning',
    Icons.cleaning_services_outlined,
    'পরিচ্ছন্নতা',
    'Cleaning',
  ),
  ChoreIconDef('broom', Icons.cleaning_services_rounded, 'ঝাড়ু', 'Broom'),
  ChoreIconDef('dishes', Icons.local_dining_outlined, 'বাসন', 'Dishes'),
  ChoreIconDef('water', Icons.water_drop_outlined, 'পানি', 'Water'),
  ChoreIconDef('fridge', Icons.ac_unit_outlined, 'ফ্রিজ', 'Fridge'),
  ChoreIconDef('living', Icons.weekend_outlined, 'বসার ঘর', 'Living room'),
  ChoreIconDef(
    'laundry',
    Icons.local_laundry_service_outlined,
    'কাপড় ধোয়া',
    'Laundry',
  ),
  ChoreIconDef('laundry_iron', Icons.iron_outlined, 'ইস্ত্রি', 'Ironing'),
  ChoreIconDef('vacuum', Icons.wind_power_outlined, 'ভ্যাকুয়াম', 'Vacuum'),
  ChoreIconDef('trash', Icons.delete_outline_rounded, 'ময়লা', 'Trash'),
  ChoreIconDef('bed', Icons.bed_outlined, 'বিছানা', 'Bedroom'),
  ChoreIconDef('bath', Icons.bathtub_outlined, 'গোসল', 'Bathroom'),
  ChoreIconDef('fan', Icons.mode_fan_off_outlined, 'ফ্যান', 'Fan'),
  ChoreIconDef('light', Icons.lightbulb_outline_rounded, 'বাতি', 'Light'),
  ChoreIconDef('door', Icons.door_front_door_outlined, 'দরজা', 'Door'),
  ChoreIconDef('plant', Icons.local_florist_outlined, 'গাছ', 'Plant'),
  ChoreIconDef('pet', Icons.pets_outlined, 'পোষা প্রাণী', 'Pet'),
  ChoreIconDef('child', Icons.child_care_outlined, 'শিশু', 'Child'),
  ChoreIconDef('study', Icons.menu_book_outlined, 'পড়াশোনা', 'Study'),
  ChoreIconDef('school', Icons.school_outlined, 'স্কুল', 'School'),
  ChoreIconDef('medicine', Icons.medication_outlined, 'ওষুধ', 'Medicine'),
  ChoreIconDef('shopping', Icons.shopping_basket_outlined, 'বাজার', 'Shopping'),
  ChoreIconDef('bill', Icons.receipt_long_outlined, 'বিল', 'Bill'),
  ChoreIconDef('phone', Icons.phone_in_talk_outlined, 'ফোন', 'Phone'),
  ChoreIconDef('repair', Icons.handyman_outlined, 'মেরামত', 'Repair'),
  ChoreIconDef('tools', Icons.build_outlined, 'যন্ত্রপাতি', 'Tools'),
  ChoreIconDef('car', Icons.directions_car_outlined, 'গাড়ি', 'Car'),
  ChoreIconDef('bike', Icons.pedal_bike_outlined, 'সাইকেল', 'Bicycle'),
  ChoreIconDef('box', Icons.inventory_2_outlined, 'বাক্স', 'Box'),
  ChoreIconDef('calendar', Icons.event_outlined, 'ক্যালেন্ডার', 'Calendar'),
  ChoreIconDef('clock', Icons.schedule_outlined, 'ঘড়ি', 'Clock'),
  ChoreIconDef(
    'checklist',
    Icons.checklist_rtl_outlined,
    'তালিকা',
    'Checklist',
  ),
  ChoreIconDef('star', Icons.star_border_rounded, 'তারা', 'Star'),
  ChoreIconDef('heart', Icons.favorite_border_rounded, 'ভালোবাসা', 'Heart'),
  ChoreIconDef('home', Icons.home_outlined, 'বাড়ি', 'Home'),
  ChoreIconDef('work', Icons.work_outline_rounded, 'কাজ', 'Work'),
  ChoreIconDef('gift', Icons.card_giftcard_outlined, 'উপহার', 'Gift'),
  ChoreIconDef('other', Icons.checklist_rounded, 'অন্যান্য', 'Other'),
  // ── Kitchen and food ────────────────────────────────────────────────────
  ChoreIconDef('cafe', Icons.local_cafe_outlined, 'ক্যাফে', 'Cafe'),
  ChoreIconDef('dining', Icons.restaurant_outlined, 'খাবার', 'Dining'),
  ChoreIconDef(
    'breakfast',
    Icons.breakfast_dining_outlined,
    'নাশতা',
    'Breakfast',
  ),
  ChoreIconDef('lunch', Icons.lunch_dining_outlined, 'দুপুরের খাবার', 'Lunch'),
  ChoreIconDef('snack', Icons.icecream_outlined, 'নাস্তা', 'Snack'),
  ChoreIconDef(
    'microwave',
    Icons.microwave_outlined,
    'মাইক্রোওয়েভ',
    'Microwave',
  ),
  ChoreIconDef('blender', Icons.blender_outlined, 'ব্লেন্ডার', 'Blender'),
  ChoreIconDef(
    'coffee_maker',
    Icons.coffee_maker_outlined,
    'কফি মেকার',
    'Coffee maker',
  ),
  ChoreIconDef('grill', Icons.outdoor_grill_outlined, 'বারবিকিউ', 'Grill'),
  ChoreIconDef('fireplace', Icons.fireplace_outlined, 'উনুন', 'Stove'),
  // ── Cleaning and laundry ────────────────────────────────────────────────
  ChoreIconDef('wash', Icons.local_car_wash_outlined, 'ধোয়া', 'Wash'),
  ChoreIconDef('soap', Icons.soap_outlined, 'সাবান', 'Soap'),
  ChoreIconDef('sanitize', Icons.sanitizer_outlined, 'জীবাণুমুক্ত', 'Sanitize'),
  ChoreIconDef(
    'dry_clean',
    Icons.dry_cleaning_outlined,
    'ড্রাই ক্লিন',
    'Dry clean',
  ),
  ChoreIconDef('wardrobe', Icons.checkroom_outlined, 'ওয়ারড্রব', 'Wardrobe'),
  ChoreIconDef('shower', Icons.shower_outlined, 'শাওয়ার', 'Shower'),
  ChoreIconDef('toilet', Icons.wc_outlined, 'টয়লেট', 'Toilet'),
  ChoreIconDef('handwash', Icons.wash_outlined, 'হাত ধোয়া', 'Handwash'),
  // ── Home and garden ─────────────────────────────────────────────────────
  ChoreIconDef('window', Icons.window_outlined, 'জানালা', 'Window'),
  ChoreIconDef('balcony', Icons.balcony_outlined, 'বারান্দা', 'Balcony'),
  ChoreIconDef('garden', Icons.yard_outlined, 'বাগান', 'Garden'),
  ChoreIconDef('deck', Icons.deck_outlined, 'ডেক', 'Deck'),
  ChoreIconDef('garage', Icons.garage_outlined, 'গ্যারেজ', 'Garage'),
  ChoreIconDef('stairs', Icons.stairs_outlined, 'সিঁড়ি', 'Stairs'),
  ChoreIconDef('roof', Icons.roofing_outlined, 'ছাদ', 'Roof'),
  ChoreIconDef('pool', Icons.pool_outlined, 'পুল', 'Pool'),
  ChoreIconDef('air', Icons.air_outlined, 'বাতাস', 'Air'),
  // ── Utilities and devices ───────────────────────────────────────────────
  ChoreIconDef(
    'electricity',
    Icons.electrical_services_outlined,
    'বিদ্যুৎ',
    'Electricity',
  ),
  ChoreIconDef('gas', Icons.propane_tank_outlined, 'গ্যাস', 'Gas'),
  ChoreIconDef('plumbing', Icons.plumbing_outlined, 'প্লাম্বিং', 'Plumbing'),
  ChoreIconDef('internet', Icons.router_outlined, 'ইন্টারনেট', 'Internet'),
  ChoreIconDef('tv', Icons.tv_outlined, 'টিভি', 'TV'),
  ChoreIconDef('computer', Icons.computer_outlined, 'কম্পিউটার', 'Computer'),
  ChoreIconDef('camera', Icons.camera_alt_outlined, 'ক্যামেরা', 'Camera'),
  ChoreIconDef(
    'charger',
    Icons.battery_charging_full_outlined,
    'চার্জার',
    'Charger',
  ),
  ChoreIconDef(
    'thermostat',
    Icons.thermostat_outlined,
    'তাপমাত্রা',
    'Thermostat',
  ),
  // ── Health ──────────────────────────────────────────────────────────────
  ChoreIconDef(
    'hospital',
    Icons.local_hospital_outlined,
    'হাসপাতাল',
    'Hospital',
  ),
  ChoreIconDef('doctor', Icons.medical_services_outlined, 'ডাক্তার', 'Doctor'),
  ChoreIconDef('vaccine', Icons.vaccines_outlined, 'টিকা', 'Vaccine'),
  ChoreIconDef(
    'first_aid',
    Icons.health_and_safety_outlined,
    'প্রাথমিক চিকিৎসা',
    'First aid',
  ),
  // ── Money and documents ─────────────────────────────────────────────────
  ChoreIconDef('wallet', Icons.wallet_outlined, 'মানিব্যাগ', 'Wallet'),
  ChoreIconDef('card', Icons.credit_card_outlined, 'কার্ড', 'Card'),
  ChoreIconDef('savings', Icons.savings_outlined, 'সঞ্চয়', 'Savings'),
  ChoreIconDef('bank', Icons.account_balance_outlined, 'ব্যাংক', 'Bank'),
  ChoreIconDef('print', Icons.print_outlined, 'প্রিন্ট', 'Print'),
  ChoreIconDef('mail', Icons.mail_outline_rounded, 'চিঠি', 'Mail'),
  ChoreIconDef('documents', Icons.folder_outlined, 'নথি', 'Documents'),
  // ── Travel and outdoors ─────────────────────────────────────────────────
  ChoreIconDef('bus', Icons.directions_bus_outlined, 'বাস', 'Bus'),
  ChoreIconDef('train', Icons.train_outlined, 'ট্রেন', 'Train'),
  ChoreIconDef(
    'motorcycle',
    Icons.two_wheeler_outlined,
    'মোটরসাইকেল',
    'Motorcycle',
  ),
  ChoreIconDef('fuel', Icons.local_gas_station_outlined, 'জ্বালানি', 'Fuel'),
  ChoreIconDef('parking', Icons.local_parking_outlined, 'পার্কিং', 'Parking'),
  ChoreIconDef('umbrella', Icons.umbrella_outlined, 'ছাতা', 'Umbrella'),
  ChoreIconDef('rain', Icons.thunderstorm_outlined, 'বৃষ্টি', 'Rain'),
  ChoreIconDef('sun', Icons.wb_sunny_outlined, 'রোদ', 'Sun'),
  ChoreIconDef('night', Icons.nightlight_outlined, 'রাত', 'Night'),
  ChoreIconDef('insects', Icons.pest_control_outlined, 'পোকামাকড়', 'Insects'),
  // ── Family, school and fun ──────────────────────────────────────────────
  ChoreIconDef('birthday', Icons.cake_outlined, 'জন্মদিন', 'Birthday'),
  ChoreIconDef('party', Icons.celebration_outlined, 'উৎসব', 'Party'),
  ChoreIconDef('toys', Icons.toys_outlined, 'খেলনা', 'Toys'),
  ChoreIconDef('games', Icons.sports_esports_outlined, 'গেম', 'Games'),
  ChoreIconDef('robot', Icons.smart_toy_outlined, 'রোবট', 'Robot'),
  ChoreIconDef('baby', Icons.child_friendly_outlined, 'বাচ্চা', 'Baby'),
  ChoreIconDef('stroller', Icons.stroller_outlined, 'স্ট্রলার', 'Stroller'),
  ChoreIconDef('books', Icons.library_books_outlined, 'বই', 'Books'),
  ChoreIconDef('calculator', Icons.calculate_outlined, 'হিসাব', 'Calculator'),
  ChoreIconDef('science', Icons.science_outlined, 'বিজ্ঞান', 'Science'),
  ChoreIconDef(
    'exercise',
    Icons.fitness_center_outlined,
    'ব্যায়াম',
    'Exercise',
  ),
  ChoreIconDef('sports', Icons.sports_soccer_outlined, 'খেলাধুলা', 'Sports'),
  ChoreIconDef('cricket', Icons.sports_cricket_outlined, 'ক্রিকেট', 'Cricket'),
  // ── Safety, work and errands ────────────────────────────────────────────
  ChoreIconDef('keys', Icons.key_outlined, 'চাবি', 'Keys'),
  ChoreIconDef('lock', Icons.lock_outline_rounded, 'তালা', 'Lock'),
  ChoreIconDef('security', Icons.shield_outlined, 'নিরাপত্তা', 'Security'),
  ChoreIconDef(
    'fire_safety',
    Icons.local_fire_department_outlined,
    'অগ্নি নিরাপত্তা',
    'Fire safety',
  ),
  ChoreIconDef('store', Icons.storefront_outlined, 'দোকান', 'Store'),
  ChoreIconDef('bag', Icons.shopping_bag_outlined, 'ব্যাগ', 'Bag'),
  ChoreIconDef('paint', Icons.format_paint_outlined, 'রং', 'Paint'),
  ChoreIconDef('carpentry', Icons.carpenter_outlined, 'কাঠের কাজ', 'Carpentry'),
  ChoreIconDef('pest', Icons.cruelty_free_outlined, 'প্রাণী', 'Animal'),
];

final Map<String, ChoreIconDef> _iconsByKey = <String, ChoreIconDef>{
  for (final icon in choreIcons) icon.key: icon,
};

/// The icon of a chore; an unknown (or null) key is the neutral checklist.
IconData choreIcon(String? key) =>
    _iconsByKey[key]?.icon ?? Icons.checklist_rounded;

/// The localized label of an icon, or null when the key is unknown.
String? choreIconLabel(BuildContext context, String key) =>
    _iconsByKey[key]?.nameFor(Localizations.localeOf(context).languageCode);

/// Every key [choreIcon] knows, in picker order.
List<String> get knownIconKeys => <String>[
  for (final icon in choreIcons) icon.key,
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
